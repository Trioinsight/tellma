﻿using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System;
using System.Threading.Tasks;
using Tellma.Api;
using Tellma.Api.Base;
using Tellma.Api.Dto;
using Tellma.Model.Admin;
using Tellma.Services.ApiAuthentication;

namespace Tellma.Controllers
{
    [Route("api/identity-server-clients")]
    [AuthorizeJwtBearer]
    [AdminController]
    [ApiVersion("1.0")]
    public class IdentityServerClientsController : CrudControllerBase<IdentityServerClientForSave, IdentityServerClient, int>
    {
        private readonly IdentityServerClientsService _service;

        public IdentityServerClientsController(IdentityServerClientsService service)
        {
            _service = service;
        }

        protected override CrudServiceBase<IdentityServerClientForSave, IdentityServerClient, int> GetCrudService()
        {
            return _service;
        }

        [HttpPut("reset-secret")]
        public async Task<ActionResult<EntitiesResponse<IdentityServerClient>>> ResetSecret([FromQuery] ResetClientSecretArguments args)
        {
            var serverTime = DateTimeOffset.UtcNow;
            var result = await _service.ResetClientSecret(args);
            var response = TransformToEntitiesResponse(result, serverTime, cancellation: default);

            return Ok(response);
        }
    }
}
