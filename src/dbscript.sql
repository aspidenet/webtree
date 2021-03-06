USE [web3]
GO
/****** Object:  User [web3]    Script Date: 09/10/2020 12:08:24 ******/
CREATE USER [web3] FOR LOGIN [web3] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [web3]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CSVToTable]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- select * from fn_CSVToTable('', ',')
create FUNCTION [dbo].[fn_CSVToTable] ( @StringInput VARCHAR(8000), @Delimiter nvarchar(1))
RETURNS @OutputTable TABLE ( String VARCHAR(MAX) )
AS
BEGIN

    DECLARE @String    VARCHAR(10)

    WHILE LEN(@StringInput) > 0
    BEGIN
        SET @String      = LEFT(@StringInput, 
                                ISNULL(NULLIF(CHARINDEX(@Delimiter, @StringInput) - 1, -1),
                                LEN(@StringInput)))
        SET @StringInput = SUBSTRING(@StringInput,
                                     ISNULL(NULLIF(CHARINDEX(@Delimiter, @StringInput), 0),
                                     LEN(@StringInput)) + 1, LEN(@StringInput))

        INSERT INTO @OutputTable ( [String] )
        VALUES ( RTRIM(LTRIM(@String)) )
    END

    RETURN
END
GO
/****** Object:  Table [dbo].[Users]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[username] [varchar](50) NOT NULL,
	[password] [varchar](50) NOT NULL,
	[flag_admin] [char](1) NOT NULL,
	[flag_active] [char](1) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Registries]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Registries](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[registry_code] [varchar](50) NOT NULL,
	[registry_type] [varchar](50) NOT NULL,
	[person_surname] [varchar](50) NOT NULL,
	[person_name] [varchar](50) NOT NULL,
	[company_name] [varchar](250) NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_Registries] PRIMARY KEY CLUSTERED 
(
	[registry_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RelUserRegistry]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RelUserRegistry](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[master_code] [varchar](50) NOT NULL,
	[slave_code] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_Users]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_Users]
AS
SELECT        dbo.Users.username, dbo.Users.flag_admin, dbo.Registries.person_surname, dbo.Registries.person_name, dbo.Registries.company_name, dbo.Users.flag_active, 
                         dbo.Users.ident AS user_id, dbo.Registries.ident AS registry_id
FROM            dbo.Registries RIGHT OUTER JOIN
                         dbo.RelUserRegistry ON dbo.Registries.registry_code = dbo.RelUserRegistry.slave_code RIGHT OUTER JOIN
                         dbo.Users ON dbo.RelUserRegistry.master_code = dbo.Users.username
GO
/****** Object:  Table [dbo].[Groups]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Groups](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[group_code] [varchar](50) NOT NULL,
	[label0] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_Groups] PRIMARY KEY CLUSTERED 
(
	[group_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RelUserGroup]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RelUserGroup](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[master_code] [varchar](50) NOT NULL,
	[slave_code] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_RelUserGroup] PRIMARY KEY CLUSTERED 
(
	[master_code] ASC,
	[slave_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_UsersGroups]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create VIEW [dbo].[vw_UsersGroups]
AS
	SELECT g.*, u.username       
	FROM groups g
	JOIN dbo.RelUserGroup ug ON ug.slave_code = g.group_code 
	JOIN dbo.Users u ON ug.master_code = u.username
GO
/****** Object:  Table [dbo].[Actions]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Actions](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[action_code] [varchar](50) NOT NULL,
	[label0] [varchar](50) NOT NULL,
	[module_code] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
	[dynamic] [bit] NOT NULL,
 CONSTRAINT [PK_Actions] PRIMARY KEY CLUSTERED 
(
	[action_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Menus]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Menus](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[menu_code] [varchar](50) NOT NULL,
	[label0] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
	[link] [varchar](250) NULL,
	[icon] [varchar](50) NULL,
	[module_code] [varchar](50) NULL,
 CONSTRAINT [PK_Menus] PRIMARY KEY CLUSTERED 
(
	[menu_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MetaClassLevels]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaClassLevels](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[classlevel] [int] NOT NULL,
	[classtype_code] [varchar](50) NOT NULL,
	[label0] [varchar](100) NOT NULL,
	[flag_alphanumeric] [char](1) NOT NULL,
	[flag_enabled] [char](1) NOT NULL,
	[flag_reset] [char](1) NOT NULL,
	[len_alphacode] [int] NOT NULL,
	[flag_active] [char](1) NOT NULL,
	[note] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MetaClassNodeAddFields]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaClassNodeAddFields](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[node_code] [varchar](50) NOT NULL,
	[field_code] [varchar](50) NOT NULL,
	[flag_active] [char](1) NOT NULL,
	[note] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MetaClassNodes]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaClassNodes](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[node_code] [varchar](50) NOT NULL,
	[parent_code] [varchar](50) NOT NULL,
	[classtype_code] [varchar](50) NOT NULL,
	[label0] [varchar](100) NOT NULL,
	[classlevel] [int] NOT NULL,
	[flag_active] [char](1) NOT NULL,
	[note] [text] NULL,
	[icon] [varchar](50) NULL,
	[sorting] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MetaClassTemplates]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaClassTemplates](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[classtype_code] [varchar](50) NOT NULL,
	[template_code] [varchar](50) NOT NULL,
	[flag_mandatory] [char](1) NOT NULL,
	[flag_primary] [char](1) NOT NULL,
	[flag_firsttab] [char](1) NOT NULL,
	[sorting] [int] NOT NULL,
	[flag_active] [char](1) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MetaClassTypeAddFields]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaClassTypeAddFields](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[classtype_code] [varchar](50) NOT NULL,
	[field_code] [varchar](50) NOT NULL,
	[flag_active] [char](1) NOT NULL,
	[note] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MetaClassTypes]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaClassTypes](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[classtype_code] [varchar](50) NOT NULL,
	[label0] [varchar](1000) NOT NULL,
	[flag_active] [char](1) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
	[list] [char](1) NOT NULL,
	[query] [varchar](200) NULL,
	[result_code] [varchar](50) NULL,
	[result_label] [varchar](50) NULL,
 CONSTRAINT [PK_MetaClassTypes] PRIMARY KEY CLUSTERED 
(
	[classtype_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MetaFields]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaFields](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[field_code] [varchar](50) NOT NULL,
	[template_code] [varchar](50) NOT NULL,
	[dbfield] [varchar](50) NOT NULL,
	[label0] [varchar](1000) NOT NULL,
	[sorting] [int] NOT NULL,
	[format_code] [varchar](50) NULL,
	[flag_ins_visible] [char](1) NOT NULL,
	[flag_ins_mandatory] [char](1) NOT NULL,
	[flag_ins_modifiable] [char](1) NOT NULL,
	[flag_upd_visible] [char](1) NOT NULL,
	[flag_upd_mandatory] [char](1) NOT NULL,
	[flag_upd_modifiable] [char](1) NOT NULL,
	[list_code] [varchar](50) NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
	[classtype_code] [varchar](50) NULL,
	[help0] [varchar](1000) NULL,
	[default_value] [varchar](200) NULL,
 CONSTRAINT [PK_MetaFields] PRIMARY KEY CLUSTERED 
(
	[field_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MetaRelations]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaRelations](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[relation_code] [varchar](50) NOT NULL,
	[master_code] [varchar](50) NOT NULL,
	[slave_code] [varchar](50) NOT NULL,
	[label0] [varchar](100) NOT NULL,
	[sorting] [int] NOT NULL,
	[dbview] [varchar](250) NOT NULL,
	[dbtable] [varchar](250) NULL,
	[flag_ins_visible] [char](1) NOT NULL,
	[flag_ins_mandatory] [char](1) NOT NULL,
	[flag_ins_modifiable] [char](1) NOT NULL,
	[flag_upd_visible] [char](1) NOT NULL,
	[flag_upd_mandatory] [char](1) NOT NULL,
	[flag_upd_modifiable] [char](1) NOT NULL,
	[cardinality_min] [int] NOT NULL,
	[cardinality_max] [int] NOT NULL,
	[flag_active] [char](1) NOT NULL,
	[flag_can_create] [bit] NOT NULL,
	[flag_can_link] [bit] NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
	[code_dbfield] [varchar](50) NULL,
	[master_dbfield] [varchar](50) NULL,
	[slave_dbfield] [varchar](50) NULL,
	[readonly] [char](1) NOT NULL,
	[recordset_code] [varchar](50) NULL,
	[nosave] [bit] NOT NULL,
 CONSTRAINT [PK_MetaRelations] PRIMARY KEY CLUSTERED 
(
	[relation_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MetaTemplates]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaTemplates](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[template_code] [varchar](50) NOT NULL,
	[label0] [varchar](100) NOT NULL,
	[dbtable] [varchar](150) NOT NULL,
	[dbview] [varchar](250) NOT NULL,
	[dbkey] [varchar](50) NOT NULL,
	[dblabel] [varchar](50) NULL,
	[icon] [varchar](50) NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
	[recordset_code] [varchar](50) NULL,
	[type] [varchar](10) NOT NULL,
 CONSTRAINT [PK_MetaTemplates] PRIMARY KEY CLUSTERED 
(
	[template_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MetaWizards]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetaWizards](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[wizard_code] [varchar](50) NOT NULL,
	[label0] [varchar](100) NOT NULL,
	[dbview] [varchar](50) NOT NULL,
	[template_code] [varchar](50) NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_MetaWizards] PRIMARY KEY CLUSTERED 
(
	[wizard_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Modules]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Modules](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[module_code] [varchar](50) NOT NULL,
	[label0] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_Modules] PRIMARY KEY CLUSTERED 
(
	[module_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Params]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Params](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[code] [varchar](50) NOT NULL,
	[code_procedure] [varchar](50) NOT NULL,
	[dbparam] [varchar](200) NOT NULL,
	[label0] [varchar](200) NOT NULL,
	[sorting] [int] NOT NULL,
	[type] [varchar](50) NOT NULL,
	[fl_optional] [bit] NOT NULL,
	[help_short] [varchar](255) NULL,
	[help_long] [varchar](6000) NULL,
	[code_list] [varchar](50) NULL,
	[source_type] [char](1) NOT NULL,
	[source_code] [varchar](500) NULL,
	[result_value] [varchar](200) NULL,
	[result_label] [varchar](200) NULL,
	[default_value] [varchar](200) NULL,
	[group_value] [varchar](200) NULL,
	[group_label] [varchar](200) NULL,
	[fl_group] [bit] NOT NULL,
	[fl_invisible] [bit] NOT NULL,
	[fl_showvalues] [bit] NOT NULL,
	[fl_showall] [bit] NOT NULL,
	[fl_null] [bit] NOT NULL,
	[fl_multiselect] [bit] NOT NULL,
 CONSTRAINT [PK_MetaParams] PRIMARY KEY CLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Procedures]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Procedures](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[code] [varchar](50) NOT NULL,
	[sp] [varchar](200) NOT NULL,
	[label0] [varchar](200) NULL,
	[label1] [varchar](200) NULL,
	[label2] [varchar](200) NULL,
	[tipo] [char](1) NULL,
	[help_lungo0] [text] NULL,
	[help_lungo1] [text] NULL,
	[help_lungo2] [text] NULL,
	[respammin] [varchar](50) NULL,
	[note] [varchar](500) NULL,
	[release] [varchar](200) NULL,
	[categoria] [varchar](100) NULL,
	[priority] [int] NULL,
	[code_linked] [varchar](50) NULL,
	[spcheck] [varchar](250) NULL,
	[preparam] [char](1) NULL,
	[static] [char](1) NULL,
	[pagesize] [varchar](10) NULL,
	[pageorientation] [char](1) NULL,
	[serverdb] [varchar](50) NULL,
	[code_server] [varchar](50) NULL,
	[icona] [varchar](100) NULL,
	[funzione] [char](1) NOT NULL,
 CONSTRAINT [PK_MetaProcedure] PRIMARY KEY CLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Profiles]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Profiles](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[profile_code] [varchar](50) NOT NULL,
	[module_code] [varchar](50) NOT NULL,
	[role_code] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_Profiles] PRIMARY KEY CLUSTERED 
(
	[profile_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RecordsetColumns]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RecordsetColumns](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[column_code] [varchar](50) NOT NULL,
	[recordset_code] [varchar](50) NOT NULL,
	[dbcolumn] [varchar](50) NOT NULL,
	[label0] [varchar](1000) NOT NULL,
	[sorting] [int] NOT NULL,
	[format_code] [varchar](50) NULL,
	[flag_visible] [char](1) NOT NULL,
	[js_text] [text] NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_RecordsetColumns] PRIMARY KEY CLUSTERED 
(
	[column_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Recordsets]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Recordsets](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[code] [varchar](50) NOT NULL,
	[label0] [varchar](200) NULL,
	[source] [varchar](1000) NULL,
 CONSTRAINT [PK_Recordsets] PRIMARY KEY CLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RelProfileAction]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RelProfileAction](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[profile_code] [varchar](50) NOT NULL,
	[action_code] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_RelProfileAction] PRIMARY KEY CLUSTERED 
(
	[profile_code] ASC,
	[action_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RelProfileMenu]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RelProfileMenu](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[profile_code] [varchar](50) NOT NULL,
	[menu_code] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_RelProfileMenu] PRIMARY KEY CLUSTERED 
(
	[menu_code] ASC,
	[profile_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RelProfileProcedure]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RelProfileProcedure](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[profile_code] [varchar](50) NOT NULL,
	[procedure_code] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_RelProfileProcedure] PRIMARY KEY CLUSTERED 
(
	[procedure_code] ASC,
	[profile_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RelUserProfile]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RelUserProfile](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[code] [varchar](50) NOT NULL,
	[user_code] [varchar](50) NOT NULL,
	[profile_code] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_RelUserProfile] PRIMARY KEY CLUSTERED 
(
	[user_code] ASC,
	[profile_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RelUserProfileVisibility]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RelUserProfileVisibility](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[code] [varchar](50) NULL,
	[userprofile_code] [varchar](50) NOT NULL,
	[visibility_code] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_RelUserProfileVisibility] PRIMARY KEY CLUSTERED 
(
	[userprofile_code] ASC,
	[visibility_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[role_code] [varchar](50) NOT NULL,
	[label0] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[role_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RuleDetails]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RuleDetails](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[rule_code] [varchar](50) NOT NULL,
	[label0] [varchar](100) NOT NULL,
	[help0] [varchar](200) NULL,
	[template_code] [varchar](50) NOT NULL,
	[node_code] [varchar](50) NULL,
	[flag_action] [char](1) NULL,
	[flag_prepost] [varchar](4) NOT NULL,
	[pseudocode] [text] NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
	[severity] [char](1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Rules]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rules](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[rule_code] [varchar](50) NOT NULL,
	[wizard_code] [varchar](50) NULL,
	[label0] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_Rules] PRIMARY KEY CLUSTERED 
(
	[rule_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Visibilities]    Script Date: 09/10/2020 12:08:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Visibilities](
	[ident] [int] IDENTITY(1,1) NOT NULL,
	[visibility_code] [varchar](50) NOT NULL,
	[label0] [varchar](50) NOT NULL,
	[note] [text] NULL,
	[class] [varchar](50) NULL,
 CONSTRAINT [PK_Visibilities] PRIMARY KEY CLUSTERED 
(
	[visibility_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Groups] ON 

INSERT [dbo].[Groups] ([ident], [group_code], [label0], [note], [class]) VALUES (1, N'SYSTEM', N'Amministratori di sistema', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Groups] OFF
GO
SET IDENTITY_INSERT [dbo].[Menus] ON 

INSERT [dbo].[Menus] ([ident], [menu_code], [label0], [note], [class], [link], [icon], [module_code]) VALUES (1, N'WOL', N'Analisi', NULL, NULL, N'/webonline', N'globe', NULL)
SET IDENTITY_INSERT [dbo].[Menus] OFF
GO
SET IDENTITY_INSERT [dbo].[MetaClassLevels] ON 

INSERT [dbo].[MetaClassLevels] ([ident], [classlevel], [classtype_code], [label0], [flag_alphanumeric], [flag_enabled], [flag_reset], [len_alphacode], [flag_active], [note]) VALUES (3, 1, N'FIELDFORMAT', N'Formato', N'S', N'S', N'N', 10, N'S', NULL)
INSERT [dbo].[MetaClassLevels] ([ident], [classlevel], [classtype_code], [label0], [flag_alphanumeric], [flag_enabled], [flag_reset], [len_alphacode], [flag_active], [note]) VALUES (5, 1, N'NOSI', N'No o si', N'S', N'S', N'N', 1, N'S', NULL)
INSERT [dbo].[MetaClassLevels] ([ident], [classlevel], [classtype_code], [label0], [flag_alphanumeric], [flag_enabled], [flag_reset], [len_alphacode], [flag_active], [note]) VALUES (4, 1, N'SINO', N'Si o no', N'S', N'S', N'N', 1, N'S', NULL)
INSERT [dbo].[MetaClassLevels] ([ident], [classlevel], [classtype_code], [label0], [flag_alphanumeric], [flag_enabled], [flag_reset], [len_alphacode], [flag_active], [note]) VALUES (1, 1, N'TIPOANAG', N'Tipologia anagrafe', N'S', N'S', N'N', 6, N'S', NULL)
INSERT [dbo].[MetaClassLevels] ([ident], [classlevel], [classtype_code], [label0], [flag_alphanumeric], [flag_enabled], [flag_reset], [len_alphacode], [flag_active], [note]) VALUES (8, 1, N'TIPOPROCEDURE', N'Tipologia procedura', N'S', N'S', N'N', 1, N'S', NULL)
INSERT [dbo].[MetaClassLevels] ([ident], [classlevel], [classtype_code], [label0], [flag_alphanumeric], [flag_enabled], [flag_reset], [len_alphacode], [flag_active], [note]) VALUES (6, 1, N'TIPOTEMPLATE', N'Tipologia template', N'S', N'S', N'N', 3, N'S', NULL)
INSERT [dbo].[MetaClassLevels] ([ident], [classlevel], [classtype_code], [label0], [flag_alphanumeric], [flag_enabled], [flag_reset], [len_alphacode], [flag_active], [note]) VALUES (10, 1, N'UNOZERO', N'vero o falso', N'N', N'S', N'N', 1, N'S', NULL)
INSERT [dbo].[MetaClassLevels] ([ident], [classlevel], [classtype_code], [label0], [flag_alphanumeric], [flag_enabled], [flag_reset], [len_alphacode], [flag_active], [note]) VALUES (11, 1, N'WOLCATEG', N'Categorie WOL', N'S', N'S', N'N', 10, N'S', NULL)
INSERT [dbo].[MetaClassLevels] ([ident], [classlevel], [classtype_code], [label0], [flag_alphanumeric], [flag_enabled], [flag_reset], [len_alphacode], [flag_active], [note]) VALUES (9, 1, N'ZEROUNO', N'falso o vero', N'N', N'S', N'N', 1, N'S', NULL)
SET IDENTITY_INSERT [dbo].[MetaClassLevels] OFF
GO
SET IDENTITY_INSERT [dbo].[MetaClassNodes] ON 

INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (18, N'0', N'root', N'UNOZERO', N'falso', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (15, N'0', N'root', N'ZEROUNO', N'falso', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (17, N'1', N'root', N'UNOZERO', N'vero', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (16, N'1', N'root', N'ZEROUNO', N'vero', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (21, N'CDC', N'root', N'WOLCATEG', N'Centri di costo', 1, N'S', NULL, N'block layout', 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (22, N'CHECK', N'root', N'WOLCATEG', N'Check', 1, N'S', NULL, N'tasks', 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (5, N'CODE', N'root', N'FIELDFORMAT', N'Codice di sistema', 1, N'S', NULL, NULL, 99)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (14, N'D', N'root', N'TIPOPROCEDURE', N'dashboard', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (24, N'DATE', N'root', N'FIELDFORMAT', N'Data', 1, N'S', NULL, NULL, 2)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (26, N'FILE', N'root', N'FIELDFORMAT', N'File', 1, N'S', NULL, NULL, 4)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (4, N'INT', N'root', N'FIELDFORMAT', N'Intero', 1, N'S', NULL, NULL, 1)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (25, N'LINK', N'root', N'FIELDFORMAT', N'Link (collegamento ipertestuale)', 1, N'S', NULL, NULL, 3)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (9, N'N', N'root', N'NOSI', N'no', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (8, N'N', N'root', N'SINO', N'no', 1, N'S', NULL, NULL, 1)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (12, N'NAV', N'root', N'TIPOTEMPLATE', N'navigazione', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (23, N'NUMERIC', N'root', N'FIELDFORMAT', N'Numero', 1, N'S', NULL, NULL, 1)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (19, N'PATRIM', N'root', N'WOLCATEG', N'Patrimonio edilizio', 1, N'S', NULL, N'city', 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (1, N'PERFIS', N'root', N'TIPOANAG', N'Persona fisica', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (2, N'PERGIU', N'root', N'TIPOANAG', N'Persona giuridica', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (20, N'PERSO', N'root', N'WOLCATEG', N'Personale', 1, N'S', NULL, N'users', 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (6, N'PSWD', N'root', N'FIELDFORMAT', N'Password', 1, N'S', NULL, NULL, 99)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (10, N'S', N'root', N'NOSI', N'si', 1, N'S', NULL, NULL, 2)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (7, N'S', N'root', N'SINO', N'si', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (11, N'SYS', N'root', N'TIPOTEMPLATE', N'sistema', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (3, N'TEXT', N'root', N'FIELDFORMAT', N'Testo', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (13, N'X', N'root', N'TIPOPROCEDURE', N'estrazione', 1, N'S', NULL, NULL, 0)
INSERT [dbo].[MetaClassNodes] ([ident], [node_code], [parent_code], [classtype_code], [label0], [classlevel], [flag_active], [note], [icon], [sorting]) VALUES (27, N'TEST', N'root', N'WOLCATEG', N'Analisi Test', 1, N'S', NULL, NULL, 99)
SET IDENTITY_INSERT [dbo].[MetaClassNodes] OFF
GO
SET IDENTITY_INSERT [dbo].[MetaClassTypes] ON 

INSERT [dbo].[MetaClassTypes] ([ident], [classtype_code], [label0], [flag_active], [note], [class], [list], [query], [result_code], [result_label]) VALUES (2, N'FIELDFORMAT', N'Formato del campo', N'S', NULL, NULL, N'N', NULL, NULL, NULL)
INSERT [dbo].[MetaClassTypes] ([ident], [classtype_code], [label0], [flag_active], [note], [class], [list], [query], [result_code], [result_label]) VALUES (4, N'NOSI', N'No o si', N'S', NULL, NULL, N'N', NULL, NULL, NULL)
INSERT [dbo].[MetaClassTypes] ([ident], [classtype_code], [label0], [flag_active], [note], [class], [list], [query], [result_code], [result_label]) VALUES (3, N'SINO', N'Si o no', N'S', NULL, NULL, N'N', NULL, NULL, NULL)
INSERT [dbo].[MetaClassTypes] ([ident], [classtype_code], [label0], [flag_active], [note], [class], [list], [query], [result_code], [result_label]) VALUES (1, N'TIPOANAG', N'Tipologia anagrafe', N'S', NULL, NULL, N'N', NULL, NULL, NULL)
INSERT [dbo].[MetaClassTypes] ([ident], [classtype_code], [label0], [flag_active], [note], [class], [list], [query], [result_code], [result_label]) VALUES (6, N'TIPOPROCEDURE', N'Tipologia procedura', N'S', NULL, NULL, N'N', NULL, NULL, NULL)
INSERT [dbo].[MetaClassTypes] ([ident], [classtype_code], [label0], [flag_active], [note], [class], [list], [query], [result_code], [result_label]) VALUES (5, N'TIPOTEMPLATE', N'Tipologia template', N'S', NULL, NULL, N'N', NULL, NULL, NULL)
INSERT [dbo].[MetaClassTypes] ([ident], [classtype_code], [label0], [flag_active], [note], [class], [list], [query], [result_code], [result_label]) VALUES (9, N'UNOZERO', N'vero o falso', N'S', NULL, NULL, N'N', NULL, NULL, NULL)
INSERT [dbo].[MetaClassTypes] ([ident], [classtype_code], [label0], [flag_active], [note], [class], [list], [query], [result_code], [result_label]) VALUES (10, N'WOLCATEG', N'Categorie WOL', N'S', NULL, NULL, N'N', NULL, NULL, NULL)
INSERT [dbo].[MetaClassTypes] ([ident], [classtype_code], [label0], [flag_active], [note], [class], [list], [query], [result_code], [result_label]) VALUES (7, N'ZEROUNO', N'falso o vero', N'S', NULL, NULL, N'N', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[MetaClassTypes] OFF
GO
SET IDENTITY_INSERT [dbo].[MetaFields] ON 

INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (135, N'DOCUMENTO_autore', N'DOCUMENTO', N'autore', N'Autore', 1, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (16, N'GROUP_GROUP_CODE', N'GROUP', N'group_code', N'Codice gruppo', 1, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (18, N'GROUP_GROUP_LABEL', N'GROUP', N'label0', N'Etichetta gruppo', 2, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (160, N'MENU_icon', N'MENU', N'icon', N'Icona', 40, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (158, N'MENU_label0', N'MENU', N'label0', N'Voce del menu', 20, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (159, N'MENU_link', N'MENU', N'link', N'URL', 30, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (157, N'MENU_menu_code', N'MENU', N'menu_code', N'Codice', 10, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (116, N'METAPARAMS_code', N'METAPARAMS', N'code', N'Codice', 0, N'CODE', N'S', N'N', N'S', N'S', N'N', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (117, N'METAPARAMS_dbparam', N'METAPARAMS', N'dbparam', N'Nome del parametro', 2, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (125, N'METAPARAMS_fl_group', N'METAPARAMS', N'fl_group', N'I dati possono essere raggruppati', 50, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, N'ZEROUNO', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (131, N'METAPARAMS_fl_multiselect', N'METAPARAMS', N'fl_multiselect', N'Flag multiselect', 60, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, N'ZEROUNO', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (126, N'METAPARAMS_group_label', N'METAPARAMS', N'group_label', N'Campo con l''etichetta del raggruppamento', 52, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (127, N'METAPARAMS_group_value', N'METAPARAMS', N'group_value', N'Campo che identifica il codice del raggruppamento', 51, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (118, N'METAPARAMS_label0', N'METAPARAMS', N'label0', N'Etichetta', 3, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (130, N'METAPARAMS_result_label', N'METAPARAMS', N'result_label', N'Campo del risultato che rappresenta l''ETICHETTA', 41, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (129, N'METAPARAMS_result_value', N'METAPARAMS', N'result_value', N'Campo del risultato che rappresenta il CODICE', 40, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (119, N'METAPARAMS_sorting', N'METAPARAMS', N'sorting', N'Ordine', 0, N'INT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (128, N'METAPARAMS_source_code', N'METAPARAMS', N'source_code', N'Codice SQL sorgente', 2, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (122, N'METAPARAMS_type', N'METAPARAMS', N'type', N'Tipo', 1, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (83, N'METAPROCEDURES_categoria', N'METAPROCEDURES', N'categoria', N'Categoria', 4, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (84, N'METAPROCEDURES_code', N'METAPROCEDURES', N'code', N'Codice', 0, N'CODE', N'N', N'S', N'S', N'N', N'N', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (156, N'METAPROCEDURES_funzione', N'METAPROCEDURES', N'funzione', N'E'' una funzione?', 1000, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'NOSI', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (82, N'METAPROCEDURES_help_lungo0', N'METAPROCEDURES', N'help_lungo0', N'Help lungo', 5, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (80, N'METAPROCEDURES_label0', N'METAPROCEDURES', N'label0', N'Etichetta', 2, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (85, N'METAPROCEDURES_note', N'METAPROCEDURES', N'note', N'Note', 99, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (79, N'METAPROCEDURES_sp', N'METAPROCEDURES', N'sp', N'Procedura', 3, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (81, N'METAPROCEDURES_tipo', N'METAPROCEDURES', N'tipo', N'Tipo di  procedura', 1, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'TIPOPROCEDURE', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (143, N'MODULE_label0', N'MODULE', N'label0', N'Etichetta', 2, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (142, N'MODULE_module_code', N'MODULE', N'module_code', N'Codice', 1, N'TEXT', N'S', N'S', N'S', N'S', N'N', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (144, N'MODULE_note', N'MODULE', N'note', N'Note', 3, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (154, N'PROFILE_module_code', N'PROFILE', N'module_code', N'Codice del modulo', 20, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (153, N'PROFILE_profile_code', N'PROFILE', N'profile_code', N'Codice profilo', 10, N'TEXT', N'S', N'S', N'S', N'S', N'N', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (155, N'PROFILE_role_code', N'PROFILE', N'role_code', N'Codice del ruolo', 30, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (12, N'REGISTRY_CODE', N'REGISTRY', N'registry_code', N'Codice anagrafica', 20, N'TEXT', N'S', N'S', N'S', N'S', N'N', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (10, N'REGISTRY_NAME', N'REGISTRY', N'person_name', N'Nome', 40, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (14, N'REGISTRY_NOTE', N'REGISTRY', N'note', N'Note', 50, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (138, N'REGISTRY_registry_type', N'REGISTRY', N'registry_type', N'Tipo anagrafica', 10, N'TEXT', N'S', N'S', N'S', N'S', N'N', N'N', NULL, NULL, NULL, N'TIPOANAG', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (9, N'REGISTRY_SURNAME', N'REGISTRY', N'person_surname', N'Cognome', 30, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (140, N'ROLE_label0', N'ROLE', N'label0', N'Etichetta', 20, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (141, N'ROLE_note', N'ROLE', N'note', N'Note', 30, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (139, N'ROLE_role_code', N'ROLE', N'role_code', N'Codice', 10, N'TEXT', N'S', N'S', N'S', N'S', N'N', N'N', NULL, NULL, NULL, NULL, N'Codice univoco del ruolo', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (72, N'SYSCOLUMNS_COLUMNS_CODE', N'SYSCOLUMNS', N'column_code', N'Codice', 1, N'TEXT', N'S', N'S', N'S', N'S', N'N', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (74, N'SYSCOLUMNS_DBCOLUMN', N'SYSCOLUMNS', N'dbcolumn', N'Colonna db', 3, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (78, N'SYSCOLUMNS_FLAG_VISIBLE', N'SYSCOLUMNS', N'flag_visible', N'Visibile', 7, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'SINO', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (77, N'SYSCOLUMNS_FORMAT_CODE', N'SYSCOLUMNS', N'format_code', N'Formato', 6, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'FIELDFORMAT', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (75, N'SYSCOLUMNS_LABEL0', N'SYSCOLUMNS', N'label0', N'Etichetta', 4, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (73, N'SYSCOLUMNS_RECORDSET_CODE', N'SYSCOLUMNS', N'recordset_code', N'Recordset', 2, N'TEXT', N'S', N'S', N'S', N'S', N'N', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (76, N'SYSCOLUMNS_SORTING', N'SYSCOLUMNS', N'sorting', N'Ordinamento', 5, N'INT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (67, N'SYSFIELDS_CLASS', N'SYSFIELDS', N'class', N'PHP Class', 22, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (124, N'SYSFIELDS_classtype_code', N'SYSFIELDS', N'classtype_code', N'Codice albero/lista/classificazione', 10, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (55, N'SYSFIELDS_DBFIELD', N'SYSFIELDS', N'dbfield', N'Campo corrispondente sul DB', 5, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (52, N'SYSFIELDS_FIELD_CODE', N'SYSFIELDS', N'field_code', N'Codice del campo', 1, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (60, N'SYSFIELDS_FLAG_INS_MANDATORY', N'SYSFIELDS', N'flag_ins_mandatory', N'Flag obbligatorio - Insert', 12, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'NOSI', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (61, N'SYSFIELDS_FLAG_INS_MODIFIABLE', N'SYSFIELDS', N'flag_ins_modifiable', N'Flag modificabile - Insert', 11, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'SINO', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (58, N'SYSFIELDS_FLAG_INS_VISIBLE', N'SYSFIELDS', N'flag_ins_visible', N'Flag visibile - Insert', 10, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'SINO', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (63, N'SYSFIELDS_FLAG_UPD_MANDATORY', N'SYSFIELDS', N'flag_upd_mandatory', N'Flag obbligatorio - Update', 15, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'NOSI', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (64, N'SYSFIELDS_FLAG_UPD_MODIFIABLE', N'SYSFIELDS', N'flag_upd_modifiable', N'Flag modificabile - Update', 14, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'SINO', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (62, N'SYSFIELDS_FLAG_UPD_VISIBLE', N'SYSFIELDS', N'flag_upd_visible', N'Flag visibile - Update', 13, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'SINO', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (57, N'SYSFIELDS_FORMAT_CODE', N'SYSFIELDS', N'format_code', N'Formato', 6, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, N'FIELDFORMAT', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (132, N'SYSFIELDS_help0', N'SYSFIELDS', N'help0', N'Help', 4, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (54, N'SYSFIELDS_LABEL0', N'SYSFIELDS', N'label0', N'Etichetta del campo', 3, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (66, N'SYSFIELDS_NOTE', N'SYSFIELDS', N'note', N'Note', 21, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (56, N'SYSFIELDS_SORTING', N'SYSFIELDS', N'sorting', N'Ordine', 5, N'INT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (53, N'SYSFIELDS_TEMPLATE_CODE', N'SYSFIELDS', N'template_code', N'Codice template', 2, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (69, N'SYSRECORDSETS_CODE', N'SYSRECORDSETS', N'code', N'Code', 1, N'TEXT', N'S', N'S', N'S', N'S', N'N', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (70, N'SYSRECORDSETS_LABEL0', N'SYSRECORDSETS', N'label0', N'Etichetta', 2, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (71, N'SYSRECORDSETS_SOURCE', N'SYSRECORDSETS', N'source', N'Sorgente', 3, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (107, N'SYSRELATION_cardinality_max', N'SYSRELATION', N'cardinality_max', N'Cardinalità massima', 120, N'INT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (106, N'SYSRELATION_cardinality_min', N'SYSRELATION', N'cardinality_min', N'Cardinalità minima', 110, N'INT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (152, N'SYSRELATION_code_dbfield', N'SYSRELATION', N'code_dbfield', N'Campo codice della relazione', 80, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, N'E'' il campo sul db che identifica, se presente, il codice della relazione che per default è la concatenazione tra campo master e campo slave se non diversamente indicato.', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (105, N'SYSRELATION_dbtable', N'SYSRELATION', N'dbtable', N'Tabella', 60, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (104, N'SYSRELATION_dbview', N'SYSRELATION', N'dbview', N'Vista', 70, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (133, N'SYSRELATION_flag_can_create', N'SYSRELATION', N'flag_can_create', N'Si possono creare nuovi oggetti?', 210, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'UNOZERO', N'Se VERO, la maschera della relazione mosta il campo "NUOVO" e si potrà creare un nuovo oggetto. Se FALSO, non si possono creare nuovi oggetti.', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (134, N'SYSRELATION_flag_can_link', N'SYSRELATION', N'flag_can_link', N'Si possono associare oggetti?', 220, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'UNOZERO', N'Se VERO, nella maschera della relazione è presente il tasto ASSOCIA che permette di collegare un oggetto già creato. Se FALSO, non è possibile collegare oggetti già creati.', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (146, N'SYSRELATION_flag_ins_mandatory', N'SYSRELATION', N'flag_ins_mandatory', N'E'' obbligatorio inserire questa relazione in fase di inserimento?', 160, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, N'NOSI', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (148, N'SYSRELATION_flag_ins_modifiable', N'SYSRELATION', N'flag_ins_modifiable', N'Relazione modificabile in fase di creazione?', 170, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, N'NOSI', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (145, N'SYSRELATION_flag_ins_visible', N'SYSRELATION', N'flag_ins_visible', N'Visibile in fase di inserimento?', 150, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, N'NOSI', N'Durante la creazione dell''oggetto principale, questa relazione deve essere visibile?', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (150, N'SYSRELATION_flag_upd_mandatory', N'SYSRELATION', N'flag_upd_mandatory', N'E'' obbligatoria in fase di modifica?', 190, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, N'NOSI', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (151, N'SYSRELATION_flag_upd_modifiable', N'SYSRELATION', N'flag_upd_modifiable', N'E'' modificabile in fase di modifica?', 200, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, N'NOSI', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (149, N'SYSRELATION_flag_upd_visible', N'SYSRELATION', N'flag_upd_visible', N'Visibile in modifica?', 180, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, N'NOSI', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (102, N'SYSRELATION_label0', N'SYSRELATION', N'label0', N'Etichetta', 40, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (100, N'SYSRELATION_master_code', N'SYSRELATION', N'master_code', N'Template master', 20, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (113, N'SYSRELATION_master_dbfield', N'SYSRELATION', N'master_dbfield', N'Nome del campo chiave padre nella relazione', 90, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (147, N'SYSRELATION_readonly', N'SYSRELATION', N'readonly', N'Sola lettura?', 130, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, N'ZEROUNO', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (115, N'SYSRELATION_recordset_code', N'SYSRELATION', N'recordset_code', N'Codice del recordset per la visualizzazione', 140, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (99, N'SYSRELATION_relation_code', N'SYSRELATION', N'relation_code', N'Codice', 10, N'TEXT', N'S', N'S', N'S', N'S', N'N', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (101, N'SYSRELATION_slave_code', N'SYSRELATION', N'slave_code', N'Template slave', 30, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (114, N'SYSRELATION_slave_dbfield', N'SYSRELATION', N'slave_dbfield', N'Nome del campo chiave figlio nella relazione', 100, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (103, N'SYSRELATION_sorting', N'SYSRELATION', N'sorting', N'Ordine', 50, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (36, N'SYSTEMPLATE_CLASS', N'SYSTEMPLATE', N'class', N'PHP Class', 9, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (32, N'SYSTEMPLATE_DBKEY', N'SYSTEMPLATE', N'dbkey', N'Chiave sul DB', 5, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, N'Campo nella tabella che rappresenta la CHIAVE univoca del record.', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (33, N'SYSTEMPLATE_DBLABEL', N'SYSTEMPLATE', N'dblabel', N'Etichetta del campo sul DB', 6, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, N'Campo nella tabella che rappresenta l''etichetta del record.', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (30, N'SYSTEMPLATE_DBTABLE', N'SYSTEMPLATE', N'dbtable', N'Tabella sul DB', 3, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, N'Nome della tabella dove vengono memorizzati i dati del template.', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (31, N'SYSTEMPLATE_DBVIEW', N'SYSTEMPLATE', N'dbview', N'Vista', 4, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, NULL, N'Nome della vista usata in lettura. Se non presente, indicare il nome della tabella.', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (34, N'SYSTEMPLATE_ICON', N'SYSTEMPLATE', N'icon', N'Icona', 7, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (29, N'SYSTEMPLATE_LABEL0', N'SYSTEMPLATE', N'label0', N'Etichetta del template', 2, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (35, N'SYSTEMPLATE_NOTE', N'SYSTEMPLATE', N'note', N'Note', 8, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (109, N'SYSTEMPLATE_recordset_code', N'SYSTEMPLATE', N'recordset_code', N'Recordset', 80, N'TEXT', N'S', N'N', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, N'Inserire qui il RECORDSET legato a questo template che mostra i campi opportunamente configurati all''interno di un elenco.', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (28, N'SYSTEMPLATE_TEMPLATE_CODE', N'SYSTEMPLATE', N'template_code', N'Codice template', 1, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'N', NULL, NULL, NULL, NULL, N'Codice UNIVOCO del template.', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (108, N'SYSTEMPLATE_type', N'SYSTEMPLATE', N'type', N'Tipologia', 0, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'TIPOTEMPLATE', N'Se NAVIGAZIONE viene usato nel modulo "Navigazioni", SISTEMA altrimenti.', NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (137, N'USER_flag_active', N'USER', N'flag_active', N'Utente attivo', 30, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'SINO', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (136, N'USER_flag_admin', N'USER', N'flag_admin', N'Utente amministratore', 40, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'S', NULL, NULL, NULL, N'NOSI', NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (2, N'USER_PASSWORD', N'USER', N'password', N'Password', 20, N'PSWD', N'S', N'S', N'S', N'S', N'N', N'S', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[MetaFields] ([ident], [field_code], [template_code], [dbfield], [label0], [sorting], [format_code], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [list_code], [note], [class], [classtype_code], [help0], [default_value]) VALUES (1, N'USER_USERNAME', N'USER', N'username', N'Username', 10, N'TEXT', N'S', N'S', N'S', N'S', N'S', N'N', NULL, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[MetaFields] OFF
GO
SET IDENTITY_INSERT [dbo].[MetaRelations] ON 

INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (17, N'EDIFICIO-AULA', N'EDIFICIOX', N'AULA', N'Aule', 0, N'REFTREE_TEST_DB.Consolidamento.dbo.REF_VW_AuleAttive', N'REFTREE_TEST_DB.Consolidamento.dbo.REF_VW_AuleAttive', N'S', N'N', N'S', N'S', N'N', N'S', 0, 10000, N'S', 1, 1, NULL, NULL, NULL, N'AS_ASSET_CODE_EDIFICIO', N'AS_ASSET_ID', N'N', NULL, 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (26, N'EDIFICIO-DOCUMENTO', N'EDIFICIO', N'DOCUMENTO', N'Documenti', 30, N'Consolidamento.dbo.NAV_VW_ASSET_DOCUMENTI', N'Consolidamento.dbo.NAV_VW_ASSET_DOCUMENTI', N'S', N'N', N'S', N'S', N'N', N'S', 0, 1000, N'S', 0, 0, NULL, NULL, NULL, N'Code_asset', N'Code_documento', N'N', N'DOCUMENTO', 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (19, N'EDIFICIO-PERSONE', N'EDIFICIO', N'PERSONA', N'Persona', 20, N'Consolidamento.dbo.NAV_VW_Personale_Edifici', N'Consolidamento.dbo.NAV_VW_Personale_Edifici', N'S', N'N', N'S', N'S', N'N', N'S', 0, 10000, N'S', 1, 1, NULL, NULL, NULL, N'codice_edificio', N'matricola', N'N', N'PERSONALE', 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (22, N'EDIFICIO-STRUTTURA', N'EDIFICIO', N'STRUTTURA', N'Struttura', 10, N'Consolidamento.dbo.NAV_VW_Strutture_Edifici', N'Consolidamento.dbo.NAV_VW_Strutture_Edifici', N'S', N'N', N'S', N'S', N'N', N'S', 0, 10000, N'S', 1, 1, NULL, NULL, NULL, N'codice_edificio', N'CodeStruttura', N'N', N'STRUTTURA', 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (24, N'Edificio_DDU', N'DDU', N'edificio', N'Edificio', 0, N'consolidamento.dbo.NAV_VW_CDC_DDU_SottoDDU_Edifici', N'consolidamento.dbo.NAV_VW_CDC_DDU_SottoDDU_Edifici', N'S', N'N', N'S', N'S', N'N', N'S', 0, 10000, N'S', 1, 1, NULL, NULL, NULL, N'codice_ddu', N'codice_edificio', N'N', N'CDC_DDU_EDIFICIO', 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (30, N'MENUPROFILE', N'MENU', N'PROFILE', N'Profili', 10, N'RelProfileMenu', N'RelProfileMenu', N'N', N'N', N'N', N'N', N'N', N'N', 0, 1000, N'S', 0, 1, NULL, NULL, NULL, N'menu_code', N'profile_code', N'1', NULL, 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (25, N'METAPROCPARAM', N'METAPROCEDURES', N'METAPARAMS', N'Parametri', 1, N'MetaParams', N'MetaParams', N'S', N'N', N'S', N'S', N'N', N'S', 0, 1000, N'S', 1, 0, NULL, NULL, NULL, N'code_procedure', N'code', N'N', NULL, 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (19, N'PERSONA-EDIFICIO', N'PERSONA', N'EDIFICIO', N'Edificio', 0, N'Consolidamento.dbo.NAV_VW_Edifici_Personale', N'Consolidamento.dbo.NAV_VW_Edifici_Personale', N'S', N'N', N'S', N'S', N'N', N'S', 0, 10000, N'S', 1, 1, NULL, NULL, NULL, N'matricola', N'codice_edificio', N'N', N'PERSONA-EDIFICIO', 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (19, N'PERSONA-STRUTTURA', N'PERSONA', N'STRUTTURA', N'Struttura', 0, N'Consolidamento.dbo.NAV_VW_Personale_Edifici', N'Consolidamento.dbo.NAV_VW_Personale_Edifici', N'S', N'N', N'S', N'S', N'N', N'S', 0, 10000, N'S', 1, 1, NULL, NULL, NULL, N'matricola', N'CodeStruttura', N'N', N'STRUTTURA', 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (27, N'PROFILE', N'MODULE', N'ROLE', N'Ruoli associati', 10, N'profiles', N'profiles', N'S', N'N', N'S', N'N', N'N', N'S', 0, 1000, N'S', 0, 0, NULL, NULL, N'profile_code', N'module_code', N'role_code', N'0', NULL, 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (29, N'PROFILE-PROCEDURE', N'PROFILE', N'METAPROCEDURES', N'Analisi', 20, N'RelProfileProcedure', N'RelProfileProcedure', N'N', N'N', N'N', N'N', N'N', N'N', 0, 10000, N'S', 0, 1, NULL, NULL, NULL, N'profile_code', N'procedure_code', N'0', NULL, 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (31, N'PROFILEMENU', N'PROFILE', N'MENU', N'Voci di menu', 30, N'RelProfileMenu', N'RelProfileMenu', N'N', N'N', N'N', N'N', N'N', N'N', 0, 1000, N'S', 0, 0, NULL, NULL, NULL, N'profile_code', N'menu_code', N'0', NULL, 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (20, N'STRUTTURA-EDIFICIO', N'STRUTTURA', N'EDIFICIO', N'Edificio', 0, N'Consolidamento.dbo.NAV_VW_Strutture_Edifici', N'Consolidamento.dbo.NAV_VW_Strutture_Edifici', N'S', N'N', N'S', N'S', N'N', N'S', 0, 10000, N'S', 1, 1, NULL, NULL, NULL, N'CodeStruttura', N'codice_edificio', N'N', NULL, 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (21, N'STRUTTURA-PERSONE', N'STRUTTURA', N'PERSONA', N'Persona', 0, N'Consolidamento.dbo.NAV_VW_Personale_Edifici', N'Consolidamento.dbo.NAV_VW_Personale_Edifici', N'S', N'N', N'S', N'S', N'N', N'S', 0, 10000, N'S', 1, 1, NULL, NULL, NULL, N'CodeStruttura', N'matricola', N'N', N'PERSONALE', 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (3, N'SYSTEMPLATE-FIELDS', N'SYSTEMPLATE', N'SYSFIELDS', N'Template-Fields', 1, N'MetaFields', N'MetaFields', N'S', N'S', N'S', N'S', N'S', N'S', 1, 1000, N'S', 1, 0, NULL, NULL, NULL, N'template_code', N'field_code', N'N', NULL, 1)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (2, N'USER-GROUP', N'USER', N'GROUP', N'Utenti-Gruppi', 2, N'vw_UsersGroups', N'RelUserGroup', N'S', N'N', N'S', N'S', N'N', N'S', 0, 1000, N'S', 1, 1, NULL, NULL, NULL, N'username', N'group_code', N'N', NULL, 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (1, N'USER-REGISTRY', N'USER', N'REGISTRY', N'Utenti-Anagrafiche', 1, N'vw_Users', N'RelUserRegistry', N'S', N'S', N'S', N'S', N'S', N'S', 1, 1, N'S', 1, 1, NULL, NULL, NULL, N'master_code', N'slave_code', N'N', NULL, 0)
INSERT [dbo].[MetaRelations] ([ident], [relation_code], [master_code], [slave_code], [label0], [sorting], [dbview], [dbtable], [flag_ins_visible], [flag_ins_mandatory], [flag_ins_modifiable], [flag_upd_visible], [flag_upd_mandatory], [flag_upd_modifiable], [cardinality_min], [cardinality_max], [flag_active], [flag_can_create], [flag_can_link], [note], [class], [code_dbfield], [master_dbfield], [slave_dbfield], [readonly], [recordset_code], [nosave]) VALUES (28, N'USERPROFILE', N'PROFILE', N'USER', N'Utenti', 10, N'RelUserProfile', N'RelUserProfile', N'N', N'N', N'N', N'N', N'N', N'N', 0, 1000, N'S', 0, 0, NULL, NULL, NULL, N'profile_code', N'user_code', N'0', NULL, 0)
SET IDENTITY_INSERT [dbo].[MetaRelations] OFF
GO
SET IDENTITY_INSERT [dbo].[MetaTemplates] ON 

INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (24, N'AULA', N'Aula', N'REFTREE_TEST_DB.Consolidamento.dbo.REF_VW_AuleAttive', N'REFTREE_TEST_DB.Consolidamento.dbo.REF_VW_AuleAttive', N'AS_ASSET_ID', N'ID Asset', NULL, NULL, NULL, NULL, N'NAV')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (31, N'CLASSTYPE', N'Classificazioni/Liste', N'MetaClassTypes', N'MetaClassTypes', N'classtype_code', N'label0', NULL, NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (27, N'DDU', N'DDU', N'Consolidamento.dbo.NAV_VW_DDU', N'Consolidamento.dbo.NAV_VW_DDU', N'codice_ddu', N'ddu', NULL, NULL, NULL, NULL, N'NAV')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (35, N'DOCUMENTO', N'Documento', N'Consolidamento.dbo.TB_REF_DOCUMENTI', N'Consolidamento.dbo.NAV_VW_ASSET_DOCUMENTI', N'code_documento', N'deco_file', NULL, NULL, NULL, N'DOCUMENTO', N'NAV')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (23, N'EDIFICIO', N'Edificio', N'Consolidamento.dbo.NAV_VW_EdificiAttivi', N'Consolidamento.dbo.NAV_VW_EdificiAttivi', N'codice_edificio', N'Codice Edificio', N'building', NULL, N'NAVEdificio', N'EDIFICIO', N'NAV')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (3, N'GROUP', N'Gruppo', N'Groups', N'Groups', N'group_code', NULL, N'users', N'Gruppo', NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (15, N'MAGICUSER', N'Utenti REF', N'Magic_Mmb_Users', N'Magic_Mmb_Users', N'UserID', N'UserID', NULL, NULL, NULL, N'MAGICUSERS', N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (40, N'MENU', N'Menu', N'Menus', N'Menus', N'menu_code', N'label0', NULL, NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (28, N'METAPARAMS', N'Parametro di una procedura', N'MetaParams', N'MetaParams', N'code', N'label0', NULL, N'aaa', NULL, N'METAPARAMS', N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (11, N'METAPROCEDURES', N'Meta Procedure', N'Procedures', N'Procedures', N'code', N'label0', NULL, NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (38, N'MODULE', N'Modulo', N'Modules', N'Modules', N'module_code', N'label0', N'sitemap', NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (25, N'PERSONA', N'Personale', N'Consolidamento.dbo.NAV_VW_Personale_Edifici', N'Consolidamento.dbo.NAV_VW_Personale_Edifici', N'matricola', N'Matricola', N'users', NULL, N'NAVPersona', NULL, N'NAV')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (39, N'PROFILE', N'Profilo', N'Profiles', N'Profiles', N'profile_code', NULL, NULL, NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (19, N'REFGROUP', N'Gruppo Reftree', N'core.US_GROUPS_groups', N'core.US_GROUPS_groups', N'US_GROUPS_ID', N'ID', NULL, NULL, NULL, N'GROUP', N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (2, N'REGISTRY', N'Anagrafica', N'Registries', N'Registries', N'registry_code', N'person_surname', N'address card', N'Anagrafica di sistema', NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (37, N'ROLE', N'Ruoli', N'Roles', N'Roles', N'role_code', N'label0', N'user tag', NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (8, N'RULES', N'Regole template', N'rules', N'rules', N'rule_code', N'label0', N'lex', NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (26, N'STRUTTURA', N'Struttura', N'Consolidamento.dbo.CSA_VW_Strutture', N'Consolidamento.dbo.CSA_VW_Strutture', N'codestruttura', N'decostruttura', N'block layout', NULL, N'NAVStruttura', N'STRUTTURA', N'NAV')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (10, N'SYSCOLUMNS', N'SYS RS Columns', N'RecordsetColumns', N'RecordsetColumns', N'column_code', N'Codice colonna', NULL, NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (6, N'SYSFIELDS', N'SYS Template Fields', N'MetaFields', N'MetaFields', N'field_code', N'label0', N'icona', N'nota', N'phpclasse', NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (9, N'SYSRECORDSETS', N'SYS RecordSets', N'Recordsets', N'Recordsets', N'code', N'label0', N'table', NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (16, N'SYSRELATION', N'Relazione tra templates', N'MetaRelations', N'MetaRelations', N'relation_code', N'Codice', NULL, NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (5, N'SYSTEMPLATE', N'SYS Template', N'MetaTemplates', N'MetaTemplates', N'template_code', N'label0', NULL, NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (1, N'USER', N'Utente', N'Users', N'Users', N'username', N'username', N'user', N'Utente del sistema', NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (12, N'USEROL', N'Ruoli utente', N'core.US_USEROL_User_role', N'core.US_USEROL_User_role', N'US_USEROL_ID', N'US_USEROL_DESCRIPTION', NULL, NULL, NULL, NULL, N'SYS')
INSERT [dbo].[MetaTemplates] ([ident], [template_code], [label0], [dbtable], [dbview], [dbkey], [dblabel], [icon], [note], [class], [recordset_code], [type]) VALUES (36, N'XXXX', N'UUUU', N'groups', N'groups', N'group_code', N'label0', NULL, NULL, NULL, NULL, N'NAV')
SET IDENTITY_INSERT [dbo].[MetaTemplates] OFF
GO
SET IDENTITY_INSERT [dbo].[MetaWizards] ON 

INSERT [dbo].[MetaWizards] ([ident], [wizard_code], [label0], [dbview], [template_code], [note], [class]) VALUES (18, N'MENU', N'Wizard menu', N'Menus', N'MENU', NULL, NULL)
INSERT [dbo].[MetaWizards] ([ident], [wizard_code], [label0], [dbview], [template_code], [note], [class]) VALUES (8, N'METAPROCEDURES', N'Wizard procedure', N'Procedures', N'METAPROCEDURES', NULL, NULL)
INSERT [dbo].[MetaWizards] ([ident], [wizard_code], [label0], [dbview], [template_code], [note], [class]) VALUES (16, N'MODULE', N'Wizard moduli', N'Modules', N'MODULE', NULL, NULL)
INSERT [dbo].[MetaWizards] ([ident], [wizard_code], [label0], [dbview], [template_code], [note], [class]) VALUES (17, N'PROFILE', N'Wizard profili', N'Profiles', N'PROFILE', NULL, NULL)
INSERT [dbo].[MetaWizards] ([ident], [wizard_code], [label0], [dbview], [template_code], [note], [class]) VALUES (15, N'ROLE', N'Wizard ruoli', N'Roles', N'ROLE', NULL, NULL)
INSERT [dbo].[MetaWizards] ([ident], [wizard_code], [label0], [dbview], [template_code], [note], [class]) VALUES (5, N'SYSCOLUMNS', N'Wizard RS Columns', N'RecordsetColumns', N'SYSCOLUMNS', NULL, NULL)
INSERT [dbo].[MetaWizards] ([ident], [wizard_code], [label0], [dbview], [template_code], [note], [class]) VALUES (7, N'SYSFIELDS', N'Wizard fields', N'MetaFields', N'SYSFIELDS', NULL, NULL)
INSERT [dbo].[MetaWizards] ([ident], [wizard_code], [label0], [dbview], [template_code], [note], [class]) VALUES (4, N'SYSRECORDSETS', N'Wizard Recordsets', N'Recordsets', N'SYSRECORDSETS', NULL, NULL)
INSERT [dbo].[MetaWizards] ([ident], [wizard_code], [label0], [dbview], [template_code], [note], [class]) VALUES (10, N'SYSRELATIONS', N'Wizard Relazioni', N'MetaRelations', N'SYSRELATION', NULL, NULL)
INSERT [dbo].[MetaWizards] ([ident], [wizard_code], [label0], [dbview], [template_code], [note], [class]) VALUES (3, N'SYSTEMPLATES', N'Wizard templates', N'MetaTemplates', N'SYSTEMPLATE', NULL, NULL)
INSERT [dbo].[MetaWizards] ([ident], [wizard_code], [label0], [dbview], [template_code], [note], [class]) VALUES (2, N'USERS', N'Wizard utenti', N'Users', N'USER', NULL, NULL)
SET IDENTITY_INSERT [dbo].[MetaWizards] OFF
GO
SET IDENTITY_INSERT [dbo].[Modules] ON 

INSERT [dbo].[Modules] ([ident], [module_code], [label0], [note], [class]) VALUES (1, N'ADMIN', N'Amministrazione', NULL, NULL)
INSERT [dbo].[Modules] ([ident], [module_code], [label0], [note], [class]) VALUES (3, N'REFPERSONALE', N'REF Personale', NULL, NULL)
INSERT [dbo].[Modules] ([ident], [module_code], [label0], [note], [class]) VALUES (4, N'REFUSER', N'REF Utente', NULL, NULL)
INSERT [dbo].[Modules] ([ident], [module_code], [label0], [note], [class]) VALUES (2, N'WOL', N'Analisi', N'nota', NULL)
SET IDENTITY_INSERT [dbo].[Modules] OFF
GO
SET IDENTITY_INSERT [dbo].[Procedures] ON 

INSERT [dbo].[Procedures] ([ident], [code], [sp], [label0], [label1], [label2], [tipo], [help_lungo0], [help_lungo1], [help_lungo2], [respammin], [note], [release], [categoria], [priority], [code_linked], [spcheck], [preparam], [static], [pagesize], [pageorientation], [serverdb], [code_server], [icona], [funzione]) VALUES (1, N'220598626f4bcb1b7cd2064c53c8e4c2', N'PROC_Test_A', N'Analisi Test A', NULL, NULL, N'X', NULL, NULL, NULL, NULL, NULL, NULL, N'TEST', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'N')
INSERT [dbo].[Procedures] ([ident], [code], [sp], [label0], [label1], [label2], [tipo], [help_lungo0], [help_lungo1], [help_lungo2], [respammin], [note], [release], [categoria], [priority], [code_linked], [spcheck], [preparam], [static], [pagesize], [pageorientation], [serverdb], [code_server], [icona], [funzione]) VALUES (2, N'95b88bb068eb80ce9c38e115ef64e187', N'PROC_Test_B', N'Analisi Test B', NULL, NULL, N'X', NULL, NULL, NULL, NULL, NULL, NULL, N'TEST', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'N')
SET IDENTITY_INSERT [dbo].[Procedures] OFF
GO
SET IDENTITY_INSERT [dbo].[Profiles] ON 

INSERT [dbo].[Profiles] ([ident], [profile_code], [module_code], [role_code], [note], [class]) VALUES (5, N'REFPERSONALESUPER', N'REFPERSONALE', N'SUPER', NULL, NULL)
INSERT [dbo].[Profiles] ([ident], [profile_code], [module_code], [role_code], [note], [class]) VALUES (6, N'REFUSEROPERATORE', N'REFUSER', N'OPERATORE', NULL, NULL)
INSERT [dbo].[Profiles] ([ident], [profile_code], [module_code], [role_code], [note], [class]) VALUES (4, N'WOLSUPER', N'WOL', N'SUPER', NULL, NULL)
INSERT [dbo].[Profiles] ([ident], [profile_code], [module_code], [role_code], [note], [class]) VALUES (3, N'WOLVISUAL', N'WOL', N'VISUAL', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Profiles] OFF
GO
SET IDENTITY_INSERT [dbo].[RecordsetColumns] ON 

INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (107, N'METAPARAMS_code', N'METAPARAMS', N'code', N'Codice', 50, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (84, N'METAPARAMS_dbparam', N'METAPARAMS', N'dbparam', N'Nome', 2, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (86, N'METAPARAMS_help_short', N'METAPARAMS', N'help_short', N'Help breve', 30, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (83, N'METAPARAMS_label0', N'METAPARAMS', N'label0', N'Etichetta parametro', 3, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (82, N'METAPARAMS_sorting', N'METAPARAMS', N'sorting', N'Ordine', 1, N'INT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (99, N'METAPARAMS_type', N'METAPARAMS', N'type', N'Tipo', 5, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (106, N'METAPROCEDURES_code', N'METAPROCEDURES', N'code', N'Codice', 99, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (105, N'METAPROCEDURES_help_lungo0', N'METAPROCEDURES', N'help_lungo0', N'Help', 5, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (103, N'METAPROCEDURES_label0', N'METAPROCEDURES', N'label0', N'Nome procedura', 1, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (104, N'METAPROCEDURES_tipo', N'METAPROCEDURES', N'tipo', N'Tipo', 0, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (180, N'USER_company_name', N'USER', N'company_name', N'Ragione sociale azienda', 6, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (181, N'USER_flag_active', N'USER', N'flag_active', N'Utente attivo', 10, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (182, N'USER_flag_admin', N'USER', N'flag_admin', N'Utente amministratore', 12, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (179, N'USER_person_name', N'USER', N'person_name', N'Nome', 3, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (178, N'USER_person_surname', N'USER', N'person_surname', N'Cognome', 2, N'TEXT', N'S', NULL, NULL, NULL)
INSERT [dbo].[RecordsetColumns] ([ident], [column_code], [recordset_code], [dbcolumn], [label0], [sorting], [format_code], [flag_visible], [js_text], [note], [class]) VALUES (177, N'USER_username', N'USER', N'username', N'Nome utente', 1, N'TEXT', N'S', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[RecordsetColumns] OFF
GO
SET IDENTITY_INSERT [dbo].[Recordsets] ON 

INSERT [dbo].[Recordsets] ([ident], [code], [label0], [source]) VALUES (23, N'METAPARAMS', N'Parametri', N'select * from Params')
INSERT [dbo].[Recordsets] ([ident], [code], [label0], [source]) VALUES (12, N'METAPROCEDURES', N'Procedure', N'select * from Procedures')
INSERT [dbo].[Recordsets] ([ident], [code], [label0], [source]) VALUES (29, N'USER', N'Utente di sistema', N'select * from vw_Users')
SET IDENTITY_INSERT [dbo].[Recordsets] OFF
GO
SET IDENTITY_INSERT [dbo].[Registries] ON 

SET IDENTITY_INSERT [dbo].[Registries] OFF
GO
SET IDENTITY_INSERT [dbo].[RelProfileMenu] ON 

INSERT [dbo].[RelProfileMenu] ([ident], [profile_code], [menu_code], [note], [class]) VALUES (2, N'REFPERSONALESUPER', N'REFPERSONALE', NULL, NULL)
INSERT [dbo].[RelProfileMenu] ([ident], [profile_code], [menu_code], [note], [class]) VALUES (3, N'REFUSEROPERATORE', N'REFUSER', NULL, NULL)
INSERT [dbo].[RelProfileMenu] ([ident], [profile_code], [menu_code], [note], [class]) VALUES (1, N'WOLVISUAL', N'WOL', NULL, NULL)
SET IDENTITY_INSERT [dbo].[RelProfileMenu] OFF
GO
SET IDENTITY_INSERT [dbo].[RelProfileProcedure] ON 

INSERT [dbo].[RelProfileProcedure] ([ident], [profile_code], [procedure_code], [note], [class]) VALUES (2, N'WOLSUPER', N'220598626f4bcb1b7cd2064c53c8e4c2', NULL, NULL)
INSERT [dbo].[RelProfileProcedure] ([ident], [profile_code], [procedure_code], [note], [class]) VALUES (1, N'WOLVISUAL', N'220598626f4bcb1b7cd2064c53c8e4c2', NULL, NULL)
INSERT [dbo].[RelProfileProcedure] ([ident], [profile_code], [procedure_code], [note], [class]) VALUES (3, N'WOLSUPER', N'95b88bb068eb80ce9c38e115ef64e187', NULL, NULL)
SET IDENTITY_INSERT [dbo].[RelProfileProcedure] OFF
GO
SET IDENTITY_INSERT [dbo].[RelUserGroup] ON 

INSERT [dbo].[RelUserGroup] ([ident], [master_code], [slave_code], [note], [class]) VALUES (1, N'SYSTEM', N'root', NULL, NULL)
SET IDENTITY_INSERT [dbo].[RelUserGroup] OFF
GO
SET IDENTITY_INSERT [dbo].[RelUserProfile] ON 

SET IDENTITY_INSERT [dbo].[RelUserProfile] OFF
GO
SET IDENTITY_INSERT [dbo].[RelUserProfileVisibility] ON 

SET IDENTITY_INSERT [dbo].[RelUserProfileVisibility] OFF
GO
SET IDENTITY_INSERT [dbo].[RelUserRegistry] ON 

SET IDENTITY_INSERT [dbo].[RelUserRegistry] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([ident], [role_code], [label0], [note], [class]) VALUES (4, N'OPERATORE', N'Operatore', NULL, NULL)
INSERT [dbo].[Roles] ([ident], [role_code], [label0], [note], [class]) VALUES (3, N'SUPER', N'Super', NULL, NULL)
INSERT [dbo].[Roles] ([ident], [role_code], [label0], [note], [class]) VALUES (2, N'VISUAL', N'Visualizzatore', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[RuleDetails] ON 

INSERT [dbo].[RuleDetails] ([ident], [rule_code], [label0], [help0], [template_code], [node_code], [flag_action], [flag_prepost], [pseudocode], [note], [class], [severity]) VALUES (1, N'USERS_1', N'Dettaglio 1', N'Verifica che lo username non sia già utilizzato.', N'USER', NULL, NULL, N'PRE', N'if exists(select * from users where username=''%username%'')
 exec RuleResult 1, ''Username ''''%username%'''' già presente.''
else
 exec RuleResult 0, ''''', NULL, NULL, N'E')
INSERT [dbo].[RuleDetails] ([ident], [rule_code], [label0], [help0], [template_code], [node_code], [flag_action], [flag_prepost], [pseudocode], [note], [class], [severity]) VALUES (2, N'USERS_1', N'Dettaglio 2', N'Verifica che lo username sia di almeno 8 caratteri.', N'USER', NULL, NULL, N'PRE', N'if len(''%username%'')<8
 exec RuleResult 1, ''Lo Username ''''%username%'''' deve essere di almeno 8 caratteri.''
else
 exec RuleResult 0, ''''', NULL, NULL, N'E')
SET IDENTITY_INSERT [dbo].[RuleDetails] OFF
GO
SET IDENTITY_INSERT [dbo].[Rules] ON 

INSERT [dbo].[Rules] ([ident], [rule_code], [wizard_code], [label0], [note], [class]) VALUES (1, N'USERS_1', N'USERS', N'Regole Wizard USERS', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Rules] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([ident], [username], [password], [flag_admin], [flag_active], [note], [class]) VALUES (1, N'root', N'', N'S', N'S', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
SET IDENTITY_INSERT [dbo].[Visibilities] ON 

INSERT [dbo].[Visibilities] ([ident], [visibility_code], [label0], [note], [class]) VALUES (1, N'VISA', N'Visibilità A', NULL, NULL)
INSERT [dbo].[Visibilities] ([ident], [visibility_code], [label0], [note], [class]) VALUES (2, N'VISB', N'Visibilità B', NULL, NULL)
SET IDENTITY_INSERT [dbo].[Visibilities] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [uniqueProfile]    Script Date: 09/10/2020 12:08:33 ******/
ALTER TABLE [dbo].[Profiles] ADD  CONSTRAINT [uniqueProfile] UNIQUE NONCLUSTERED 
(
	[module_code] ASC,
	[role_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Actions] ADD  CONSTRAINT [DF_Actions_dynamic]  DEFAULT ((0)) FOR [dynamic]
GO
ALTER TABLE [dbo].[MetaClassTypes] ADD  DEFAULT ('N') FOR [list]
GO
ALTER TABLE [dbo].[MetaRelations] ADD  CONSTRAINT [DF_MetaRelations_flag_active]  DEFAULT ('S') FOR [flag_active]
GO
ALTER TABLE [dbo].[MetaRelations] ADD  CONSTRAINT [DF_MetaRelations_readonly]  DEFAULT ('N') FOR [readonly]
GO
ALTER TABLE [dbo].[MetaRelations] ADD  CONSTRAINT [DF_MetaRelations_nosave]  DEFAULT ((0)) FOR [nosave]
GO
ALTER TABLE [dbo].[Procedures] ADD  CONSTRAINT [DF_Procedures_funzione]  DEFAULT ('N') FOR [funzione]
GO
/****** Object:  StoredProcedure [dbo].[PROC_Test_A]    Script Date: 09/10/2020 12:08:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[PROC_Test_A] 
as
begin
	select 'Questa è un''analisi di test. (Vers. A) ' as messaggio
end
GO
/****** Object:  StoredProcedure [dbo].[PROC_Test_B]    Script Date: 09/10/2020 12:08:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[PROC_Test_B] 
as
begin
	select 'Questa è un''analisi di test. (Vers. B)' as messaggio
end
GO
/****** Object:  StoredProcedure [dbo].[RuleResult]    Script Date: 09/10/2020 12:08:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[RuleResult] @res int, @mess varchar(200) 
	as
	begin
	select @res as esito, @mess as messaggio
	end
GO

