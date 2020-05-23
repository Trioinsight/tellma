﻿DELETE FROM @Roles;
DELETE FROM @Members;
DELETE FROM @Permissions;

IF @DB = N'101' -- Banan SD, USD, en
BEGIN
	INSERT INTO @Roles
	([Index],	[Name],				[Name2],		[Code], [IsPublic]) VALUES
	(0,			N'Finance Manager',	N'مدير مالي',	'FM',	0),
	(1,			N'General Manager', N'مدير عام',	'GM',	0),
	(2,			N'Reader',			N'قارئ',		'RDR',	0),
	(3,			N'Account Manager',	N'مدير علاقة',	'AM',	0),
	(4,			N'Comptroller',		N'مشرف حسابات','CMPT',	0),
	(5,			N'Cash Custodian',	N'مسؤول عهدة',	'CC',	0),
	(6,			N'Admin. Affairs',	N'الشؤون الإدارية', N'AA',0),
	(9,			N'Public',			N'عام',			'PBLC',	1)
	INSERT INTO @Members([Index],[HeaderIndex],
	[UserId]) VALUES
	(0,0,@Jiad_akra),
	(0,1,@amtaam),
	(0,2,@mohamad_akra),
	(0,3,@amtaam),
	(0,4,@Jiad_akra),
	(1,4,@alaeldin),
	(0,5,@amtaam),
	(1,5,@aasalam),
	(0,6,@omer);
	INSERT INTO @Permissions([Index], [HeaderIndex],
	--Action: N'Read', N'Update', N'Delete', N'IsActive', N'IsDeprecated', N'ResendInvitationEmail', N'State', N'All'))
		[Action],	[Criteria],			[View]) VALUES
	(0,0,N'All',	NULL,				N'all'),
	(0,1,N'All',	NULL,				N'all'),
	(0,2,N'Read',	NULL,				N'all'),
	(0,3,N'All',	N'CreatedById = Me',N'documents/revenue-recognition-vouchers'),
	(1,3,N'Update',	N'Agent/UserId = Me or (AgentId = Null and AssigneeId = Me)', -- requires specifying the safe in the header
										N'documents/cash-payment-vouchers'),
	(2,3,N'Update',	N'Agent/UserId = Me or (AgentId = Null and AssigneeId = Me)', -- requires specifying the safe in the header
										N'documents/cash-receipt-vouchers'),
	(0,4,N'All',	NULL,				N'documents/manual-journal-vouchers'),
	(1,4,N'All',	NULL,				N'documents/cash-payment-vouchers'),
	(2,4,N'All',	NULL,				N'documents/revenue-recognition-vouchers'),
	(3,4,N'Read',	NULL,				N'accounts'),
	(0,5,N'Update',	N'Agent/UserId = Me or (AgentId = Null and AssigneeId = Me)', -- requires specifying the safe in the header
										N'documents/cash-payment-vouchers'),
	(1,5,N'All',	N'Agent/UserId = Me or AssigneeId = Me',
										N'documents/cash-receipt-vouchers'),
	(2,5,N'Update', NULL,				N'contracts/suppliers'),

	(0,9,N'Read',	NULL,				N'contracts/cash-custodians'),
	(1,9,N'Read',	NULL,				N'centers'),
	(2,9,N'Read',	NULL,				N'currencies'),
	(3,9,N'Update',	N'CreatedById = Me',N'documents/cash-payment-vouchers'),
	(4,9,N'Read',	NULL,				N'resources/employee-benefits-expenses'),
	(5,9,N'Read',	NULL,				N'entry-types'),
	(6,9,N'Read',	NULL,				N'lookups/it-equipment-manufacturers'),
	(7,9,N'Read',	NULL,				N'units'),
	(8,9,N'Read',	NULL,				N'lookups/operating-systems'),
	(9,9,N'Read',	NULL,				N'centers'),
	(10,9,N'Read',	NULL,				N'resources/services-expenses'),
	(11,9,N'Read',	NULL,				N'roles'),
	(12,9,N'Read',	NULL,				N'contracts/suppliers'),
	(13,9,N'Read',	NULL,				N'users');
