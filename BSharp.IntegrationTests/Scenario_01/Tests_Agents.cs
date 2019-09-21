﻿using BSharp.Controllers.Dto;
using BSharp.Entities;
using BSharp.IntegrationTests.Utilities;
using BSharp.Services.Utilities;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Threading.Tasks;
using Xunit;
using Xunit.Abstractions;

namespace BSharp.IntegrationTests.Scenario_01
{
    public class Tests_Agents : Scenario_01
    {
        public Tests_Agents(Scenario_01_WebApplicationFactory factory, ITestOutputHelper output) : base(factory, output)
        {
        }

        public readonly string _baseAddress = "agents";

        public string Url => $"/api/{_baseAddress}";
        private string ViewId => _baseAddress;

        [Fact(DisplayName = "01 Getting all agents before creating any returns a 200 OK singleton collection")]
        public async Task Test02()
        {
            await GrantPermissionToSecurityAdministrator(ViewId, Constants.Update, "Id lt 100000");

            // Call the API
            var response = await Client.GetAsync(Url);
            Output.WriteLine(await response.Content.ReadAsStringAsync());

            // Assert the result is 200 OK
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            // Confirm the result is a well formed response
            var responseData = await response.Content.ReadAsAsync<GetResponse<Agent>>();

            // Assert the result makes sense
            Assert.Equal("Agent", responseData.CollectionName);

            Assert.Equal(1, responseData.TotalCount);
            Assert.Single(responseData.Result);
        }

        [Fact(DisplayName = "02 Getting a non-existent agent id returns a 404 Not Found")]
        public async Task Test03()
        {
            int nonExistentId = 500;
            var response = await Client.GetAsync($"{Url}/{nonExistentId}");

            Output.WriteLine(await response.Content.ReadAsStringAsync());
            Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
        }

        [Fact(DisplayName = "03 Saving two well-formed AgentForSave returns a 200 OK result")]
        public async Task Test04()
        {
            // Prepare a well formed entity
            var dtoForSave = new AgentForSave
            {
                Name = "John Wick",
                Name2 = "جون ويك",
                Code = "JW",
                PreferredLanguage = "en",
                AgentType = "Individual",
                IsRelated = false
            };

            var dtoForSave2 = new AgentForSave
            {
                Name = "Jason Bourne",
                Name2 = "جيسن بورن",
                Code = "JB",
                PreferredLanguage = "en",
                AgentType = "Individual",
                IsRelated = false
            };

            // Save it
            var dtosForSave = new List<AgentForSave> { dtoForSave, dtoForSave2 };
            var response = await Client.PostAsJsonAsync(Url, dtosForSave);

            // Assert that the response status code is a happy 200 OK
            Output.WriteLine(await response.Content.ReadAsStringAsync());
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            // Assert that the response is well-formed singleton of Agent
            var responseData = await response.Content.ReadAsAsync<EntitiesResponse<Agent>>();
            Assert.Collection(responseData.Result,
                e => Assert.NotEqual(0, e.Id),
                e => Assert.NotEqual(0, e.Id));

            // Assert that the result matches the saved entity
            Assert.Equal("Agent", responseData.CollectionName);

            // Retreve the entity from the entities
            var responseDto = responseData.Result.FirstOrDefault();

            Assert.Equal(dtoForSave.Name, responseDto.Name);
            Assert.Equal(dtoForSave.Name2, responseDto.Name2);
            Assert.Equal(dtoForSave.Code, responseDto.Code);
            Assert.Equal(dtoForSave.PreferredLanguage, responseDto.PreferredLanguage);
            Assert.Equal(dtoForSave.AgentType, responseDto.AgentType);


            var responseDto2 = responseData.Result.LastOrDefault();

            Assert.Equal(dtoForSave2.Name, responseDto2.Name);
            Assert.Equal(dtoForSave2.Name2, responseDto2.Name2);
            Assert.Equal(dtoForSave2.Code, responseDto2.Code);
            Assert.Equal(dtoForSave2.PreferredLanguage, responseDto2.PreferredLanguage);
            Assert.Equal(dtoForSave2.AgentType, responseDto2.AgentType);

            Shared.Set("Agent_JohnWick", responseDto);
            Shared.Set("Agent_JasonBourne", responseDto2);
        }

