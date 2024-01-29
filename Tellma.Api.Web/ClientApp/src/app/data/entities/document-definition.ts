// tslint:disable:variable-name
// tslint:disable:max-line-length
import { EntityForSave } from './base/entity-for-save';
import { SettingsForClient } from '../dto/settings-for-client';
import { EntityDescriptor } from './base/metadata';
import { WorkspaceService } from '../workspace.service';
import { TranslateService } from '@ngx-translate/core';
import { EntityWithKey } from './base/entity-with-key';
import { DefinitionState, mainMenuSectionPropDescriptor, mainMenuIconPropDescriptor, mainMenuSortKeyPropDescriptor, visibilityPropDescriptor, statePropDescriptor, lookupDefinitionIdPropDescriptor, lookupDefinitionPropDescriptor } from './base/definition-common';
import { DefinitionVisibility as Visibility } from './base/definition-common';
import { DocumentDefinitionLineDefinitionForSave, DocumentDefinitionLineDefinition } from './document-definition-line-definition';
import { TimeGranularity } from './base/metadata-types';
export interface DocumentDefinitionForSave<TLineDefinition = DocumentDefinitionLineDefinitionForSave> extends EntityForSave {
    Code?: string;
    IsOriginalDocument?: boolean;
    Description?: string;
    Description2?: string;
    Description3?: string;
    TitleSingular?: string;
    TitleSingular2?: string;
    TitleSingular3?: string;
    TitlePlural?: string;
    TitlePlural2?: string;
    TitlePlural3?: string;

    Prefix?: string;
    CodeWidth?: number;

    PostingDateVisibility?: Visibility;
    CenterVisibility?: Visibility;

    Lookup1Label?: string;
    Lookup1Label2?: string;
    Lookup1Label3?: string;
    Lookup1Visibility?: Visibility;
    Lookup1DefinitionId?: number;
    Lookup2Label?: string;
    Lookup2Label2?: string;
    Lookup2Label3?: string;
    Lookup2Visibility?: Visibility;
    Lookup2DefinitionId?: number;

    ZatcaDocumentType?: string;

    ClearanceVisibility?: Visibility;
    MemoVisibility?: Visibility;
    AttachmentVisibility?: Visibility;
    HasBookkeeping?: boolean;

    CloseValidateScript?: string;

    // Main Menu

    MainMenuIcon?: string;
    MainMenuSection?: string;
    MainMenuSortKey?: number;

    LineDefinitions?: TLineDefinition[];
}

export interface DocumentDefinition extends DocumentDefinitionForSave<DocumentDefinitionLineDefinition> {
    State?: DefinitionState;
    SavedById?: number | string;
    SavedAt?: string;
}

const _select = ['', '2', '3'].map(pf => 'TitleSingular' + pf);
let _settings: SettingsForClient;
let _cache: EntityDescriptor = null;