END

IF @DB = N'102' -- Banan ET, ETB, en
BEGIN
	INSERT INTO @Roles
	([Index],	[Name],				[Code]) VALUES
	(0,			N'Comptroller',		'CMPT'),
	(1,			N'General Manager', 'GM'),
	(2,			N'PR Officer',		'PRO'),
	(3,			N'Reader',			'RDR'),
	(4,			N'Employee',		'EMP');

	INSERT INTO @Members
	([HeaderIndex],	[Index],	[UserId])
	SELECT	0,		0,			[Id] FROM dbo.[Users] WHERE Email = N'jiad.akra@gmail.com'			UNION
	SELECT	1,		0,			[Id] FROM dbo.[Users] WHERE Email = N'mohamad.akra@banan-it.com'	UNION
	SELECT	2,		0,			[Id] FROM dbo.[Users] WHERE Email = N'wendylulu99@gmail.com'		UNION
	SELECT	3,		0,			[Id] FROM dbo.[Users] WHERE Email = N'ahmad.akra@banan-it.com'		UNION
	SELECT	4,		0,			[Id] FROM dbo.[Users] WHERE Email = N'yisakfikadu79@gmail.com'		;

	INSERT INTO @Permissions
	--Action: N'Read', N'Update', N'Delete', N'IsActive', N'IsDeprecated', N'ResendInvitationEmail', N'All'))
	([HeaderIndex],	[Index],[View],									[Action]) VALUES
	(0,				0,		N'all',									N'Read'),
	(0,				1,		N'documents/manual-journal-vouchers',	N'All'),
	(1,				0,		N'all',									N'Read'),
	(3,				0,		N'all',									N'Read');

END
--IF @DB = N'103' -- Lifan Cars, ETB, en/zh
--	INSERT INTO @Users
--	([Index],[Name],			[Name2],		[Name3],							[Email]) VALUES
--	(0,		N'Salman Al-Juhani',N'سلمان الجهني',N'萨尔曼·朱哈尼（Salman Al-Juhani)',	N'salman.aljuhani@lifan.com'),
--	(1,		N'Sami Shubaily',	N'سامي شبيلي',	N'萨米·希比利（Sami Shibili)',		N'sami.shubaily@lifan.com');

IF @DB = N'104' -- Walia Steel, ETB, en/am
BEGIN
	INSERT INTO @Roles
	([Index],	[Name],					[Code]) VALUES
	(0,			N'Finance Manager',		'FM'),
	(1,			N'General Manager',		'GM'),
	(2,			N'Production Manager',	'PM'),
	(3,			N'Sales Manager',		'SM'),
	(4,			N'Accountant',			'AE'),
	(5,			N'Cashier',				'CS')
	INSERT INTO @Members
	([HeaderIndex],	[Index],	[UserId])
	SELECT	0,		0,			[Id] FROM dbo.[Users] WHERE Email = N'tizitanigussie@gmail.com'		UNION
	SELECT	1,		0,			[Id] FROM dbo.[Users] WHERE Email = N'badege.kebede@gmail.com'		UNION
	SELECT	2,		0,			[Id] FROM dbo.[Users] WHERE Email = N'mesfinwolde47@gmail.com'		UNION
	SELECT	3,		0,			[Id] FROM dbo.[Users] WHERE Email = N'ashenafi935@gmail.com'		UNION
	SELECT	4,		0,			[Id] FROM dbo.[Users] WHERE Email = N'sarabirhanuk@gmail.com'		UNION	
	SELECT	4,		1,			[Id] FROM dbo.[Users] WHERE Email = N'zewdnesh.hora@gmail.com'		UNION
	SELECT	5,		0,			[Id] FROM dbo.[Users] WHERE Email = N'tigistnegash74@gmail.com'
	INSERT INTO @Permissions
	--Action: N'Read', N'Update', N'Delete', N'IsActive', N'IsDeprecated', N'ResendInvitationEmail', N'All'))
	([HeaderIndex],	[Index],[View],									[Action]) VALUES
	(0,				0,		N'all',									N'Read'),
	(0,				1,		N'documents/manual-journal-vouchers',	N'All'),
	(1,				0,		N'all',									N'Read'),
	(4,				0,		N'all',									N'Read'),
	(5,				0,		N'all',									N'Read')
	--INSERT INTO @Users
	--([Index],	[Name],						[Email]) VALUES
	--(0,			N'Badege Kebede',			N'badege.kebede@gmail.com'),
	--(1,			N'Mesfin Wolde',			N'mesfinwolde47@gmail.com'),
	--(2,			N'Ashenafi Fantahun',		N'ashenafi935@gmail.com'),
	--(3,			N'Ayelech Hora',			N'ayelech.hora@gmail.com'),
	--(4,			N'Tizita Nigussie',			N'tizitanigussie@gmail.com'),
	--(5,			N'Natnael Giragn',			N'natnaelgiragn340@gmail.com'),
	--(6,			N'Sara Birhanu',			N'sarabirhanuk@gmail.com'),
	--(7,			N'Sisay Tesfaye Bekele',	N'sisay41@yahoo.com'),
	--(8,			N'Tigist Negash',			N'tigistnegash74@gmail.com'),
	--(9,			N'Yisak Fikadu',			N'yisakfikadu79@gmail.com'),
	--(10,		N'Zewdinesh Hora',			N'zewdnesh.hora@gmail.com'),
	--(11,		N'Mestawet G/Egziyabhare',	N'mestawetezige@gmail.com'),
	--(12,		N'Belay Abagero',			N'belayabagero07@gmail.com'),
	--(13,		N'Kalkidan Asemamaw',		N'kasmamaw5@gmail.com');
