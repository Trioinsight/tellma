// tslint:disable:variable-name
import { EntityForSave } from './base/entity-for-save';
import { SettingsForClient } from '../dto/settings-for-client';
import { EntityDescriptor } from './base/metadata';
import { WorkspaceService } from '../workspace.service';
import { TranslateService } from '@ngx-translate/core';
import { EntityWithKey } from './base/entity-with-key';

export interface EntryTypeForSave extends EntityForSave {
  ParentId?: number;
  Name?: string;
  Name2?: string;
  Name3?: string;
  Description?: string;
  Description2?: string;
  Description3?: string;
  Code?: string;
  EntryDefinitionId?: string;
  IsAssignable?: boolean;
}

export interface EntryType extends EntryTypeForSave {
  Level?: number;
  ActiveChildCount?: number;
  ChildCount?: number;
  IsSystem?: boolean;
  IsActive?: boolean;
  CreatedAt?: string;
  CreatedById?: number | string;
  ModifiedAt?: string;
  ModifiedById?: number | string;
}

const _select = ['', '2', '3'].map(pf => 'Name' + pf);
let _settings: SettingsForClient;
let _cache: EntityDescriptor;

export function metadata_EntryType(wss: WorkspaceService, trx: TranslateService): EntityDescriptor {
  const ws = wss.currentTenant;
  // Some global values affect the result, we check here if they have changed, otherwise we return the cached result
  if (ws.settings !== _settings) {
    _settings = ws.settings;

    // clear the cache
    _cache = null;
  }

  if (!_cache) {

    const entityDesc: EntityDescriptor = {
      collection: 'Unit',
      titleSingular: () => trx.instant('EntryType'),
      titlePlural: () => trx.instant('EntryTypes'),
      select: _select,
      apiEndpoint: 'entry-types',
      masterScreenUrl: 'entry-types',
      orderby: () => ws.isSecondaryLanguage ? [_select[1], _select[0]] : ws.isTernaryLanguage ? [_select[2], _select[0]] : [_select[0]],
      inactiveFilter: 'IsActive eq true',
      format: (item: EntityWithKey) => ws.getMultilingualValueImmediate(item, _select[0]),
      properties: {

        Id: { control: 'number', label: () => trx.instant('Id'), minDecimalPlaces: 0, maxDecimalPlaces: 0 },
        Name: { control: 'text', label: () => trx.instant('Name') + ws.primaryPostfix },
        Name2: { control: 'text', label: () => trx.instant('Name') + ws.secondaryPostfix },
        Name3: { control: 'text', label: () => trx.instant('Name') + ws.ternaryPostfix },
        Description: { control: 'text', label: () => trx.instant('Description') + ws.primaryPostfix },
        Description2: { control: 'text', label: () => trx.instant('Description') + ws.secondaryPostfix },
        Description3: { control: 'text', label: () => trx.instant('Description') + ws.ternaryPostfix },
        Code: { control: 'text', label: () => trx.instant('Code') },
        IsAssignable: { control: 'boolean', label: () => trx.instant('IsAssignable') },

        // tree stuff
        ParentId: {
          control: 'number', label: () => `${trx.instant('TreeParent')} (${trx.instant('Id')})`,
          minDecimalPlaces: 0, maxDecimalPlaces: 0
        },
        Parent: {
          control: 'navigation', label: () => trx.instant('TreeParent'), type: 'EntryType',
          foreignKeyName: 'ParentId'
        },
        ChildCount: {
          control: 'number', label: () => trx.instant('TreeChildCount'), minDecimalPlaces: 0, maxDecimalPlaces: 0,
          alignment: 'right'
        },
        ActiveChildCount: {
          control: 'number', label: () => trx.instant('TreeActiveChildCount'), minDecimalPlaces: 0,
          maxDecimalPlaces: 0, alignment: 'right'
        },
        Level: {
          control: 'number', label: () => trx.instant('TreeLevel'), minDecimalPlaces: 0, maxDecimalPlaces: 0,
          alignment: 'right'
        },

        IsSystem: { control: 'boolean', label: () => trx.instant('IsSystem') },
        IsActive: { control: 'boolean', label: () => trx.instant('IsActive') },
        CreatedAt: { control: 'datetime', label: () => trx.instant('CreatedAt') },
        CreatedBy: { control: 'navigation', label: () => trx.instant('CreatedBy'), type: 'User', foreignKeyName: 'CreatedById' },
        ModifiedAt: { control: 'datetime', label: () => trx.instant('ModifiedAt') },
        ModifiedBy: { control: 'navigation', label: () => trx.instant('ModifiedBy'), type: 'User', foreignKeyName: 'ModifiedById' }
      }
    };

    if (!ws.settings.SecondaryLanguageId) {
      delete entityDesc.properties.Name2;
      delete entityDesc.properties.Description2;
    }

    if (!ws.settings.TernaryLanguageId) {
      delete entityDesc.properties.Name3;
      delete entityDesc.properties.Description3;
    }

    _cache = entityDesc;
  }

  return _cache;
}
