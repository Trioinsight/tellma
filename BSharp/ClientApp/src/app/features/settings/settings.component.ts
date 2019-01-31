import { Component, OnInit, OnDestroy, ViewChild, TemplateRef } from '@angular/core';
import { Settings } from '~/app/data/dto/settings';
import { Subject, Observable, of } from 'rxjs';
import { WorkspaceService, DetailsStatus } from '~/app/data/workspace.service';
import { ApiService } from '~/app/data/api.service';
import { ActivatedRoute, Router } from '@angular/router';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { TranslateService } from '@ngx-translate/core';
import { switchMap, catchError, tap } from 'rxjs/operators';
import { GetByIdResponse } from '~/app/data/dto/get-by-id-response';
import { addRelatedEntitiesToWorkspace } from '~/app/data/util';
import { DtoKeyBase } from '~/app/data/dto/dto-key-base';
import { ICanDeactivate } from '~/app/data/unsaved-changes.guard';

@Component({
  selector: 'b-settings',
  templateUrl: './settings.component.html',
  styleUrls: ['./settings.component.scss']
})
export class SettingsComponent implements OnInit, OnDestroy, ICanDeactivate {

  public _viewModel: Settings;
  public _viewModelJson: string;
  public _editModel: Settings;

  private expand = 'PrimaryLanguage, SecondaryLanguage';
  private notifyFetch$: Subject<void>;
  private notifyDestruct$ = new Subject<void>();
  private detailsStatus: DetailsStatus;
  private _errorMessage: string; // in the document area itself
  private _modalErrorMessage: string; // in the modal
  private _validationErrors: { [id: string]: string[] } = {}; // on the fields
  private crud = this.api.settingsApi(this.notifyDestruct$); // Just for intellisense

  workspaceApplyFns: { [collection: string]: (stale: DtoKeyBase, fresh: DtoKeyBase) => DtoKeyBase };

  @ViewChild('errorModal')
  public errorModal: TemplateRef<any>;

  @ViewChild('unsavedChangesModal')
  public unsavedChangesModal: TemplateRef<any>;

  constructor(private workspace: WorkspaceService, private api: ApiService, private router: Router,
    private route: ActivatedRoute, public modalService: NgbModal, private translate: TranslateService) {


    // When the notifyFetch$ subject fires, cancel existing backend
    // call and dispatch a new backend call
    this.notifyFetch$ = new Subject<any>();
    this.notifyFetch$.pipe(
      switchMap(() => this.doFetch())
    ).subscribe();
  }

  private doFetch(): Observable<void> {
    // clear the errors before refreshing
    this.clearErrors();

    // ELSE fetch the record from server
    // first show the rotator
    this.detailsStatus = DetailsStatus.loading;

    // server call
    return this.crud.get({ expand: this.expand }).pipe(
      tap((response: GetByIdResponse<Settings>) => {

        // add the settings locally
        this._viewModel = response.Entity;

        // Add related items to the workspace
        addRelatedEntitiesToWorkspace(response.RelatedEntities, this.workspace, this.workspaceApplyFns);

        // display the settings
        this.detailsStatus = DetailsStatus.loaded;

      }),
      catchError((friendlyError) => {
        this.detailsStatus = DetailsStatus.error;
        this._errorMessage = friendlyError.error;
        return of(null);
      })
    );
  }

  private clearErrors(): void {
    this._errorMessage = null;
    this._modalErrorMessage = null;
    this._validationErrors = {};
  }

  private fetch() {
    this.notifyFetch$.next(null);
  }

  public handleActionError = (friendlyError) => {

    // This handles any errors caused by actions
    if (friendlyError.status === 422) {
      this._validationErrors = friendlyError.error;
    } else {
      this.displayModalError(friendlyError.error);
    }
  }

  public displayModalError(errorMessage: string) {
    // shows the error message in a dismissable modal
    this._modalErrorMessage = errorMessage;
    this.modalService.open(this.errorModal);
  }

  ngOnInit() {
    // As if the screen is opened a new
    this.clearErrors();

    // initialize the API service
    this.crud = this.api.settingsApi(this.notifyDestruct$);

    // Fetch the data of the screen
    this.fetch();
  }

  ngOnDestroy() {
    // Cancel any backend operations
    this.notifyDestruct$.next();
  }


