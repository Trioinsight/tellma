import { Injectable, ApplicationRef } from '@angular/core';
import { AuthConfig, OAuthService, OAuthEvent, OAuthErrorEvent } from 'angular-oauth2-oidc';
import { appsettings } from './global-resolver.guard';
import { Subject, Observable, timer, of, from, ReplaySubject, throwError } from 'rxjs';
import { catchError, filter, map, first, tap, finalize, mergeMap } from 'rxjs/operators';
import { StorageService } from './storage.service';
import { CleanerService } from './cleaner.service';
import { ProgressOverlayService } from './progress-overlay.service';
import { JwksValidationHandler } from 'angular-oauth2-oidc-jwks';
import { environment } from '~/environments/environment';

// a set of events that various services in the application are interested in knowing about
export enum AuthEvent {

  // the user independently navigated to Identity Server and signed out from there
  SignedOutFromAuthority = 'signed_out_from_authority',

  // the user independently navigated to Identity Server and signed in as a different user
  SignedInAsDifferentUser = 'signed_in_as_different_user',

  // misc_error_while_checking_session_state
  SessionError = 'session_error',

  // the user cleared the access token in the storage from another tab
  StorageIsCleared = 'storage_is_cleared'
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  // Note: this service is a wrapper around the 'angular-oauth2-oidc' library + extra functionality

  private nonce: string;
  private discoveryDocumentLoaded$ = new ReplaySubject<boolean>();

  constructor(
    private oauth: OAuthService, private storage: StorageService, private progress: ProgressOverlayService,
    private cleaner: CleanerService, private appRef: ApplicationRef) {
    this.init();
  }

  private _events$ = new Subject<AuthEvent>();
  public get events$(): Observable<AuthEvent> {
    return this._events$;
  }

  private init(): void {

    const authConfig: AuthConfig = {

      // url of the Identity Provider
      issuer: appsettings.identityAddress,

      // url of the SPA to redirect the user to after login
      redirectUri: window.location.origin + '/sign-in-callback',

      // url of the SPA to redirect the hidden iFrame to after a silent refresh
      silentRefreshRedirectUri: window.location.origin + '/assets/silent-refresh-callback.html',

      // enable OpenID Connect session management
      sessionChecksEnabled: true,

      // without this the angular router was getting thrown off and refused to redirect in SignInCallbackGuard
      clearHashAfterLogin: false,

      // the SPA's id. The SPA is registerd with this id at the auth-server
      clientId: 'WebClient',

      // the scope for the permissions the client should request
      scope: 'openid profile email tellma',

      // Allow unsecure auth in dev environments
      requireHttps: environment.production,

      // these can be null and if they are they will be retrieved by loading the discovery document
      // setting them in the appsettings is just an optimization to allow instant startup of the app
      jwks: appsettings.identityConfig ? appsettings.identityConfig.jwks : null,
      loginUrl: appsettings.identityConfig ? appsettings.identityConfig.loginUrl : null,
      logoutUrl: appsettings.identityConfig ? appsettings.identityConfig.logoutUrl : null,
      sessionCheckIFrameUrl: appsettings.identityConfig ? appsettings.identityConfig.sessionCheckIFrameUrl : null,
    };

    // configure the 'angular-oauth2-oidc' library
    this.oauth.configure(authConfig);

    // set the validation handler
    this.oauth.tokenValidationHandler = new JwksValidationHandler();

    // relay some events from the storage system
    this.storage.changed$.subscribe(e => {
      if (e.key === 'access_token' || !e.key) { // !e.key means that storage.clear() was invoked
        if (!e.newValue) {
          this._events$.next(AuthEvent.StorageIsCleared);
        }
      }
    });

    // relay some events already provided by angular-oauth2-oidc
    (this.oauth.events as Observable<OAuthEvent>).subscribe(e => {

      if (e.type === 'session_terminated') {
        this._events$.next(AuthEvent.SignedOutFromAuthority);
      }

      if (e instanceof OAuthErrorEvent) {
        if (e.type === 'token_validation_error' && !!e.reason &&
          e.reason.toString().startsWith('After refreshing, we got an id_token for another user (sub)')) {
          // this is a little hacky but the library provides no other API to distinguish the token validation errors
          this._events$.next(AuthEvent.SignedInAsDifferentUser);
        }
      }

      if (e.type === 'session_error') {
        this._events$.next(AuthEvent.SessionError);
      }

      // capture the discovery document events in a replay subject
      // so that all events that require the discovery documents can
      // reliably wait for it to be available
      if (this.isDiscoveryDocumentNeeded(authConfig)) {

        if (e.type === 'discovery_document_loaded') {
          // for some reason this event is fired twice, first with info = null
          // and second time with info = some stuff
          if (!!(e as any).info) {
            this.discoveryDocumentLoaded$.next(true);
          }
        }

        if (e.type === 'discovery_document_validation_error') {
          this.discoveryDocumentLoaded$.error('validation error');
        }

        if (e.type === 'discovery_document_load_error') {
          this.discoveryDocumentLoaded$.error('loading error');
        }
      }
    });

    if (this.isDiscoveryDocumentNeeded(authConfig)) {
      // if the configuration is not complete then we must load the discovery document
      // it will be needed for: sign-in, sign-out, url token validation and silent refresh
      this.oauth.loadDiscoveryDocument();
    } else {
      // if no discovery document is needed, return true immediately
      // whenever someone is waiting for it
      this.discoveryDocumentLoaded$.next(true);
    }
  }

