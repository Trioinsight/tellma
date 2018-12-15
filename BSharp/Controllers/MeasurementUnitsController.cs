﻿using AutoMapper;
using BSharp.Controllers.DTO;
using BSharp.Controllers.Misc;
using BSharp.Data;
using BSharp.Services.ImportExport;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using M = BSharp.Data.Model;

namespace BSharp.Controllers
{
    [Route("api/measurement-units")]
    public class MeasurementUnitsController : CrudControllerBase<M.MeasurementUnit, MeasurementUnit, MeasurementUnitForSave, int?>
    {
        private readonly ApplicationContext _db;
        private readonly IModelMetadataProvider _metadataProvider;
        private readonly ILogger<MeasurementUnitsController> _logger;
        private readonly IStringLocalizer<MeasurementUnitsController> _localizer;
        private readonly IMapper _mapper;

        public MeasurementUnitsController(ApplicationContext db, IModelMetadataProvider metadataProvider, ILogger<MeasurementUnitsController> logger,
            IStringLocalizer<MeasurementUnitsController> localizer, IMapper mapper) : base(logger, localizer, mapper)
        {
            _db = db;
            _metadataProvider = metadataProvider;
            _logger = logger;
            _localizer = localizer;
            _mapper = mapper;
        }

        [HttpPut("activate")]
        public async Task<ActionResult<List<MeasurementUnit>>> Activate([FromBody] List<int> ids, bool returnEntities = true)
        {
            return await ActivateDeactivate(ids, returnEntities, isActive: true);
        }

        [HttpPut("deactivate")]
        public async Task<ActionResult<List<MeasurementUnit>>> Deactivate([FromBody] List<int> ids, bool returnEntities = true)
        {
            return await ActivateDeactivate(ids, returnEntities, isActive: false);
        }

        private async Task<ActionResult<List<MeasurementUnit>>> ActivateDeactivate([FromBody] List<int> ids, bool returnEntities, bool isActive)
        {
            try
            {
                // TODO Authorize Activate

                // TODO Validate (No used units, no duplicate Ids, no missing Ids?)

                var isActiveParam = new SqlParameter("@IsActive", isActive);

                DataTable idsTable = DataTable(ids.Select(id => new { Id = id }), addIndex: false);
                var idsTvp = new SqlParameter("@Ids", idsTable)
                {
                    TypeName = $"dbo.IdList",
                    SqlDbType = SqlDbType.Structured
                };

                string sql = @"
DECLARE @Now DATETIMEOFFSET(7) = SYSDATETIMEOFFSET();
DECLARE @UserId NVARCHAR(450) = CONVERT(NVARCHAR(450), SESSION_CONTEXT(N'UserId'));

MERGE INTO [dbo].MeasurementUnits AS t
	USING (
		SELECT [Id]
		FROM @Ids
	) AS s ON (t.Id = s.Id)
	WHEN MATCHED AND (t.IsActive <> @IsActive)
	THEN
		UPDATE SET 
			t.[IsActive]	= @IsActive,
			t.[ModifiedAt]	= @Now,
			t.[ModifiedBy]	= @UserId;
";

                // Update the entities
                await _db.Database.ExecuteSqlCommandAsync(sql, idsTvp, isActiveParam);

                // Determine whether entities should be returned
                if (!returnEntities)
                {
                    // IF no returned items are expected, simply return 200 OK
                    return Ok();
                }
                else
                {
                    // Load the entities using their Ids
                    var affectedDbEntities = await _db.MeasurementUnits.FromSql("SELECT * FROM dbo.[MeasurementUnits] WHERE Id IN (SELECT Id FROM @Ids)", idsTvp).ToListAsync();
                    var affectedEntities = _mapper.Map<List<MeasurementUnit>>(affectedDbEntities);

                    // sort the entities the way their Ids came, as a good practice
                    MeasurementUnit[] sortedAffectedEntities = new MeasurementUnit[ids.Count];
                    Dictionary<int, MeasurementUnit> affectedEntitiesDic = affectedEntities.ToDictionary(e => e.Id.Value);

                    for (int i = 0; i < ids.Count; i++)
                    {
                        var id = ids[i];
                        MeasurementUnit entity = null;
                        if (affectedEntitiesDic.ContainsKey(id))
                        {
                            entity = affectedEntitiesDic[id];
                        }

                        sortedAffectedEntities[i] = entity;
                    }

                    return Ok(sortedAffectedEntities);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message} {ex.StackTrace}");
                return BadRequest(ex.Message);
            }
        }