        [Fact(DisplayName = "04 Getting the Id of the AgentForSave just saved returns a 200 OK result")]
        public async Task Test05()
        {
            // Query the API for the Id that was just returned from the Save
            var entity = Shared.Get<Agent>("Agent_JohnWick");
            var id = entity.Id;
            var response = await Client.GetAsync($"{Url}/{id}");

            Output.WriteLine(await response.Content.ReadAsStringAsync());
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            // Confirm that the response is a well formed GetByIdResponse of agent
            var getByIdResponse = await response.Content.ReadAsAsync<GetByIdResponse<Agent>>();
            Assert.Equal("Agent", getByIdResponse.CollectionName);

            var responseDto = getByIdResponse.Result;
            Assert.Equal(id, responseDto.Id);
            Assert.Equal(entity.Name, responseDto.Name);
            Assert.Equal(entity.Name2, responseDto.Name2);
            Assert.Equal(entity.Code, responseDto.Code);
            Assert.Equal(entity.PreferredLanguage, responseDto.PreferredLanguage);
            Assert.Equal(entity.AgentType, responseDto.AgentType);
        }

        [Fact(DisplayName = "05 Saving an AgentForSave with an existing code returns a 422 Unprocessable Entity")]
        public async Task Test06()
        {
            // Prepare a unit with the same code 'kg' as one that has been saved already
            var list = new List<AgentForSave> {
                new AgentForSave
                {
                    Name = "Another Name",
                    Name2 = "Another Name",
                    Code = "JW",
                    PreferredLanguage = "en",
                    AgentType = "Individual",
                    IsRelated = false
                }
            };

            // Call the API
            var response = await Client.PostAsJsonAsync(Url, list);

            // Assert that the response status code is 422 unprocessable entity (validation errors)
            Output.WriteLine(await response.Content.ReadAsStringAsync());
            Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);

            // Confirm that the result is a well-formed validation errors structure
            var errors = await response.Content.ReadAsAsync<ValidationErrors>();

            // Assert that it contains a validation key pointing to the Code property
            string expectedKey = "[0].Code";
            Assert.True(errors.ContainsKey(expectedKey), $"Expected error key '{expectedKey}' was not found");

            // Assert that it contains a useful error message in English
            var message = errors["[0].Code"].Single();
            Assert.Contains("already used", message.ToLower());
        }

        [Fact(DisplayName = "06 Saving an AgentForSave trims string fields with trailing or leading spaces")]
        public async Task Test07()
        {
            // Prepare a DTO for save, that contains leading and 
            // trailing spaces in some string properties
            var dtoForSave = new AgentForSave
            {
                Name = "  Matilda", // Leading space
                Name2 = "ماتيلدا",
                Code = "MA  ", // Trailing space
                PreferredLanguage = "en",
                AgentType = "Individual",
                IsRelated = false,
            };

            // Call the API
            var response = await Client.PostAsJsonAsync(Url, new List<AgentForSave> { dtoForSave });
            Output.WriteLine(await response.Content.ReadAsStringAsync());

            // Confirm that the response is well-formed
            var responseData = await response.Content.ReadAsAsync<EntitiesResponse<Agent>>();
            var responseDto = responseData.Result.FirstOrDefault();

            // Confirm the entity was saved
            Assert.NotEqual(0, responseDto.Id);

            // Confirm that the leading and trailing spaces have been trimmed
            Assert.Equal(dtoForSave.Name?.Trim(), responseDto.Name);
            Assert.Equal(dtoForSave.Code?.Trim(), responseDto.Code);

            // share the entity, for the subsequent delete test
            Shared.Set("Agent_Matilda", responseDto);
        }