  public setupAutomaticSilentRefresh() {

    // setup periodic silent refresh
    const basePeriodInSecondsFromConfig = appsettings.identityConfig ? appsettings.identityConfig.tokenRefreshPeriodInSeconds : null;
    const basePeriod = (basePeriodInSecondsFromConfig || (60 * 60)) * 1000; // Default is 1 hour
    const rand = (Math.random() * 2) - 1; // between 1 and -1
    const period = basePeriod + (rand * basePeriod / 2); // 1 hour +/-30 minutes

    // wait for the application to stablize first before you run the timer, as per https://bit.ly/2VfkAgQ
    this.appRef.isStable.pipe(
      first(e => e === true),
      tap(_ => console.log('[Auth] App is stable...'))
    ).subscribe(() => {
      timer(0, period)
        .pipe(
          filter(_ => this.isAuthenticated),
          catchError(_ => of(0))
        )
        .subscribe(n => {

          // the code below tries to minimize waste if the user opens the system
          // on many tabs at the same time, by checking if the 'nonce' has changed
          // it means only one of the tabs will be refreshing the access token

          const nonceKey = 'nonce';
          const storageNonce = this.storage.getItem(nonceKey);
          const localNonce = this.nonce;

          // always refresh first time you open, then refresh
          // periodically if none of the other tabs has refreshed already
          // tslint:disable-next-line:no-console
          console.debug('[Auth] Refreshing...');
          if (n === 0 || storageNonce === localNonce) {
            this.refreshSilently().subscribe(
              _ => {
                this.nonce = this.storage.getItem(nonceKey);
                console.log('[Auth] Successfully refreshed access token');
              }, err => {
                this.nonce = this.storage.getItem(nonceKey);
                console.error('[Auth] Failed to refresh access token', err);
              });
          } else {
            console.log('[Auth] Another tab has refreshed the access token');
          }

          this.nonce = this.storage.getItem(nonceKey);
        });
    });
  }

  private isDiscoveryDocumentNeeded(authConfig: AuthConfig): boolean {
    return !authConfig.jwks || !authConfig.loginUrl || !authConfig.logoutUrl || !authConfig.sessionCheckIFrameUrl;
  }

  public get isSignedIn$(): Observable<boolean> {

    // this method performs 2 checks in sequence
    // if both fail then the user is not signed in

    // (1) check if the user already has a valid token in memory
    if (this.isAuthenticated) {
      return of(true);
    } else {

      const key = 'silent_refresh';
      this.progress.startAsyncOperation(key, 'CheckingYourSession');

      // (2) Check that the user has an active session with the identity server
      const obs$ =
        this.discoveryDocumentLoaded$.pipe(
          mergeMap(isLoaded => {
            if (!isLoaded) {
              return of(false);
            } else {
              return from(this.oauth.silentRefresh().catch(_ => false))
                .pipe(map(_ => this.isAuthenticated));
            }
          }),
          tap(() => this.progress.completeAsyncOperation(key)),
          catchError(err => {
            this.progress.completeAsyncOperation(key);
            return throwError(err);
          }),
          finalize(() => this.progress.completeAsyncOperation(key))
        );

      return obs$;
    }
  }

  public parseUrlToken(): Observable<boolean> {

    // this method attempts to load a valid token from the URL
    // NOT redirect the user to the identity server, for that
    // we use 'initImplicitFlow' method

    const obs$ = this.discoveryDocumentLoaded$.pipe(
      mergeMap(_ => from(this.oauth.tryLogin()))
    );

    return obs$;
  }

  public get state(): string {
    return this.oauth.state;
  }

  public initImplicitFlow(returnUrl: string = null) {
    this.oauth.initImplicitFlow(returnUrl);
  }

  public refreshSilently(): Observable<OAuthEvent> {
    return this.discoveryDocumentLoaded$.pipe(
      mergeMap(_ => from(this.oauth.silentRefresh()))
    );
  }

  public signOut() {
    // when the user requests a sign out, it is important to
    // clear the state of the application for security, especially localstorage

    // clean the app state (keep the id token since it is needed for the subsequent logout)
    const idToken = this.storage.getItem('id_token');
    this.cleaner.cleanLocalStorage(true); // preserve user independent stuff
    this.storage.setItem('id_token', idToken);

    // Close down SignalR connection with the server
    this.cleaner.cleanServerNotifications();

    // go to identity server and sign out from there
    this.oauth.logOut();
  }

  public get email(): string {
    const claims = this.oauth.getIdentityClaims() as any;
    if (!claims) {
      return null;
    }
    return claims.email;
  }

  public get isAuthenticated(): boolean {
    return this.oauth.hasValidAccessToken();
  }

  public get userName(): string {
    const claims = this.oauth.getIdentityClaims() as any;
    if (!claims) {
      return null;
    }

    return claims.email;
  }
}