        protected override IQueryable<M.MeasurementUnit> GetBaseQuery()
        {
            return _db.MeasurementUnits.Where(e => e.UnitType != "Currency");
        }

        protected override IQueryable<M.MeasurementUnit> Search(IQueryable<M.MeasurementUnit> query, string search)
        {
            if (!string.IsNullOrWhiteSpace(search))
            {
                query = query.Where(e => e.Name1.Contains(search) || e.Name2.Contains(search) || e.Code.Contains(search)); // Custom
            }

            return query;
        }

        protected override IQueryable<M.MeasurementUnit> SingletonQuery(IQueryable<M.MeasurementUnit> query, int? id)
        {
            return query.Where(e => e.Id == id);
        }

        protected override IQueryable<M.MeasurementUnit> IncludeInactive(IQueryable<M.MeasurementUnit> query, bool includeInactive)
        {
            if (!includeInactive)
            {
                query = query.Where(e => e.IsActive);
            }

            return query;
        }

        protected override async Task ValidateAsync(List<MeasurementUnitForSave> entities)
        {
            // Hash the indices for performance
            var indices = new Dictionary<MeasurementUnitForSave, int>();
            int i = 0;
            foreach (var entity in entities)
            {
                indices[entity] = i++;
            }


            // Check that Ids make sense in relation to EntityState, and that no entity is DELETED
            // All these errors indicate a bug
            foreach (var entity in entities)
            {
                if (entity.EntityState == EntityStates.Deleted)
                {
                    // Won't be supported for this API
                    var index = indices[entity];
                    ModelState.AddModelError($"[{index}].{nameof(entity.EntityState)}", _localizer["Error_Deleting0IsNotSupportedFromThisAPI", _localizer["MeasurementUnits"]]);
                }

                if (entity.Id == null && entity.EntityState != EntityStates.Inserted)
                {
                    // This error indicates a bug
                    var index = indices[entity];
                    ModelState.AddModelError($"[{index}].{nameof(entity.Id)}", _localizer["Error_CannotInsert0WhileSpecifyId", _localizer["MeasurementUnit"]]);
                }

                if (entity.Id != null && entity.EntityState == EntityStates.Updated)
                {
                    // This error indicates a bug
                    var index = indices[entity];
                    ModelState.AddModelError($"[{index}].{nameof(entity.Id)}", _localizer["Error_CannotUpdate0WithoutId", _localizer["MeasurementUnit"]]);
                }
            }

            // Check that Ids are unique
            var duplicateIds = entities.Where(e => e.Id != null).GroupBy(e => e.Id.Value).Where(g => g.Count() > 1);
            foreach (var groupWithDuplicateIds in duplicateIds)
            {
                foreach (var entity in groupWithDuplicateIds)
                {
                    // This error indicates a bug
                    var index = indices[entity];
                    ModelState.AddModelError($"[{index}].{nameof(entity.Id)}", _localizer["Error_TheEntityWithId0IsSpecifiedMoreThanOnce", entity.Id]);
                }
            }


            // Detect if the incoming collection has any duplicate codes
            var duplicateCodes = entities.GroupBy(e => e.Code).Where(g => g.Count() > 1);
            foreach (var groupWithDuplicateCodes in duplicateCodes)
            {
                foreach (var entity in groupWithDuplicateCodes)
                {
                    var index = indices[entity];
                    ModelState.AddModelError($"[{index}].{nameof(entity.Code)}", _localizer["Error_TheCode0IsDuplicated", entity.Code]);
                }
            }

            // No need to invoke SQL if the model state is full of errors
            if (ModelState.HasReachedMaxErrors)
            {
                return;
            }

            // Perform SQL-side validation
            DataTable entitiesTable = DataTable(entities, addIndex: true);
            var entitiesTvp = new SqlParameter("Entities", entitiesTable) { TypeName = $"dbo.{nameof(MeasurementUnitForSave)}List", SqlDbType = SqlDbType.Structured };
            int remainingErrorCount = ModelState.MaxAllowedErrors - ModelState.ErrorCount;

            // (1) Code must be unique
            var sqlErrors = await _db.Validation.FromSql($@"
SET NOCOUNT ON;
DECLARE @ValidationErrors dbo.ValidationErrorList;
	-- Code must be unique
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument1], [Argument2], [Argument3], [Argument4], [Argument5]) 
	SELECT '[' + CAST(FE.[Index] AS NVARCHAR(255)) + '].Code' As [Key], N'Error_TheCode0IsUsed' As [ErrorName],
		FE.Code AS Argument1, NULL AS Argument2, NULL AS Argument3, NULL AS Argument4, NULL AS Argument5
	FROM @Entities FE 
	JOIN [dbo].MeasurementUnits BE ON FE.Code = BE.Code
	WHERE (FE.[EntityState] = N'Inserted') OR (FE.Id <> BE.Id);