  public canDeactivate(): boolean | Observable<boolean> {
    if (this.isDirty) {

      // IF there are unsaved changes, prompt the user asking if they would like them discarded
      const modal = this.modalService.open(this.unsavedChangesModal);

      // capture the user's decision in a subject:
      // first action when the user presses one of the two buttons
      // second func is when the user dismisses the modal with x or ESC or clicking the background
      const decision$ = new Subject<boolean>();
      modal.result.then(
        v => { decision$.next(v); decision$.complete(); },
        _ => { decision$.next(false); decision$.complete(); }
      );

      // return the subject that will eventually emit the user's decision
      return decision$;

    } else {

      // IF there are no unsaved changes, the navigation can happily proceed
      return true;
    }
  }

  ////////// UI Bindings

  get primaryPostFix(): string {
    if (this.model && this.model.SecondaryLanguageId) {
      return ` (${this.model.PrimaryLanguageSymbol})`;
    }

    return '';
  }

  get secondaryPostFix(): string {
    if (this.model && this.model.SecondaryLanguageId) {
      return ` (${this.model.SecondaryLanguageSymbol})`;
    }

    return '';
  }

  public get ws() {
    return this.workspace.current;
  }

  get errorMessage() {
    return this._errorMessage;
  }

  get modalErrorMessage() {
    return this._modalErrorMessage;
  }

  get validationErrors() {
    return this._validationErrors;
  }

  get model(): Settings {
    return this.isEdit ? this._editModel : this._viewModel;
  }

  get showSpinner(): boolean {
    return this.detailsStatus === DetailsStatus.loading;
  }

  get showDocument(): boolean {
    return this.detailsStatus === DetailsStatus.loaded ||
      this.detailsStatus === DetailsStatus.edit;
  }

  get showRefresh(): boolean {
    return !this.isEdit;
  }

  get isDirty(): boolean {
    // TODO This may cause sluggishness for large DTOs, we'll look into ways of optimizing it later
    return this.isEdit && this._viewModelJson !== JSON.stringify(this._editModel);
  }

  get isEdit(): boolean {
    return this.detailsStatus === DetailsStatus.edit;
  }

  get showViewToolbar(): boolean {
    return !this.showEditToolbar;
  }

  get showEditToolbar(): boolean {
    return this.detailsStatus === DetailsStatus.edit;
  }

  get showErrorMessage(): boolean {
    return this.detailsStatus === DetailsStatus.error;
  }

  onRefresh(): void {
    this.fetch();
  }

  onEdit(): void {
    if (this._viewModel) {
      // clone the model (to allow for canceling changes)
      this._viewModelJson = JSON.stringify(this._viewModel);
      this._editModel = JSON.parse(this._viewModelJson);

      // show the edit view
      this.detailsStatus = DetailsStatus.edit;
    }
  }

  get canEdit(): boolean {
    // TODO  Permissions
    return !!this.model;
  }

  onSave(): void {
    // if it's new the user expects a save to happen even if there is no red asterisk
    if (!this.isDirty) {
      // since no changes, don't save to the database
      // just go back to view mode
      this.clearErrors();
      this._editModel = null;
      this.detailsStatus = DetailsStatus.loaded;
    } else {

      // clear any errors displayed
      this.clearErrors();

      // prepare the save observable
      this.crud.save(this._editModel, { expand: this.expand, returnEntities: true }).subscribe(
        (response: GetByIdResponse<Settings>) => {

          // update the workspace with the DTO from the server
          this._viewModel = response.Entity;
          addRelatedEntitiesToWorkspace(response.RelatedEntities, this.workspace, this.workspaceApplyFns);

          // in screen mode always close the edit view
          this.detailsStatus = DetailsStatus.loaded;

          // remove the local copy the user was editing
          this._editModel = null;

        },
        (friendlyError) => this.handleActionError(friendlyError)
      );
    }
  }

  onCancel(): void {
    // clear the edit model and error messages
    this._editModel = null;
    this.clearErrors();

    // ... and then close the edit form
    this.detailsStatus = DetailsStatus.loaded;
  }

  public get flip() {
    // this is to flip the UI icons in RTL
    return this.workspace.ws.isRtl ? 'horizontal' : null;
  }
}
