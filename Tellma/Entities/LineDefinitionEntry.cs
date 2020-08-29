﻿using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Tellma.Entities
{
    [EntityDisplay(Singular = "LineDefinitionEntry", Plural = "LineDefinitionEntries")]
    public class LineDefinitionEntryForSave<TCustodyDef, TResourceDef> : EntityWithKey<int>
    {
        [Display(Name = "LineDefinitionEntry_Direction")]
        [ChoiceList(new object[] { (short)1, (short)-1 }, new string[] { "Entry_Direction_Debit", "Entry_Direction_Credit" })]
        [Required]
        public short? Direction { get; set; }

        [Display(Name = "LineDefinitionEntry_ParentAccountType")]
        [Required]
        public int? ParentAccountTypeId { get; set; }

        [Display(Name = "LineDefinitionEntry_EntryType")]
        public int? EntryTypeId { get; set; }

        [Display(Name = "LineDefinitionEntry_CustodyDefinitions")]
        [ForeignKey(nameof(LineDefinitionEntryCustodyDefinition.LineDefinitionEntryId))]
        public List<TCustodyDef> CustodyDefinitions { get; set; }

        [Display(Name = "LineDefinitionEntry_ResourceDefinitions")]
        [ForeignKey(nameof(LineDefinitionEntryResourceDefinition.LineDefinitionEntryId))]
        public List<TResourceDef> ResourceDefinitions { get; set; }
    }

    public class LineDefinitionEntryForSave : LineDefinitionEntryForSave<LineDefinitionEntryCustodyDefinitionForSave, LineDefinitionEntryResourceDefinitionForSave>
    {
    }

    public class LineDefinitionEntry : LineDefinitionEntryForSave<LineDefinitionEntryCustodyDefinition, LineDefinitionEntryResourceDefinition>
    {
        [AlwaysAccessible]
        public int? Index { get; set; }

        [Display(Name = "LineDefinitionEntry_LineDefinition")]
        public int? LineDefinitionId { get; set; }

        [Display(Name = "ModifiedBy")]
        public int? SavedById { get; set; }

        // For Query

        [Display(Name = "LineDefinitionEntry_ParentAccountType")]
        [ForeignKey(nameof(ParentAccountTypeId))]
        public AccountType ParentAccountType { get; set; }

        [Display(Name = "LineDefinitionEntry_EntryType")]
        [ForeignKey(nameof(EntryTypeId))]
        public EntryType EntryType { get; set; }

        [Display(Name = "ModifiedBy")]
        [ForeignKey(nameof(SavedById))]
        public User SavedBy { get; set; }
    }
}