	-- Code must not be duplicated in the uploaded list
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument1], [Argument2], [Argument3], [Argument4], [Argument5]) 
	SELECT '[' + CAST([Index] AS NVARCHAR(255)) + '].Code' As [Key], N'TheCode0IsUsedInTheList' As [ErrorName],
		[Code] AS Argument1, NULL AS Argument2, NULL AS Argument3, NULL AS Argument4, NULL AS Argument5
	FROM @Entities
	WHERE [Code] IN (
		SELECT [Code]
		FROM @Entities
		GROUP BY [Code]
		HAVING COUNT(*) > 1
	)

	-- Name must not exist in the 
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument1], [Argument2], [Argument3], [Argument4], [Argument5]) 
	SELECT '[' + CAST(FE.[Index] AS NVARCHAR(255)) + '].Name' As [Key], N'TheName{{0}}IsUsed' As [ErrorName],
		FE.[Name] AS Argument1, NULL AS Argument2, NULL AS Argument3, NULL AS Argument4, NULL AS Argument5
	FROM @Entities FE 
	JOIN [dbo].MeasurementUnits BE ON FE.[Name] = BE.[Name]
	WHERE (FE.[EntityState] = N'Inserted') OR (FE.Id <> BE.Id);

	-- Name must be unique in the uploaded list
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument1], [Argument2], [Argument3], [Argument4], [Argument5]) 
	SELECT '[' + CAST(FE.[Index] AS NVARCHAR(255)) + '].Name' As [Key], N'TheName0IsUsedInTheList' As [ErrorName],
		[Name] AS Argument1, NULL AS Argument2, NULL AS Argument3, NULL AS Argument4, NULL AS Argument5
	FROM @Entities
	WHERE [Name] IN (
		SELECT [Name]
		FROM @Entities
		GROUP BY [Code]
		HAVING COUNT(*) > 1
	)
		-- Add further logic

