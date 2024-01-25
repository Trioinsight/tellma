﻿using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Tellma.Api;
using Tellma.Api.Base;
using Tellma.Api.Dto;
using Tellma.Model.Application;
using Tellma.Services.Utilities;

namespace Tellma.Controllers
{
    [Route("api/message-templates")]
    [ApplicationController]
    [ApiVersion("1.0")]
    public class MessageTemplatesController : CrudControllerBase<MessageTemplateForSave, MessageTemplate, int>
    {
        private readonly MessageTemplatesService _service;

        public MessageTemplatesController(MessageTemplatesService service)
        {
            _service = service;
        }

        // Standalone

        [HttpGet("message-preview/{templateId:int}")]
        public async Task<ActionResult<MessageCommandPreview>> MessageCommandPreview(int templateId, [FromQuery] PrintArguments args, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var result = await _service.MessageCommandPreviewByTemplateId(templateId, args, cancellation);

            return Ok(result);
        }

        [HttpPut("message/{templateId:int}")]
        public async Task<ActionResult<IdResult>> SendByMessage(int templateId, [FromQuery] PrintArguments args, [FromQuery] string version, CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var commandId = await _service.SendByMessage(templateId, args, version, cancellation);

            return Ok(new IdResult { Id = commandId });
        }

        // Studio Preview

        [HttpPut("message-preview")]
        public async Task<ActionResult<MessageCommandPreview>> MessageCommandPreview(
            [FromBody] MessageTemplate template,
            [FromQuery] PrintArguments args,
            CancellationToken cancellation)
        {
            args.Custom = Request.Query.ToDictionary(e => e.Key, e => e.Value.FirstOrDefault());

            var result = await _service.MessageCommandPreview(template, args, cancellation);
            return Ok(result);
        }

        [HttpPut("message-entities-preview")]
        public async Task<ActionResult<MessageCommandPreview>> MessageCommandPreviewEntities(
            [FromBody] MessageTemplate template,
            [FromQuery] PrintEntitiesArguments<int> args,
            CancellationToken cancellation)
        {
            var result = await _service.MessageCommandPreviewEntities(template, args, cancellation);
            return Ok(result);
        }

        [HttpPut("{id:int}/message-entity-preview")]
        public async Task<ActionResult<MessageCommandPreview>> MessageCommandPreviewEntity(
            [FromRoute] int id,
            [FromBody] MessageTemplate template,
            [FromQuery] PrintEntityByIdArguments args,
            CancellationToken cancellation)
        {
            var result = await _service.MessageCommandPreviewEntity(id: id, template, args, cancellation);
            return Ok(result);
        }

        protected override CrudServiceBase<MessageTemplateForSave, MessageTemplate, int> GetCrudService()
        {
            return _service;
        }

        protected override Task OnSuccessfulSave(EntitiesResult<MessageTemplate> data)
        {
            if (data?.Data != null && data.Data.Any(e => e.IsDeployed ?? false))
            {
                Response.Headers.Set("x-definitions-version", Constants.Stale);
            }

            return base.OnSuccessfulSave(data);
        }
    }
}