        [Fact(DisplayName = "07 Deleting an existing agent Id returns a 200 OK")]
        public async Task Test08()
        {
            await GrantPermissionToSecurityAdministrator(ViewId, Constants.Delete, null);

            // Get the Id
            var entity = Shared.Get<Agent>("Agent_Matilda");
            var id = entity.Id;

            // Query the delete API
            var msg = new HttpRequestMessage(HttpMethod.Delete, Url)
            {
                Content = new ObjectContent<List<int>>(new List<int> { id }, new JsonMediaTypeFormatter())
            };

            var deleteResponse = await Client.SendAsync(msg);

            Output.WriteLine(await deleteResponse.Content.ReadAsStringAsync());
            Assert.Equal(HttpStatusCode.OK, deleteResponse.StatusCode);
        }

        [Fact(DisplayName = "08 Getting an Id that was just deleted returns a 404 Not Found")]
        public async Task Test09()
        {
            // Get the Id
            var entity = Shared.Get<Agent>("Agent_Matilda");
            var id = entity.Id;

            // Verify that the id was deleted by calling get        
            var getResponse = await Client.GetAsync($"{Url}/{id}");

            // Assert that the response is correct
            Output.WriteLine(await getResponse.Content.ReadAsStringAsync());
            Assert.Equal(HttpStatusCode.NotFound, getResponse.StatusCode);
        }

        [Fact(DisplayName = "09 Deactivating an active agent returns a 200 OK inactive entity")]
        public async Task Test10()
        {
            await GrantPermissionToSecurityAdministrator(ViewId, "IsActive", null);

            // Get the Id
            var entity = Shared.Get<Agent>("Agent_JohnWick");
            var id = entity.Id;

            // Call the API
            var response = await Client.PutAsJsonAsync($"{Url}/deactivate", new List<int>() { id });

            // Assert that the response status code is correct
            Output.WriteLine(await response.Content.ReadAsStringAsync());
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            // Confirm that the response content is well formed singleton
            var responseData = await response.Content.ReadAsAsync<EntitiesResponse<Agent>>();
            Assert.Single(responseData.Result);
            var responseDto = responseData.Result.Single();

            // Confirm that the entity was deactivated
            Assert.False(responseDto.IsActive, "The Agent was not deactivated");
        }

        [Fact(DisplayName = "10 Activating an inactive agent returns a 200 OK active entity")]
        public async Task Test11()
        {
            // Get the Id
            var entity = Shared.Get<Agent>("Agent_JohnWick");
            var id = entity.Id;

            // Call the API
            var response = await Client.PutAsJsonAsync($"{Url}/activate", new List<int>() { id });

            // Assert that the response status code is correct
            Output.WriteLine(await response.Content.ReadAsStringAsync());
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            // Confirm that the response content is well formed singleton
            var responseData = await response.Content.ReadAsAsync<EntitiesResponse<Agent>>();
            Assert.Single(responseData.Result);
            var responseDto = responseData.Result.Single();

            // Confirm that the entity was activated
            Assert.True(responseDto.IsActive, "The Agent was not activated");
        }

        [Fact(DisplayName = "11 Using Select argument works as expected")]
        public async Task Test12()
        {
            // Get the Id
            var entity = Shared.Get<Agent>("Agent_JohnWick");
            var id = entity.Id;

            var response = await Client.GetAsync($"{Url}/{id}?select=Name");

            Output.WriteLine(await response.Content.ReadAsStringAsync());
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            // Confirm that the response is a well formed GetByIdResponse of Agent
            var getByIdResponse = await response.Content.ReadAsAsync<GetByIdResponse<Agent>>();
            Assert.Equal("Agent", getByIdResponse.CollectionName);

            var responseDto = getByIdResponse.Result;
            Assert.Equal(id, responseDto.Id);
            Assert.Equal(entity.Name, responseDto.Name);
            Assert.Null(responseDto.Name2);
            Assert.Null(responseDto.Code);
            Assert.Null(responseDto.AgentType);
            Assert.Null(responseDto.PreferredLanguage);
        }
    }
}
