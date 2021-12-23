﻿using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection.Extensions;
using System;
using Tellma.Api;
using Tellma.Api.Behaviors;
using Tellma.Api.ImportExport;
using Tellma.Api.Templating;
using Tellma.Api.Base;
using Tellma.Utilities.Email;

namespace Microsoft.Extensions.DependencyInjection
{
    public static class ApiCollectionExtensions
    {
        /// <summary>
        /// Registers all the services of the Tellma API and their dependencies: <br/>
        /// - AdminRepository <br/>
        /// - ApplicationRepository <br/>
        /// - Sharding <br/>
        /// - NotificationsQueue <br/>
        /// - Metadata <br/>
        /// - Templating <br/>
        /// - Import/Export <br/>
        /// - API Base <br/>
        /// - Behaviors <br/>
        /// - API Services <br/>
        /// - Caches <br/>
        /// </summary>
        /// <remarks>
        /// Using the API requires implementations of the following to be available in the DI:<br/>
        /// - <see cref="IServiceContextAccessor"/> <br/>
        /// - <see cref="IClientProxy"/> <br/>
        /// - <see cref="IEmailQueuer"/> <br/>
        /// - <see cref="IIdentityProxy"/> (optional) <br/>
        /// </remarks>
        public static IServiceCollection AddTellmaApi(this IServiceCollection services, IConfiguration config)
        {
            if (services is null)
            {
                throw new ArgumentNullException(nameof(services));
            }

            if (config is null)
            {
                throw new ArgumentNullException(nameof(config));
            }

            // (1) Add repositories
            var adminConnString = config.GetConnectionString("AdminConnection");
            services
                .AddAdminRepository(adminConnString)
                .AddApplicationRepository()
                .AddSharding(config)
                .AddAdminConnectionResolver();

            // (2) Notifications queue
            services.AddNotifications(config);

            // (3) Add base
            services
                .AddTellmaApiBase() // Adds metadata, templating, import/export
                .AddSingleton<IApiClientForTemplating, ApiClient>()
                .AddSingleton<IApiClientForImport, ApiClient>();

            // (4) Add cache
            services
                .AddSingleton<ISettingsCache, SettingsCache>()
                .AddSingleton<IDefinitionsCache, DefinitionsCache>()
                .AddSingleton<IUserSettingsCache, UserSettingsCache>()
                .AddSingleton<IPermissionsCache, PermissionsCache>();

            // (5) Add behaviors
            services
                .AddScoped<NullServiceBehavior>()
                .AddScoped<ApplicationVersions>()
                .AddScoped<AdminVersions>()
                .AddScoped<AdminServiceBehavior>()
                .AddScoped<AdminFactServiceBehavior>()
                .AddScoped<ApplicationServiceBehavior>()
                .AddScoped<ApplicationFactServiceBehavior>();

            // (6) Add base Dependencies
            services
                .AddScoped<ApplicationSettingsServiceDependencies>();

            // (7) Add API services
            services
                .AddScoped<AccountClassificationsService>()
                .AddScoped<AccountsService>()
                .AddScoped<AccountTypesService>()
                .AddScoped<AdminPermissionsService>()
                .AddScoped<AdminSettingsService>()
                .AddScoped<AdminUsersService>()
                .AddScoped<CentersService>()
                .AddScoped<CompaniesService>()
                .AddScoped<CurrenciesService>()
                .AddScoped<DashboardDefinitionsService>()
                .AddScoped<DefinitionsService>()
                .AddScoped<DetailsEntriesService>()
                .AddScoped<DocumentDefinitionsService>()
                .AddScoped<DocumentsGenericService>()
                .AddScoped<DocumentsService>()
                .AddScoped<EmailsService>()
                .AddScoped<EntryTypesService>()
                .AddScoped<ExchangeRatesService>()
                .AddScoped<FinancialSettingsService>()
                .AddScoped<GeneralSettingsService>()
                .AddScoped<IdentityServerClientsService>()
                .AddScoped<IfrsConceptsService>()
                .AddScoped<InboxService>()
                .AddScoped<LineDefinitionsService>()
                .AddScoped<LookupDefinitionsService>()
                .AddScoped<LookupsGenericService>()
                .AddScoped<LookupsService>()
                .AddScoped<MessageTemplatesService>()
                .AddScoped<NotificationCommandsService>()
                .AddScoped<NotificationTemplatesService>()
                .AddScoped<PrintingTemplatesService>()
                .AddScoped<OutboxService>()
                .AddScoped<PermissionsService>()
                .AddScoped<ReconciliationService>()
                .AddScoped<AgentDefinitionsService>()
                .AddScoped<AgentsGenericService>()
                .AddScoped<AgentsService>()
                .AddScoped<ReportDefinitionsService>()
                .AddScoped<ResourceDefinitionsService>()
                .AddScoped<ResourcesGenericService>()
                .AddScoped<ResourcesService>()
                .AddScoped<RolesService>()
                .AddScoped<SmsMessagesService>()
                .AddScoped<StatusService>()
                .AddScoped<UnitsService>()
                .AddScoped<UsersService>();

            // (8) Default services
            services.TryAddSingleton<IIdentityProxy, NullIdentityProxy>();

            return services;
        }
    }
}