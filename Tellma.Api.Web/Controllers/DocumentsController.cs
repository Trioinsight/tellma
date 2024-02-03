﻿using Asp.Versioning;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Tellma.Api;
using Tellma.Api.Base;
using Tellma.Api.Dto;
using Tellma.Controllers.Utilities;
using Tellma.Model.Application;

namespace Tellma.Controllers
{
    [Route("api/documents/{definitionId:int}")]
    [ApplicationController]
    [ApiVersion("1.0")]
    public class DocumentsController : CrudControllerBase<DocumentForSave, Document, int, DocumentsResult, DocumentResult>
    {
        private readonly DocumentsService _service;

        public DocumentsController(DocumentsService service)
        {
            _service = service;
        }

        [HttpGet("{id:int}/attachments/{attachmentId:int}")]
        public async Task<ActionResult> GetAttachment(int id, int attachmentId, CancellationToken cancellation)
        {
            var result = await GetService().GetAttachment(id, attachmentId, cancellation);
            var contentType = ControllerUtilities.ContentType(result.FileName);

            return File(fileContents: result.FileBytes, contentType: contentType, result.FileName);
        }

        [HttpPut("assign")]
        public async Task<ActionResult<EntitiesResponse<Document>>> Assign([FromBody] List<int> ids, [FromQuery] AssignArguments args)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await GetService().Assign(ids, args);

            if (args.ReturnEntities ?? false)
            {
                var response = TransformToEntitiesResponse(result, serverTime, cancellation: default);
                return Ok(response);
            }
            else
            {
                return Ok();
            }
        }

        [HttpPut("update-assignment")]
        public async Task<ActionResult<GetByIdResponse<Document>>> UpdateAssignment([FromQuery] UpdateAssignmentArguments args)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await GetService().UpdateAssignment(args);

