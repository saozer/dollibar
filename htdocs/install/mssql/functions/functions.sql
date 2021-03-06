-- ============================================================================
-- Copyright (C) 2007 Regis Houssin <regis@dolibarr.fr>
-- Copyright (C) 2007 Simon Desee   <simon@dedisoft.com>
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
--
-- ============================================================================

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'unix_timestamp') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION unix_timestamp
(
	@Date datetime
)
RETURNS varchar (19)
AS
BEGIN
	DECLARE @Result int

	--SET @Result = NULL
	--IF @Date IS NOT NULL SET @Result = DATEDIFF(s, '19700101', @Date)

	RETURN convert(varchar(19), @Date, 120);
END


END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'from_unixtime') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION from_unixtime
(
	@Epoch int
)
RETURNS datetime
AS
BEGIN
	RETURN DATEADD(s, @Epoch, ''19700101'');

END

END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'llx_bordereau_cheque_number'))
EXEC dbo.sp_executesql @statement = N'
-- FILLZERO du number

CREATE TRIGGER llx_bordereau_cheque_number
	ON llx_bordereau_cheque
	AFTER INSERT, UPDATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @numero as varchar(5)
	SELECT @numero = right(''00000'' + cast(number AS varchar(5)),5)
	from llx_bordereau_cheque
	where rowid in (select rowid from inserted)

update llx_bordereau_cheque set number = @numero
where rowid in (select rowid from inserted)

END

GO