END
IF @DB = N'105' -- Simpex, SAR, en/ar
BEGIN
	INSERT INTO @Roles
	([Index],	[Name],					[Name2],			[Code]) VALUES
	(0,			N'Finance Manager',		N'المدير المالي',	'FM'),
	(1,			N'General Manager',		N'المدير العام',	'GM'),
	(2,			N'Internal Auditor',	N'المراجع الداخلي','IA'),
	(3,			N'Account Comptroller',	N'مراقب الحسايات',	'AC'),
	(4,			N'Material Control',	N'إدارة المواد',	'MC');
	INSERT INTO @Members
	([HeaderIndex],	[Index],	[UserId])
	SELECT	0,		0,			[Id] FROM dbo.[Users] WHERE Email = N'hisham@simpex.co.sa'		UNION
	SELECT	1,		0,			[Id] FROM dbo.[Users] WHERE Email = N'nizar.kalo@simpex.co.sa'	UNION
	SELECT	2,		0,			[Id] FROM dbo.[Users] WHERE Email = N'mahdi.mrad@simpex.co.sa'		UNION
	SELECT	3,		0,			[Id] FROM dbo.[Users] WHERE Email = N'tareq@simpex.co.sa'		UNION
	SELECT	4,		0,			[Id] FROM dbo.[Users] WHERE Email = N'mazen.mrad@simpex.co.sa'	;
	INSERT INTO @Permissions
	--Action: N'Read', N'Update', N'Delete', N'IsActive', N'IsDeprecated', N'ResendInvitationEmail', N'All'))
	([HeaderIndex],	[Index],[View],									[Action]) VALUES
	(0,				0,		N'all',									N'Read'),
	(0,				1,		N'documents/manual-journal-vouchers',	N'All'),
	(1,				0,		N'all',									N'Read'),
	(4,				0,		N'all',									N'Read'),
	(5,				0,		N'all',									N'Read');
END

