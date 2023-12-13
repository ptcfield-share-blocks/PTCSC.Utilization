-- SQL database scripts to create utilization tables and stored procedures

-- create tables

-- Utilization Data Table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [UtilizationData](
	[TimeStamp] [datetime] NOT NULL,
	[EquipmentID] [nvarchar](255) NOT NULL,
	[UtilizationState] [nvarchar](255) NOT NULL,
	[ReasonGroup] [nvarchar](255) NOT NULL,
	[Reason] [nvarchar](255) NOT NULL,
	[OperatorID] [nvarchar](255) NULL,
	[ShiftID] [nvarchar](255) NULL,
	[ProductID] [nvarchar](255) NULL,
	[Comment] [nvarchar](255) NULL,
	[ModifiedAt] [datetime] NULL,
	[ModifiedBy] [nvarchar](255) NULL
 CONSTRAINT [PK_UtilizationData] PRIMARY KEY CLUSTERED 
(
	[EquipmentID] ASC,
	[TimeStamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- Reason Table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reason](
	[Reason] [nvarchar](255) NOT NULL,
	[ReasonDescription] [nvarchar](255) NOT NULL,
	[ReasonGroup] [nvarchar](255) NOT NULL,
	[UtilizationState] [nvarchar](255) NOT NULL,
	[Failure] bit NOT NULL 
 CONSTRAINT [PK_Reason] PRIMARY KEY CLUSTERED 
(
	[Reason] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- Reason Group Table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ReasonGroup](
	[ReasonGroup] [nvarchar](255) NOT NULL,
	[ReasonGroupDescription] [nvarchar](255) NOT NULL,
	[ParentReasonGroup] [nvarchar](255) NULL
 CONSTRAINT [PK_ReasonGroup] PRIMARY KEY CLUSTERED 
(
	[ReasonGroup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- Utilization State Table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [UtilizationState](
	[UtilizationState] [nvarchar](255) NOT NULL,
	[UtilizationStateDescription] [nvarchar](255) NOT NULL,
	[IncludeInUtilizationCalculation] bit NOT NULL,
	[Utilized] bit NOT NULL 
 CONSTRAINT [PK_UtilizationState] PRIMARY KEY CLUSTERED 
(
	[UtilizationState] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- Machine Code Table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MachineCode](
	[EquipmentID] [nvarchar](255) NOT NULL,
	[MachineCode] [int] NOT NULL,
	[UtilizationState] [nvarchar](255) NOT NULL,
	[ReasonGroup] [nvarchar](255) NOT NULL,
	[Reason] [nvarchar](255) NOT NULL
 CONSTRAINT [PK_MachineCode] PRIMARY KEY CLUSTERED 
(
	[EquipmentID] ASC,
	[MachineCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- create stored procedures

-- procedure to add or update UtilizationState record
CREATE PROCEDURE AddOrUpdateUtilizationState 
@UtilizationState [nvarchar](255),
@UtilizationStateDescription [nvarchar](255),
@IncludedInUtilizationCalculation bit,
@Utilized bit
AS
SET NOCOUNT ON

IF EXISTS (SELECT * FROM UtilizationState WHERE UtilizationState = @UtilizationState)
BEGIN
	UPDATE	UtilizationState
	SET		UtilizationStateDescription = @UtilizationStateDescription,
			IncludeInUtilizationCalculation = @IncludedInUtilizationCalculation,
			Utilized = @Utilized
	WHERE	UtilizationState = @UtilizationState
END
ELSE
BEGIN
	INSERT UtilizationState (UtilizationState, UtilizationStateDescription, IncludeInUtilizationCalculation, Utilized) VALUES (@UtilizationState,@UtilizationStateDescription,@IncludedInUtilizationCalculation,@Utilized)
END

GO

-- procedure to delete UtilizationState record
CREATE PROCEDURE DeleteUtilizationState 
@UtilizationState [nvarchar](255)
AS
SET NOCOUNT ON

DELETE FROM UtilizationState WHERE UtilizationState = @UtilizationState

GO

-- procedure to add or update ReasonGroup record
CREATE PROCEDURE AddOrUpdateReasonGroup 
@ReasonGroup [nvarchar](255),
@ReasonGroupDescription [nvarchar](255),
@ParentReasonGroup [nvarchar](255)
AS
SET NOCOUNT ON

IF @ParentReasonGroup IS NULL
BEGIN
	SET @ParentReasonGroup = ''
END

IF EXISTS (SELECT * FROM ReasonGroup WHERE ReasonGroup = @ReasonGroup)
BEGIN
	UPDATE	ReasonGroup
	SET		ReasonGroupDescription = @ReasonGroupDescription,
			ParentReasonGroup = @ParentReasonGroup
	WHERE	ReasonGroup = @ReasonGroup
END
ELSE
BEGIN
	INSERT ReasonGroup (ReasonGroup, ReasonGroupDescription, ParentReasonGroup) VALUES (@ReasonGroup,@ReasonGroupDescription,@ParentReasonGroup)
END

GO

-- procedure to delete ReasonGroup record
CREATE PROCEDURE DeleteReasonGroup 
@ReasonGroup [nvarchar](255)
AS
SET NOCOUNT ON

DELETE FROM ReasonGroup WHERE ReasonGroup = @ReasonGroup

GO

-- procedure to add or update Reason record
CREATE PROCEDURE AddOrUpdateReason
@Reason [nvarchar](255),
@ReasonDescription [nvarchar](255),
@ReasonGroup [nvarchar](255),
@UtilizationState [nvarchar](255),
@Failure bit 
AS
SET NOCOUNT ON

IF EXISTS (SELECT * FROM Reason WHERE Reason = @Reason)
BEGIN
	UPDATE	Reason
	SET		ReasonDescription = @ReasonDescription,
			ReasonGroup = @ReasonGroup,
			UtilizationState = @UtilizationState,
			Failure = @Failure
	WHERE	Reason = @Reason
END
ELSE
BEGIN
	INSERT Reason (Reason, ReasonDescription, ReasonGroup, UtilizationState, Failure) VALUES (@Reason,@ReasonDescription,@ReasonGroup,@UtilizationState,@Failure)
END

GO

-- procedure to delete Reason record
CREATE PROCEDURE DeleteReason
@Reason [nvarchar](255)
AS
SET NOCOUNT ON

DELETE FROM Reason WHERE Reason = @Reason

GO

-- procedure to add or update UtilizationData record
CREATE PROCEDURE AddOrUpdateUtilizationDataRecord
@TimeStamp [datetime],
@EquipmentID [nvarchar](255),
@UtilizationState [nvarchar](255),
@ReasonGroup [nvarchar](255),
@Reason [nvarchar](255),
@OperatorID [nvarchar](255) NULL,
@ShiftID [nvarchar](255) NULL,
@ProductID [nvarchar](255) NULL,
@Comment [nvarchar](255) NULL,
@ModifiedAt [datetime] NULL,
@ModifiedBy [nvarchar](255) NULL
AS
SET NOCOUNT ON

IF EXISTS (SELECT * FROM UtilizationData WHERE TimeStamp = @TimeStamp AND EquipmentID = @EquipmentID)
BEGIN
	UPDATE	UtilizationData
	SET		UtilizationState = @UtilizationState,
			ReasonGroup = @ReasonGroup,
			Reason = @Reason,
			OperatorID = @OperatorID,
			ShiftID = @ShiftID,
			ProductID = @ProductID,
			Comment = @Comment,
			ModifiedAt = @ModifiedAt,
			ModifiedBy = @ModifiedBy
	WHERE	TimeStamp = @TimeStamp AND
			EquipmentID = @EquipmentID
END
ELSE
BEGIN
	INSERT UtilizationData (TimeStamp, EquipmentID, UtilizationState, ReasonGroup, Reason, OperatorID, ShiftID, ProductID, Comment, ModifiedAt, ModifiedBy) 
	VALUES (@TimeStamp,@EquipmentID,@UtilizationState,@ReasonGroup,@Reason,@OperatorID,@ShiftID,@ProductID,@Comment,@ModifiedAt,@ModifiedBy)
END

GO

-- procedure to delete UtilizationData records
CREATE PROCEDURE DeleteUtilizationData
@DaysBack int
AS
SET NOCOUNT ON

DECLARE @PurgeDate datetime
SET @PurgeDate = GETDATE() - @DaysBack

DELETE FROM UtilizationData WHERE TimeStamp < @PurgeDate

GO

-- procedure to add or update MachineCode record
CREATE PROCEDURE AddOrUpdateMachineCode
@MachineCode [int],
@EquipmentID [nvarchar](255),
@UtilizationState [nvarchar](255),
@ReasonGroup [nvarchar](255),
@Reason [nvarchar](255)
AS
SET NOCOUNT ON

IF EXISTS (SELECT * FROM MachineCode WHERE MachineCode = @MachineCode AND EquipmentID = @EquipmentID)
BEGIN
	UPDATE	MachineCode
	SET		UtilizationState = @UtilizationState,
			ReasonGroup = @ReasonGroup,
			Reason = @Reason
	WHERE	MachineCode = @MachineCode AND
			EquipmentID = @EquipmentID
END
ELSE
BEGIN
	INSERT MachineCode (MachineCode, EquipmentID, UtilizationState, ReasonGroup, Reason) 
	VALUES (@MachineCode,@EquipmentID,@UtilizationState,@ReasonGroup,@Reason)
END

GO

-- procedure to delete MachineCode record
CREATE PROCEDURE DeleteMachineCode
@MachineCode [int],
@EquipmentID [nvarchar](255)
AS
SET NOCOUNT ON

DELETE FROM MachineCode WHERE MachineCode = @MachineCode AND EquipmentID = @EquipmentID

GO

-- procedure to get ReasonGroup records by Utilization State
CREATE PROCEDURE GetReasonGroupsByUtilizationState 
@UtilizationState [nvarchar](255)
AS
SET NOCOUNT ON

SELECT * FROM ReasonGroup WHERE ReasonGroup IN (SELECT DISTINCT ReasonGroup FROM Reason WHERE UtilizationState = @UtilizationState GROUP BY ReasonGroup)
ORDER BY ReasonGroup

GO

-- procedure to get MachineCode records by EquipmentID
CREATE PROCEDURE GetMachineCodesByEquipmentID 
@EquipmentID [nvarchar](255)
AS
SET NOCOUNT ON

SELECT * FROM MachineCode WHERE EquipmentID = @EquipmentID
ORDER BY MachineCode

GO