export function metadata_DocumentDefinition(wss: WorkspaceService, trx: TranslateService): EntityDescriptor {
    const ws = wss.currentTenant;
    // Some global values affect the result, we check here if they have changed, otherwise we return the cached result
    if (ws.settings !== _settings) {
        _settings = ws.settings;

        // clear the cache
        _cache = null;
    }

    if (!_cache) {
        _settings = ws.settings;
        const entityDesc: EntityDescriptor = {
            collection: 'DocumentDefinition',
            titleSingular: () => trx.instant('DocumentDefinition'),
            titlePlural: () => trx.instant('DocumentDefinitions'),
            select: _select,
            apiEndpoint: 'document-definitions',
            masterScreenUrl: 'document-definitions',
            orderby: () => ws.isSecondaryLanguage ? [_select[1], _select[0]] :
                ws.isTernaryLanguage ? [_select[2], _select[0]] : [_select[0]],
            inactiveFilter: null, // TODO
            format: (item: EntityWithKey) => ws.getMultilingualValueImmediate(item, _select[0]),
            formatFromVals: (vals: any[]) => ws.localize(vals[0], vals[1], vals[2]),
            properties: {
                Id: { noSeparator: true, datatype: 'numeric', control: 'number', label: () => trx.instant('Id'), minDecimalPlaces: 0, maxDecimalPlaces: 0 },
                Code: { datatype: 'string', control: 'text', label: () => trx.instant('Code') },
                IsOriginalDocument: { datatype: 'bit', control: 'check', label: () => trx.instant('DocumentDefinition_IsOriginalDocument') },
                Description: { datatype: 'string', control: 'text', label: () => trx.instant('Description') + ws.primaryPostfix },
                Description2: { datatype: 'string', control: 'text', label: () => trx.instant('Description') + ws.secondaryPostfix },
                Description3: { datatype: 'string', control: 'text', label: () => trx.instant('Description') + ws.ternaryPostfix },
                TitleSingular: { datatype: 'string', control: 'text', label: () => trx.instant('TitleSingular') + ws.primaryPostfix },
                TitleSingular2: { datatype: 'string', control: 'text', label: () => trx.instant('TitleSingular') + ws.secondaryPostfix },
                TitleSingular3: { datatype: 'string', control: 'text', label: () => trx.instant('TitleSingular') + ws.ternaryPostfix },
                TitlePlural: { datatype: 'string', control: 'text', label: () => trx.instant('TitlePlural') + ws.primaryPostfix },
                TitlePlural2: { datatype: 'string', control: 'text', label: () => trx.instant('TitlePlural') + ws.secondaryPostfix },
                TitlePlural3: { datatype: 'string', control: 'text', label: () => trx.instant('TitlePlural') + ws.ternaryPostfix },

                Prefix: { datatype: 'string', control: 'text', label: () => trx.instant('DocumentDefinition_Prefix') },
                CodeWidth: { datatype: 'numeric', control: 'number', label: () => trx.instant('DocumentDefinition_CodeWidth'), minDecimalPlaces: 0, maxDecimalPlaces: 0, noSeparator: false },

                PostingDateVisibility: visibilityPropDescriptor('Document_PostingDate', trx),
                CenterVisibility: visibilityPropDescriptor('Document_Center', trx),
                Lookup1Label: { datatype: 'string', control: 'text', label: () => trx.instant('Field0Label', { 0: trx.instant('Entity_Lookup1') }) + ws.primaryPostfix },
                Lookup1Label2: { datatype: 'string', control: 'text', label: () => trx.instant('Field0Label', { 0: trx.instant('Entity_Lookup1') }) + ws.secondaryPostfix },
                Lookup1Label3: { datatype: 'string', control: 'text', label: () => trx.instant('Field0Label', { 0: trx.instant('Entity_Lookup1') }) + ws.ternaryPostfix },
                Lookup1Visibility: visibilityPropDescriptor('Entity_Lookup1', trx),
                Lookup1DefinitionId: lookupDefinitionIdPropDescriptor('Entity_Lookup1', trx),
                Lookup1Definition: lookupDefinitionPropDescriptor('Entity_Lookup1', 'Lookup1DefinitionId', trx),
                Lookup2Label: { datatype: 'string', control: 'text', label: () => trx.instant('Field0Label', { 0: trx.instant('Entity_Lookup2') }) + ws.primaryPostfix },
                Lookup2Label2: { datatype: 'string', control: 'text', label: () => trx.instant('Field0Label', { 0: trx.instant('Entity_Lookup2') }) + ws.secondaryPostfix },
                Lookup2Label3: { datatype: 'string', control: 'text', label: () => trx.instant('Field0Label', { 0: trx.instant('Entity_Lookup2') }) + ws.ternaryPostfix },
                Lookup2Visibility: visibilityPropDescriptor('Entity_Lookup2', trx),
                Lookup2DefinitionId: lookupDefinitionIdPropDescriptor('Entity_Lookup2', trx),
                Lookup2Definition: lookupDefinitionPropDescriptor('Entity_Lookup2', 'Lookup2DefinitionId', trx),

                ZatcaDocumentType: { 
                    datatype: 'string', 
                    control: 'choice', 
                    label: () => trx.instant('DocumentDefinition_ZatcaDocumentType'),
                    choices: ['381', '383', '388', '386'],
                    format: (choice: number) => !!choice ? trx.instant('DocumentDefinition_ZatcaDocumentType_' + choice) : '' 
                },
                
                ClearanceVisibility: visibilityPropDescriptor('Document_Clearance', trx),
                MemoVisibility: visibilityPropDescriptor('Memo', trx),
                AttachmentVisibility: visibilityPropDescriptor('Document_Attachments', trx),
                HasBookkeeping: { datatype: 'bit', control: 'check', label: () => trx.instant('DocumentDefinition_HasBookkeeping') },

                CloseValidateScript: { datatype: 'string', control: 'text', label: () => trx.instant('DocumentDefinition_CloseValidateScript') },

                State: statePropDescriptor(trx),
                MainMenuSection: mainMenuSectionPropDescriptor(trx),
                MainMenuIcon: mainMenuIconPropDescriptor(trx),
                MainMenuSortKey: mainMenuSortKeyPropDescriptor(trx),

                // IsActive & Audit info
                SavedById: { noSeparator: true, datatype: 'numeric', control: 'number', label: () => `${trx.instant('ModifiedBy')} (${trx.instant('Id')})`, minDecimalPlaces: 0, maxDecimalPlaces: 0 },
                SavedBy: { datatype: 'entity', control: 'User', label: () => trx.instant('ModifiedBy'), foreignKeyName: 'SavedById' },
                SavedAt: { datatype: 'datetimeoffset', control: 'datetime', label: () => trx.instant('ModifiedAt'), granularity: TimeGranularity.minutes },
            }
        };

        // Remove multi-lingual properties if the tenant doesn't define the language
        const multiLangProps = ['TitleSingular', 'TitlePlural', 'Description'];

        for (const prop of multiLangProps) {
            if (!ws.settings.SecondaryLanguageId) {
                delete entityDesc.properties[prop + '2'];
            }
            if (!ws.settings.TernaryLanguageId) {
                delete entityDesc.properties[prop + '3'];
            }
        }

        _cache = entityDesc;
    }

    return _cache;
}
