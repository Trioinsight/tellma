import { Component, Input, OnInit } from '@angular/core';
import { tap } from 'rxjs/operators';
import { ApiService } from '~/app/data/api.service';
import { Agent, AgentForSave } from '~/app/data/entities/agent';
import { addToWorkspace } from '~/app/data/util';
import { WorkspaceService } from '~/app/data/workspace.service';
import { DetailsBaseComponent } from '~/app/shared/details-base/details-base.component';
import { TranslateService } from '@ngx-translate/core';
import { ActivatedRoute, ParamMap } from '@angular/router';
import { AgentDefinitionForClient } from '~/app/data/dto/definitions-for-client';
import { AgentRateForSave } from '~/app/data/entities/agent-rate';
import { Currency } from '~/app/data/entities/currency';

@Component({
  selector: 't-agents-details',
  templateUrl: './agents-details.component.html'
})
export class AgentsDetailsComponent extends DetailsBaseComponent implements OnInit {

  private agentsApi = this.api.agentsApi('', this.notifyDestruct$); // for intellisense
  private _definitionId: string;

  @Input()
  public set definitionId(t: string) {
    if (this._definitionId !== t) {
      this.agentsApi = this.api.agentsApi(t, this.notifyDestruct$);
      this._definitionId = t;
    }
  }

  public get definitionId(): string {
    return this._definitionId;
  }

  public expand = 'User,Rates/Resource,Rates/Unit,Rates/Currency';

  create = () => {
    const result: AgentForSave = {};
    if (this.ws.isPrimaryLanguage) {
      result.Name = this.initialText;
    } else if (this.ws.isSecondaryLanguage) {
      result.Name2 = this.initialText;
    } else if (this.ws.isTernaryLanguage) {
      result.Name3 = this.initialText;
    }
    result.IsRelated = false;
    result.Rates = [];

    // TODO Set defaults from definition

    return result;
  }

  clone = (item: Agent): Agent => {

    if (!!item) {
      const clone = JSON.parse(JSON.stringify(item)) as Agent;
      clone.Id = null;

      if (!!clone.Rates) {
        clone.Rates.forEach(e => {
          e.Id = null;
          delete e.AgentId;
        });
      }

      return clone;
    } else {
      // programmer mistake
      console.error('Cloning a non existing item');
      return null;
    }
  }

  constructor(
    private workspace: WorkspaceService, private api: ApiService,
    private translate: TranslateService, private route: ActivatedRoute) {
    super();
  }

  ngOnInit() {
    this.route.paramMap.subscribe((params: ParamMap) => {
      // This triggers changes on the screen

      if (this.isScreenMode) {

        const definitionId = params.get('definitionId');

        if (this.definitionId !== definitionId) {
          this.definitionId = definitionId;
        }
      }
    });
  }

  get view(): string {
    return `agents/${this.definitionId}`;
  }

  private get definition(): AgentDefinitionForClient {
    return !!this.definitionId ? this.ws.definitions.Agents[this.definitionId] : null;
  }

  // UI Bindings

  public get found(): boolean {
    return !!this.definition;
  }

  public onActivate = (model: Agent): void => {
    if (!!model && !!model.Id) {
      this.agentsApi.activate([model.Id], { returnEntities: true }).pipe(
        tap(res => addToWorkspace(res, this.workspace))
      ).subscribe({ error: this.details.handleActionError });
    }
  }

  public onDeactivate = (model: Agent): void => {
    if (!!model && !!model.Id) {
      this.agentsApi.deactivate([model.Id], { returnEntities: true }).pipe(
        tap(res => addToWorkspace(res, this.workspace))
      ).subscribe({ error: this.details.handleActionError });
    }
  }

  public showActivate = (model: Agent) => !!model && !model.IsActive;
  public showDeactivate = (model: Agent) => !!model && model.IsActive;

  public canActivateDeactivateItem = (model: Agent) => this.ws.canDo(this.view, 'IsActive', model.Id);

  public activateDeactivateTooltip = (model: Agent) => this.canActivateDeactivateItem(model) ? '' :
    this.translate.instant('Error_AccountDoesNotHaveSufficientPermissions')

  public get ws() {
    return this.workspace.currentTenant;
  }

  public get masterCrumb(): string {
    return this.ws.getMultilingualValueImmediate(this.definition, 'TitlePlural');
  }

  public get TaxIdentificationNumber_isVisible(): boolean {
    return !!this.definition.TaxIdentificationNumberVisibility;
  }

  public get TaxIdentificationNumber_isRequired(): boolean {
    return this.definition.TaxIdentificationNumberVisibility === 'Required';
  }

  public get StartDate_isVisible(): boolean {
    return !!this.definition.StartDateVisibility;
  }

  public get StartDate_isRequired(): boolean {
    return this.definition.StartDateVisibility === 'Required';
  }

  public get StartDate_label(): string {
    return !!this.definition.StartDateLabel ?
      this.ws.getMultilingualValueImmediate(this.definition, 'StartDateLabel') :
      this.translate.instant('Agent_StartDate');
  }

  public get Job_isVisible(): boolean {
    return !!this.definition.JobVisibility;
  }

  public get Job_isRequired(): boolean {
    return this.definition.JobVisibility === 'Required';
  }

  public get BankAccountNumber_isVisible(): boolean {
    return !!this.definition.BankAccountNumberVisibility;
  }

  public get BankAccountNumber_isRequired(): boolean {
    return this.definition.BankAccountNumberVisibility === 'Required';
  }

  public get Tabs_isVisible(): boolean {
    return this.Rates_isVisible; // More tabs may be added
  }

  public get Rates_isVisible(): boolean {
    return !!this.definition.RatesVisibility;
  }

  public get Rates_label(): string {
    return !!this.definition.RatesLabel ?
      this.ws.getMultilingualValueImmediate(this.definition, 'RatesLabel') :
      this.translate.instant('Agent_Rates');
  }

  public Rates_count(model: AgentForSave): number {
    return !!model && !!model.Rates ? model.Rates.length : 0;
  }

  public Rates_showError(model: AgentForSave): boolean {
    return !!model && !!model.Rates && model.Rates.some(e => !!e.serverErrors);
  }

  public Rate_minDecimalPlaces(line: AgentRateForSave): number {
    const curr = this.ws.get('Currency', line.CurrencyId) as Currency;
    return !!curr ? curr.E : this.ws.settings.FunctionalCurrencyDecimals;
  }

  public Rate_maxDecimalPlaces(line: AgentRateForSave): number {
    const curr = this.ws.get('Currency', line.CurrencyId) as Currency;
    return !!curr ? curr.E : this.ws.settings.FunctionalCurrencyDecimals;
  }

  public Rate_format(line: AgentRateForSave): string {
    return `1.${this.Rate_minDecimalPlaces(line)}-${this.Rate_maxDecimalPlaces(line)}`;
  }
}
