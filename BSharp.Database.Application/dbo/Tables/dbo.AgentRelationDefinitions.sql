﻿CREATE TABLE [dbo].[AgentRelationDefinitions] ( -- managed by Banan IT
	[Id]							NVARCHAR (50)	CONSTRAINT [PK_AgentRelationDefinitions] PRIMARY KEY,
	[SingularLabel]					NVARCHAR (50)	NOT NULL, -- legal Label
	[SingularLabel2]				NVARCHAR (50),
	[SingularLabel3]				NVARCHAR (50),
	[PluralLabel]					NVARCHAR (50),
	[PluralLabel2]					NVARCHAR (50),
	[PluralLabel3]					NVARCHAR (50),
	[Prefix]						NVARCHAR (30)	DEFAULT (N''),
	[CodeWidth]						TINYINT			DEFAULT (3), -- For presentation purposes
	[IsActive]						BIT				NOT NULL DEFAULT 1,

	[JobTitleVisibility]			NVARCHAR (50), -- not visible, visible, visible and required
	[BasicSalaryVisibility]			NVARCHAR (50),
	[TransportationAllowanceVisibility]		NVARCHAR (50),
	[HardshipAllowanceVisibility]	NVARCHAR (50),
	[OvertimeRate]					MONEY,

	[CreatedAt]						DATETIMEOFFSET(7)	NOT NULL DEFAULT SYSDATETIMEOFFSET(),
	[CreatedById]					INT					NOT NULL DEFAULT CONVERT(INT, SESSION_CONTEXT(N'UserId')),
	[ModifiedAt]					DATETIMEOFFSET(7)	NOT NULL DEFAULT SYSDATETIMEOFFSET(), 
	[ModifiedById]					INT					NOT NULL DEFAULT CONVERT(INT, SESSION_CONTEXT(N'UserId')),
	CONSTRAINT [FK_AgentRelationDefinitions__CreatedById] FOREIGN KEY ([CreatedById]) REFERENCES [dbo].[Users] ([Id]),
	CONSTRAINT [FK_AgentRelationDefinitions__ModifiedById]  FOREIGN KEY ([ModifiedById]) REFERENCES [dbo].[Users] ([Id]),
);


/* 
Shareholder, Investment, Customer, Supplier, Employee, CostCenter, Cost Unit, Revenue Center, Debtor, Creditor
Two levels might be a good idea. We may want to separate the customer categories into: Bookshop customers, students, etc.
Shareholders: 0
	Shareholder					
	Non Voting					
Cash Custodian 100
	Petty Cash
	Cash
	Bank
Inventory Custodian 200
Customer: 300
	Customer - Retail			
	Tenant
	Passenger
	Distributer					
	Student						
	Patient						
	Pet							
	Household					
Suppliers: 400
	Supplier -					
Employees: 500
	Employee - Full time		
	Employee - Part time
	Employee - Home worker
	Employee - Consultant
Debtor: 600
Creditor: 700
Investment: 800
Employer: 900
*/