SELECT TOP {remainingErrorCount} * FROM @ValidationErrors;
", entitiesTvp).ToListAsync();

            // Local function for intelligently parsing strings into objects
            object Parse(string str)
            {
                if (string.IsNullOrWhiteSpace(str))
                {
                    return str;
                }

                if (DateTime.TryParse(str, out DateTime dResult))
                {
                    return dResult;
                }

                return str;
            }

            // Loop over the errors returned from SQL and add them to ModelState
            foreach (var sqlError in sqlErrors)
            {
                object[] formatArguments = {
                    Parse(sqlError.Argument1),
                    Parse(sqlError.Argument2),
                    Parse(sqlError.Argument3),
                    Parse(sqlError.Argument4),
                    Parse(sqlError.Argument5),
                };

                string key = sqlError.Key;
                string errorMessage = _localizer[sqlError.ErrorName, formatArguments];

                ModelState.AddModelError(key: key, errorMessage: errorMessage);
            }
        }

        protected override async Task<List<M.MeasurementUnit>> PersistAsync(List<MeasurementUnitForSave> entities, bool returnEntities)
        {
            // Add created entities
            DataTable entitiesTable = DataTable(entities, addIndex: true);
            var entitiesTvp = new SqlParameter("Entities", entitiesTable)
            {
                TypeName = $"dbo.{nameof(MeasurementUnitForSave)}List",
                SqlDbType = SqlDbType.Structured
            };

            string saveSql = $@"
-- Procedure: MeasurementUnitsSave
SET NOCOUNT ON;
	DECLARE @IndexedIds [dbo].[IndexedIdList];
	DECLARE @TenantId int = CONVERT(INT, SESSION_CONTEXT(N'TenantId'));
	DECLARE @Now DATETIMEOFFSET(7) = SYSDATETIMEOFFSET();
	DECLARE @UserId NVARCHAR(450) = CONVERT(NVARCHAR(450), SESSION_CONTEXT(N'UserId'));

	INSERT INTO @IndexedIds([Index], [Id])
	SELECT x.[Index], x.[Id]
	FROM
	(
		MERGE INTO [dbo].MeasurementUnits AS t
		USING (
			SELECT [Index], [Id], [Code], [UnitType], [Name1], [Name2], [UnitAmount], [BaseAmount]
			FROM @Entities 
			WHERE [EntityState] IN (N'Inserted', N'Updated')
		) AS s ON (t.Id = s.Id)
		WHEN MATCHED 
		THEN
			UPDATE SET 
				t.[UnitType]	= s.[UnitType],
				t.[Name1]		= s.[Name1],
				t.[Name2]		= s.[Name2],
				t.[UnitAmount]	= s.[UnitAmount],
				t.[BaseAmount]	= s.[BaseAmount],
				t.[Code]		= s.[Code],
				t.[ModifiedAt]	= @Now,
				t.[ModifiedBy]	= @UserId
		WHEN NOT MATCHED THEN
				INSERT ([TenantId], [UnitType], [Name1], [Name2], [UnitAmount], [BaseAmount], [Code], [CreatedAt], [CreatedBy], [ModifiedAt], [ModifiedBy])
				VALUES (@TenantId, s.[UnitType], s.[Name1], s.[Name2], s.[UnitAmount], s.[BaseAmount], s.[Code], @Now, @UserId, @Now, @UserId)
			OUTPUT s.[Index], inserted.[Id] 
	) As x
";
            // Optimization
            if (!returnEntities)
            {
                // IF no returned items are expected, simply execute a non-Query and return an empty list;
                await _db.Database.ExecuteSqlCommandAsync(saveSql, entitiesTvp);
                return new List<M.MeasurementUnit>();
            }
            else
            {
                // If returned items are expected, append a select statement to the SQL command
                saveSql = saveSql += "SELECT * FROM @IndexedIds;";

                // Retrieve the map from Indexes to Ids
                var indexedIds = await _db.Saving.FromSql(saveSql, entitiesTvp).ToListAsync();

                // Load the entities using their Ids
                DataTable idsTable = DataTable(indexedIds.Select(e => new { e.Id }), addIndex: false);
                var idsTvp = new SqlParameter("Ids", idsTable)
                {
                    TypeName = $"dbo.IdList",
                    SqlDbType = SqlDbType.Structured
                };
                var savedEntities = await _db.MeasurementUnits.FromSql("SELECT * FROM dbo.[MeasurementUnits] WHERE Id IN (SELECT Id FROM @Ids)", idsTvp).ToListAsync();


                // SQL Server does not guarantee order, so make sure the result is sorted according to the initial index
                Dictionary<int, int> indices = indexedIds.ToDictionary(e => e.Id, e => e.Index);
                var sortedSavedEntities = new M.MeasurementUnit[savedEntities.Count];
                foreach (var item in savedEntities)
                {
                    int index = indices[item.Id];
                    sortedSavedEntities[index] = item;
                }

                // Return the sorted collection
                return sortedSavedEntities.ToList();
            }
        }

        protected override async Task DeleteImplAsync(List<int?> ids)
        {
            // Prepare a list of Ids to delete
            DataTable idsTable = DataTable(ids.Select(e => new { Id = e }), addIndex: false);
            var idsTvp = new SqlParameter("Ids", idsTable)
            {
                TypeName = $"dbo.IdList",
                SqlDbType = SqlDbType.Structured
            };

            try
            {
                // Delete efficiently with a SQL query
                await _db.Database.ExecuteSqlCommandAsync("DELETE FROM dbo.[MeasurementUnits] WHERE Id IN (SELECT Id FROM @Ids)", idsTvp);
            }
            catch (SqlException ex) when (IsForeignKeyViolation(ex))
            {
                throw new BadRequestException(_localizer["Error_CannotDelete0AlreadyInUse", _localizer["MeasurementUnit"]]);
            }
        }

        protected override async Task<(List<MeasurementUnitForSave>, Func<string, int?>)> ToDtosForSave(AbstractDataGrid grid, ParseArguments args)
        {
            // Get the properties of the DTO for Save, excluding Id or EntityState
            string mode = args.Mode;
            var readType = typeof(MeasurementUnit);
            var saveType = typeof(MeasurementUnitForSave);

            var readProps = readType.GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly)
                .ToDictionary(prop => _metadataProvider.GetMetadataForProperty(readType, prop.Name)?.DisplayName ?? prop.Name, StringComparer.InvariantCultureIgnoreCase);

            var saveProps = saveType.GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly)
                .ToDictionary(prop => _metadataProvider.GetMetadataForProperty(saveType, prop.Name)?.DisplayName ?? prop.Name, StringComparer.InvariantCultureIgnoreCase);

            // Maps the index of the grid column to a property on the DtoForSave
            var saveColumnMap = new List<(int Index, PropertyInfo Property)>(grid.RowSize);

            // Make sure all column header labels are recognizable
            // and construct the save column map
            var firstRow = grid[0];
            for (int c = 0; c < firstRow.Length; c++)
            {
                var column = firstRow[c];
                string headerLabel = column.Content?.ToString();

                if (saveProps.ContainsKey(headerLabel))
                {
                    var prop = saveProps[headerLabel];
                    saveColumnMap.Add((c, prop));
                }
                else if (readProps.ContainsKey(headerLabel))
                {
                    // All good, just ignore
                }
                else
                {
                    AddRowError(1, _localizer["Error_Column0NotRecognizable", headerLabel]);
                }
            }

            // Milestone 1: columns in the abstract grid mapped
            if (!ModelState.IsValid)
            {
                throw new UnprocessableEntityException(ModelState);
            }

            // Construct the result using the map generated earlier
            List<MeasurementUnitForSave> result = new List<MeasurementUnitForSave>(grid.Count - 1);
            for (int i = 1; i < grid.Count; i++) // Skip the header
            {
                var row = grid[i];
                var entity = new MeasurementUnitForSave();
                foreach (var (index, prop) in saveColumnMap)
                {
                    var content = row[index].Content;


                    // Special handling for choice lists
                    if (content != null)
                    {
                        var choiceListAttr = prop.GetCustomAttribute<ChoiceListAttribute>();
                        if (choiceListAttr != null)
                        {
                            List<string> displayNames = choiceListAttr.DisplayNames.Select(e => _localizer[e].Value).ToList();
                            string stringContent = content.ToString();
                            var displayNameIndex = displayNames.IndexOf(stringContent);
                            if (displayNameIndex == -1)
                            {
                                var propName = _metadataProvider.GetMetadataForProperty(readType, prop.Name).DisplayName;
                                string seperator = _localizer[","];
                                AddRowError(i + 2, _localizer["Error_Value0IsNotValidFor1AcceptableValuesAre2", stringContent, propName, string.Join(seperator, displayNames)]);
                            }
                            else
                            {
                                content = choiceListAttr.Choices[displayNameIndex];
                            }
                        }
                    }

                    prop.SetValue(entity, content); // TODO casting here to be done
                }

                result.Add(entity);
            }

            // Milestone 2: DTOs created
            if (!ModelState.IsValid)
            {
                throw new UnprocessableEntityException(ModelState);
            }

            // For each entity, set the Id and EntityState depending on import mode
            if (mode == "Insert")
            {
                // For Insert mode, all are marked inserted and all Ids are null
                // Any duplicate codes will be handled later in the validation
                result.ForEach(e => e.Id = null);
                result.ForEach(e => e.EntityState = "Inserted");
            }
            else
            {
                // For all other modes besides Insert, we need to match the entity codes to Ids by querying the DB
                // Load the code Ids from the database
                var nonNullCodes = result.Where(e => !string.IsNullOrWhiteSpace(e.Code));
                var codesDataTable = DataTable(nonNullCodes.Select(e => new { e.Code }));
                var entitiesTvp = new SqlParameter("@Codes", codesDataTable)
                {
                    TypeName = $"dbo.CodeList",
                    SqlDbType = SqlDbType.Structured
                };

                string sql = $@"SELECT c.Code, e.Id FROM @Codes c JOIN [dbo].[MeasurementUnits] e on c.Code = e.Code;";
                var idCodesDic = await _db.CodeIds.FromSql(sql, entitiesTvp).ToDictionaryAsync(e => e.Code, e => e.Id);

                result.ForEach(e =>
                {
                    if (!string.IsNullOrWhiteSpace(e.Code) && idCodesDic.ContainsKey(e.Code))
                    {
                        e.Id = idCodesDic[e.Code];
                    }
                    else
                    {
                        e.Id = null;
                    }
                });

                if (mode == "Merge")
                {
                    // Merge simply inserts codes that are not found, and updates codes that are found
                    result.ForEach(e =>
                    {
                        if (e.Id != null)
                        {
                            e.EntityState = "Updated";
                        }
                        else
                        {
                            e.EntityState = "Inserted";
                        }
                    });
                }
                else
                {
                    // In the case of update and delete: codes are required, and MUST match database Ids
                    for (int index = 0; index < result.Count; index++)
                    {
                        var entity = result[index];
                        if (string.IsNullOrWhiteSpace(entity.Code))
                        {
                            AddRowError(index + 2, _localizer["Error_CodeIsRequiredForImportModeUpdateAndDelete"]);
                        }
                        else if (entity.Id == null)
                        {
                            AddRowError(index + 2, _localizer["Error_TheUnitCode0DoesNotExist"]);
                        }
                    }
                    result.ForEach(e => e.EntityState = "Updated");

                    if (mode == "Update")
                    {
                        result.ForEach(e => e.EntityState = "Updated");
                    }
                    else if (mode == "Delete")
                    {
                        result.ForEach(e => e.EntityState = "Deleted");
                    }
                    else
                    {
                        throw new InvalidOperationException("Unknown save mode"); // Developer bug
                    }
                }
            }

            // Milestone 3: 
            if (!ModelState.IsValid)
            {
                throw new UnprocessableEntityException(ModelState);
            }

            // Function maps any future validation errors back to specific rows
            int? errorKeyMap(string key)
            {
                int? rowNumber = null;
                if (key != null && key.StartsWith("["))
                {
                    var indexStr = key.TrimStart('[').Split(']')[0];
                    if (int.TryParse(indexStr, out int index))
                    {
                        // Add 2:
                        // 1 for the header in the abstract grid
                        // 1 for the difference between index and number
                        rowNumber = index + 2;
                    }
                }
                return rowNumber;
            }

            return (result, errorKeyMap);
        }

        protected override AbstractDataGrid GetImportTemplate()
        {
            // Get the properties of the DTO for Save, excluding Id or EntityState
            var type = typeof(MeasurementUnitForSave);
            var props = type.GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);

            // The result that will be returned
            var result = new AbstractDataGrid(props.Length, 1);

            // Add the header
            var header = result[result.AddRow()];
            for (int i = 0; i < props.Length; i++)
            {
                var prop = props[i];
                var display = _metadataProvider.GetMetadataForProperty(type, prop.Name)?.DisplayName ?? prop.Name;
                // var display = _localizer["MeasurementUnit_Code"].Value;
                header[i] = AbstractDataCell.Cell(display);
            }

            return result;
        }

        protected override AbstractDataGrid ToAbstractGrid(GetResponse<MeasurementUnit> response, ExportArguments args)
        {
            // Get all the properties without Id and EntityState
            var type = typeof(MeasurementUnit);
            var readProps = typeof(MeasurementUnit).GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);
            var saveProps = typeof(MeasurementUnitForSave).GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);
            var props = saveProps.Union(readProps).ToArray();

            // The result that will be returned
            var result = new AbstractDataGrid(props.Length, response.Data.Count() + 1);

            // Add the header
            var header = result[result.AddRow()];
            for (int i = 0; i < props.Length; i++)
            {
                var prop = props[i];
                var display = _metadataProvider.GetMetadataForProperty(type, prop.Name)?.DisplayName ?? prop.Name;

                header[i] = AbstractDataCell.Cell(display);
            }


            // Add the rows
            foreach (var entity in response.Data)
            {
                var row = result[result.AddRow()];
                for (int i = 0; i < props.Length; i++)
                {
                    var prop = props[i];
                    var content = prop.GetValue(entity);

                    // Special handling for choice lists
                    var choiceListAttr = prop.GetCustomAttribute<ChoiceListAttribute>();
                    if (choiceListAttr != null)
                    {
                        var choiceIndex = Array.FindIndex(choiceListAttr.Choices, e => e.Equals(content));
                        if (choiceIndex != -1)
                        {
                            string displayName = choiceListAttr.DisplayNames[choiceIndex];
                            content = _localizer[displayName];
                        }
                    }

                    row[i] = AbstractDataCell.Cell(content);
                }
            }

            return result;
        }

        private bool IsForeignKeyViolation(SqlException ex)
        {
            return ex.Number == 547;
        }
    }
}