IF @DB = N'106' -- Soreti, ETB, en/am
BEGIN
	INSERT INTO @Roles
	([Index],	[Name],				[Name2],		[Code], [IsPublic]) VALUES
	(0,			N'Finance Manager',	N'مدير مالي',	'FM',	0),
	(1,			N'General Manager', N'مدير عام',	'GM',	0),
	(2,			N'Reader',			N'قارئ',		'RDR',	0),
	(3,			N'Account Manager',	N'مدير علاقة',	'AM',	0),
	(4,			N'Comptroller',		N'مشرف حسابات','CMPT',	0),
	(5,			N'Cash Custodian',	N'مسؤول عهدة',	'CC',	0),
	(6,			N'Admin. Affairs',	N'الشؤون الإدارية', N'AA',0),
	(9,			N'Public',			N'عام',			'PBLC',	1)
	INSERT INTO @Permissions([Index], [HeaderIndex],
	--Action: N'Read', N'Update', N'Delete', N'IsActive', N'IsDeprecated', N'ResendInvitationEmail', N'State', N'All'))
		[Action],	[Criteria],			[View]) VALUES
	(0,0,N'All',	NULL,				N'all'),
	(0,1,N'All',	NULL,				N'all'),
	(0,2,N'Read',	NULL,				N'all'),
	(0,3,N'All',	N'CreatedById = Me',N'documents/revenue-recognition-vouchers'),
	(1,3,N'Update',	N'Agent/UserId = Me or (AgentId = Null and AssigneeId = Me)', -- requires specifying the safe in the header
										N'documents/cash-payment-vouchers'),
	(2,3,N'Update',	N'Agent/UserId = Me or (AgentId = Null and AssigneeId = Me)', -- requires specifying the safe in the header
										N'documents/cash-receipt-vouchers'),
	(0,4,N'All',	NULL,				N'documents/manual-journal-vouchers'),
	(1,4,N'All',	NULL,				N'documents/cash-payment-vouchers'),
	(2,4,N'All',	NULL,				N'documents/revenue-recognition-vouchers'),
	(3,4,N'Read',	NULL,				N'accounts'),
	(0,5,N'Update',	N'Agent/UserId = Me or (AgentId = Null and AssigneeId = Me)', -- requires specifying the safe in the header
										N'documents/cash-payment-vouchers'),
	(1,5,N'All',	N'Agent/UserId = Me or AssigneeId = Me',
										N'documents/cash-receipt-vouchers'),
	(2,5,N'Update', NULL,				N'contracts/suppliers'),

	(0,9,N'Read',	NULL,				N'contracts/cash-custodians'),
	(1,9,N'Read',	NULL,				N'centers'),
	(2,9,N'Read',	NULL,				N'currencies'),
	(3,9,N'Update',	N'CreatedById = Me',N'documents/cash-payment-vouchers'),
	(4,9,N'Read',	NULL,				N'resources/employee-benefits-expenses'),
	(5,9,N'Read',	NULL,				N'entry-types'),
	(6,9,N'Read',	NULL,				N'lookups/it-equipment-manufacturers'),
	(7,9,N'Read',	NULL,				N'units'),
	(8,9,N'Read',	NULL,				N'lookups/operating-systems'),
	(9,9,N'Read',	NULL,				N'centers'),
	(10,9,N'Read',	NULL,				N'resources/services-expenses'),
	(11,9,N'Read',	NULL,				N'roles'),
	(12,9,N'Read',	NULL,				N'contracts/suppliers'),
	(13,9,N'Read',	NULL,				N'users');
END

DELETE FROM @Roles WHERE [Name] IN (SELECT [Name] FROM dbo.Roles);
DELETE FROM @Members WHERE [HeaderIndex] NOT IN (SELECT [Index] FROM @Roles);
DELETE FROM @Permissions WHERE [HeaderIndex] NOT IN (SELECT [Index] FROM @Roles);
EXEC dal.Roles__Save
	@Entities = @Roles,
	@Members = @Members,
	@Permissions = @Permissions

DECLARE @1GeneralManager INT, @1Comptroller INT, @1Reader INT, @1AccountManager INT;
SELECT @1Comptroller = [Id] FROM dbo.Roles WHERE [Name] = N'Comptroller';
SELECT @1GeneralManager = [Id] FROM dbo.Roles WHERE [Name] = N'General Manager';
SELECT @1Reader = [Id] FROM dbo.Roles WHERE [Name] = N'Reader';
SELECT @1AccountManager = [Id] FROM dbo.Roles WHERE [Name] = N'Account Manager';