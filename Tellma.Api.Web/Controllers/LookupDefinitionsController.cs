﻿using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Tellma.Api;
using Tellma.Api.Base;
using Tellma.Api.Dto;
using Tellma.Model.Application;
using Tellma.Services.Utilities;

namespace Tellma.Controllers
{
    [Route("api/lookup-definitions")]
    [ApplicationController]
    [ApiVersion("1.0")]
    public class LookupDefinitionsController : CrudControllerBase<LookupDefinitionForSave, LookupDefinition, int>
    {
        private readonly LookupDefinitionsService _service;

        public LookupDefinitionsController(LookupDefinitionsService service)
        {
            _service = service;
        }

        [HttpPut("update-state")]
        public async Task<ActionResult<EntitiesResponse<Document>>> Close([FromBody] List<int> ids, [FromQuery] UpdateStateArguments args)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await _service.UpdateState(ids, args);

            Response.Headers.Set("x-definitions-version", Constants.Stale);
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

        protected override CrudServiceBase<LookupDefinitionForSave, LookupDefinition, int> GetCrudService()
        {
            return _service;
        }

        protected override Task OnSuccessfulSave(EntitiesResult<LookupDefinition> data)
        {
            Response.Headers.Set("x-definitions-version", Constants.Stale);
            return base.OnSuccessfulSave(data);
        }

        protected override Task OnSuccessfulDelete(List<int> ids)
        {
            Response.Headers.Set("x-definitions-version", Constants.Stale);
            return base.OnSuccessfulDelete(ids);
        }
    }
}