            if (args.ReturnEntities ?? false)
            {
                var entity = result.Entity;

                // Flatten and Trim
                var singleton = new List<Document> { entity };
                var relatedEntities = Flatten(singleton, cancellation: default);

                // Prepare the result in a response object
                var response = new GetByIdResponse<Document>
                {
                    Result = entity,
                    RelatedEntities = relatedEntities,
                    CollectionName = ControllerUtilities.GetCollectionName(typeof(Document)),
                    Extras = CreateExtras(result),
                    ServerTime = serverTime,
                };

                return Ok(response);
            }
            else
            {
                return Ok();
            }
        }

        [HttpPut("sign-lines")]
        public async Task<ActionResult<EntitiesResponse<Document>>> SignLines([FromBody] List<int> lineIds, [FromQuery] SignArguments args)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await GetService().SignLines(lineIds, args);

            if (args.ReturnEntities ?? false)
            {
                var response = TransformToEntitiesResponse(result, serverTime, cancellation: default);
                return Ok(response);
            }
            else
            {
                return Ok();
            }
        }

        [HttpPut("unsign-lines")]
        public async Task<ActionResult<EntitiesResponse<Document>>> UnsignLines([FromBody] List<int> signatureIds, [FromQuery] ActionArguments args)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await GetService().UnsignLines(signatureIds, args);

            if (args.ReturnEntities ?? false)
            {
                var response = TransformToEntitiesResponse(result, serverTime, cancellation: default);
                return Ok(response);
            }
            else
            {
                return Ok();
            }
        }

        [HttpPut("close")]
        public async Task<ActionResult<EntitiesResponse<Document>>> Close([FromBody] List<int> ids, [FromQuery] ActionArguments args)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await GetService().Close(ids, args);

            if (args.ReturnEntities ?? false)
            {
                var response = TransformToEntitiesResponse(result, serverTime, cancellation: default);
                return Ok(response);
            }
            else
            {
                return Ok();
            }
        }

        [HttpPut("open")]
        public async Task<ActionResult<EntitiesResponse<Document>>> Open([FromBody] List<int> ids, [FromQuery] ActionArguments args)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await GetService().Open(ids, args);

            if (args.ReturnEntities ?? false)
            {
                var response = TransformToEntitiesResponse(result, serverTime, cancellation: default);
                return Ok(response);
            }
            else
            {
                return Ok();
            }
        }

        [HttpPut("cancel")]
        public async Task<ActionResult<EntitiesResponse<Document>>> Cancel([FromBody] List<int> ids, [FromQuery] ActionArguments args)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await GetService().Cancel(ids, args);

            if (args.ReturnEntities ?? false)
            {
                var response = TransformToEntitiesResponse(result, serverTime, cancellation: default);
                return Ok(response);
            }
            else
            {
                return Ok();
            }
        }

        [HttpPut("uncancel")]
        public async Task<ActionResult<EntitiesResponse<Document>>> Uncancel([FromBody] List<int> ids, [FromQuery] ActionArguments args)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await GetService().Uncancel(ids, args);

            if (args.ReturnEntities ?? false)
            {
                var response = TransformToEntitiesResponse(result, serverTime, cancellation: default);
                return Ok(response);
            }
            else
            {
                return Ok();
            }
        }

        [HttpPut("generate-lines")]
        public async Task<ActionResult<EntitiesResponse<LineForSave>>> AutoGenerateLinesForMultipleDefinitions(
            [FromQuery] List<int> i, 
            [FromBody] List<DocumentForSave> entities, 
            CancellationToken cancellation)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await GetService().AutoGenerateLinesForMultipleDefinitions(i, entities, new(), cancellation);

            var response = MapToResponse(result, serverTime);

            // Return
            return Ok(response);
        }

        [HttpPut("generate-lines/{lineDefId:int}")]
        public async Task<ActionResult<EntitiesResponse<LineForSave>>> AutoGenerateLines(
            [FromRoute] int lineDefId, 
            [FromBody] List<DocumentForSave> entities, 
            [FromQuery] Dictionary<string, string> args, 
            CancellationToken cancellation)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await GetService().AutoGenerateLines(lineDefId, entities, args, cancellation);

            var response = MapToResponse(result, serverTime);

            // Return
            return Ok(response);
        }

        private EntitiesResponse<LineForSave> MapToResponse(LinesResult result, DateTimeOffset serverTime)
        {
            // Related entitiess
            var relatedEntities = new RelatedEntities
            {
                Account = result.Accounts.ToList(),
                Resource = result.Resources.ToList(),
                Agent = result.Agents.ToList(),
                EntryType = result.EntryTypes.ToList(),
                Center = result.Centers.ToList(),
                Currency = result.Currencies.ToList(),
                Unit = result.Units.ToList()
            };

            // Prepare the result in a response object
            var response = new EntitiesResponse<LineForSave>
            {
                Result = result.Data.ToList(),
                RelatedEntities = relatedEntities,
                CollectionName = "", // Not important
                ServerTime = serverTime,
            };

            return response;
        }

        [HttpGet("email-entities-preview/{templateId:int}")]
        public async Task<ActionResult<EmailCommandPreview>> EmailCommandPreviewEntities(int templateId, [FromQuery] PrintEntitiesArguments<int> args, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var service = GetService();
            var result = await service.EmailCommandPreviewEntities(templateId, args, cancellation);

            return Ok(result);
        }

        [HttpGet("email-entities-preview/{templateId:int}/{index:int}")]
        public async Task<ActionResult<EmailPreview>> EmailPreviewEntities(int templateId, int index, [FromQuery] PrintEntitiesArguments<int> args, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var service = GetService();
            var result = await service.EmailPreviewEntities(templateId, index, args, cancellation);

            return Ok(result);
        }

        [HttpPut("email-entities/{templateId:int}")]
        public async Task<ActionResult<IdResult>> EmailEntities(int templateId, [FromQuery] PrintEntitiesArguments<int> args, [FromBody] EmailCommandVersions versions, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var service = GetService();
            int commandId = await service.SendByEmail(templateId, args, versions, cancellation);

            return Ok(new IdResult { Id = commandId });
        }

        [HttpGet("{id:int}/email-entity-preview/{templateId:int}")]
        public async Task<ActionResult<EmailCommandPreview>> EmailCommandPreviewEntity(int id, int templateId, [FromQuery] PrintEntityByIdArguments args, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var service = GetService();
            var result = await service.EmailCommandPreviewEntity(id, templateId, args, cancellation);

            return Ok(result);
        }

        [HttpGet("{id:int}/email-entity-preview/{templateId:int}/{index:int}")]
        public async Task<ActionResult<EmailPreview>> EmailPreviewEntity(int id, int templateId, int index, [FromQuery] PrintEntityByIdArguments args, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var service = GetService();
            var result = await service.EmailPreviewEntity(id, templateId, index, args, cancellation);

            return Ok(result);
        }

        [HttpPut("{id:int}/email-entity/{templateId:int}")]
        public async Task<ActionResult<IdResult>> EmailEntity(int id, int templateId, [FromQuery] PrintEntityByIdArguments args, [FromBody] EmailCommandVersions versions, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var service = GetService();
            int commandId = await service.SendByEmail(id, templateId, args, versions, cancellation);

            return Ok(new IdResult { Id = commandId });
        }

        [HttpGet("message-entities-preview/{templateId:int}")]
        public async Task<ActionResult<MessageCommandPreview>> MessageCommandPreviewEntities(int templateId, [FromQuery] PrintEntitiesArguments<int> args, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var service = GetService();
            var result = await service.MessageCommandPreviewEntities(templateId, args, cancellation);

            return Ok(result);
        }

        [HttpPut("message-entities/{templateId:int}")]
        public async Task<ActionResult<IdResult>> MessageEntities(int templateId, [FromQuery] PrintEntitiesArguments<int> args, [FromQuery] string version, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var service = GetService();
            var commandId = await service.SendByMessage(templateId, args, version, cancellation);

            return Ok(new IdResult { Id = commandId });
        }

        [HttpGet("{id:int}/message-entity-preview/{templateId:int}")]
        public async Task<ActionResult<MessageCommandPreview>> MessageCommandPreviewEntity(int id, int templateId, [FromQuery] PrintEntityByIdArguments args, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var service = GetService();
            var result = await service.MessageCommandPreviewEntity(id, templateId, args, cancellation);

            return Ok(result);
        }

        [HttpPut("{id:int}/message-entity/{templateId:int}")]
        public async Task<ActionResult<IdResult>> MessageEntity(int id, int templateId, [FromQuery] PrintEntityByIdArguments args, [FromQuery] string version, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var service = GetService();
            int commandId = await service.SendByMessage(id, templateId, args, version, cancellation);

            return Ok(new IdResult { Id = commandId });
        }

        [HttpPost("lines/{lineDefId:int}/parse"), RequestSizeLimit(20 * 1024 * 1024)] // 20 MB
        public async Task<ActionResult<EntitiesResponse<LineForSave>>> LinesParse([FromRoute] int lineDefId, CancellationToken cancellation)
        {
            var serverTime = DateTimeOffset.UtcNow;

            string contentType = null;
            string fileName = null;
            Stream fileStream = null;

            if (Request.Form.Files.Count > 0)
            {
                IFormFile formFile = Request.Form.Files[0];
                contentType = formFile?.ContentType;
                fileName = formFile?.FileName;
                fileStream = formFile?.OpenReadStream();
            }

            try
            {
                var service = GetService();
                var result = await service.ParseLines(fileStream, lineDefId, fileName, contentType, cancellation);

                // Related entitiess
                var relatedEntities = new RelatedEntities
                {
                    Account = result.Accounts.ToList(),
                    Resource = result.Resources.ToList(),
                    Agent = result.Agents.ToList(),
                    EntryType = result.EntryTypes.ToList(),
                    Center = result.Centers.ToList(),
                    Currency = result.Currencies.ToList(),
                    Unit = result.Units.ToList()
                };

                // Prepare the result in a response object
                var response = new EntitiesResponse<LineForSave>
                {
                    Result = result.Data.ToList(),
                    RelatedEntities = relatedEntities,
                    CollectionName = "", // Not important
                    ServerTime = serverTime,
                };

                // Return
                return Ok(response);
            }
            finally
            {
                if (fileStream != null)
                {
                    await fileStream.DisposeAsync();
                }
            }
        }

        [HttpGet("lines/{lineDefId:int}/template")]
        public async Task<ActionResult> CsvTemplateForLines([FromRoute] int lineDefId, CancellationToken cancellation)
        {
            var service = GetService();
            Stream template = await service.CsvTemplateForLines(lineDefId, cancellation);

            return await Task.FromResult(File(template, MimeTypes.Csv));
        }

        protected override CrudServiceBase<DocumentForSave, Document, int, DocumentsResult, DocumentResult> GetCrudService()
        {
            return GetService();
        }

        private DocumentsService GetService()
        {
            _service.SetDefinitionId(DefinitionId);
            _service.SetIncludeRequiredSignatures(IncludeRequiredSignatures());

            return _service;
        }

        protected int DefinitionId => int.Parse(Request.RouteValues.GetValueOrDefault("definitionId").ToString());

        private bool IncludeRequiredSignatures()
        {
            const string paramName = "includeRequiredSignatures";

            return Request.Query.TryGetValue(paramName, out StringValues value)
                && value.FirstOrDefault()?.ToLower() == "true";
        }

        protected override Extras CreateExtras(DocumentResult result)
        {
            return CreateExtras(result.RequiredSignatures);
        }

        protected override Extras CreateExtras(DocumentsResult result)
        {
            return CreateExtras(result.RequiredSignatures);
        }

        protected Extras CreateExtras(IReadOnlyList<RequiredSignature> requiredSignatures)
        {
            if (requiredSignatures == null)
            {
                return null;
            }
            else
            {
                var extras = new Extras();

                var relatedEntities = Flatten(requiredSignatures, cancellation: default);
                foreach (var rs in requiredSignatures)
                {
                    rs.EntityMetadata = null; // Smaller response size
                }

                extras["RequiredSignatures"] = requiredSignatures;
                extras["RequiredSignaturesRelatedEntities"] = relatedEntities;

                return extras;
            }
        }
    }

    [Route("api/documents")]
    [ApplicationController]
    public class DocumentsGenericController : FactWithIdControllerBase<Document, int>
    {
        private readonly DocumentsGenericService _service;

        public DocumentsGenericController(DocumentsGenericService service)
        {
            _service = service;
        }

        protected override FactWithIdServiceBase<Document, int> GetFactWithIdService()
        {
            return _service;
        }
    }
}