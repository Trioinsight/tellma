﻿using Asp.Versioning;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using Tellma.Api;
using Tellma.Api.Base;
using Tellma.Api.Dto;
using Tellma.Model.Application;
using Tellma.Services.Utilities;

namespace Tellma.Controllers
{
    [Route("api/report-definitions")]
    [ApplicationController]
    [ApiVersion("1.0")]
    public class ReportDefinitionsController : CrudControllerBase<ReportDefinitionForSave, ReportDefinition, int>
    {
        private readonly ReportDefinitionsService _service;

        public ReportDefinitionsController(ReportDefinitionsService service)
        {
            _service = service;
        }

        protected override CrudServiceBase<ReportDefinitionForSave, ReportDefinition, int> GetCrudService()
        {
            return _service;
        }

        protected override Task OnSuccessfulSave(EntitiesResult<ReportDefinition> data)
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
