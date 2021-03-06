USE [testdb]
GO
/****** Object:  StoredProcedure [dbo].[pVKAB_API_ClientInsert]    Script Date: 04/10/2015 17:16:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pVKAB_API_ClientInsert]
 @ClientID			NUMERIC(15,0) OUTPUT
,@ClientINN         VARCHAR(30) = '' -- ИНН 
,@ClientFullName	VARCHAR(255) --ФИО заемщика
,@Gender			VARCHAR(100) --Пол	
,@Doc_Type			VARCHAR(100) --Тип документа	
,@Doc_Ser			VARCHAR(100)--Серия	
,@Doc_Num			VARCHAR(100)--Номер	
,@Doc_Date			VARCHAR(100)--Дата выдачи	
,@Doc_Org			VARCHAR(100) = ''--Кем выдан	
,@Doc_OrgCode		VARCHAR(100) = ''--Код подразделения
,@BirthPlace		VARCHAR(100) = ''--Место рождения	
,@BirthDate			VARCHAR(100) = ''--Дата рождения	
,@PhoneM			VARCHAR(100) = ''--Телефон мобильный
,@PhoneH			VARCHAR(100) = ''--Телефон домашний
,@PhoneW			VARCHAR(100) = ''--Телефон рабочий	
,@AR_ZIP			VARCHAR(100) = ''--РЕГИСТРАЦИЯ: Индекс  должника	
,@AR_Country		VARCHAR(100) = ''--РЕГИСТРАЦИЯ: Страна должника	
,@AR_RegionType		VARCHAR(100) = ''--РЕГИСТРАЦИЯ: Область или край (тип) Должника	
,@AR_Region			VARCHAR(100) = ''--РЕГИСТРАЦИЯ: область или край Должника	
,@AR_AreaType		VARCHAR(100) = ''--РЕГИСТРАЦИЯ: район (тип) Должника	
,@AR_Area			VARCHAR(100) = ''--РЕГИСТРАЦИЯ: район Должника	
,@AR_LocalityType	VARCHAR(100) = ''--РЕГИСТРАЦИЯ: Тип населенного пункта Должника	
,@AR_Locality		VARCHAR(100) = ''--РЕГИСТРАЦИЯ: Населенный пункт Должника	
,@AR_StreetType		VARCHAR(100) = ''--РЕГИСТРАЦИЯ: тип улицы Должника	
,@AR_Street			VARCHAR(100) = ''--РЕГИСТРАЦИЯ: Улица Должника	
,@AR_House			VARCHAR(100) = ''--РЕГИСТРАЦИЯ: Дом Должника	
,@AR_Corpus			VARCHAR(100) = ''--РЕГИСТРАЦИЯ: Корпус Должника	
,@AR_Flat			VARCHAR(100) = ''--РЕГИСТРАЦИЯ: квартира Должника	
,@AR_Kladr			VARCHAR(100) = ''--РЕГИСТРАЦИЯ: строка адреса Должника	
,@AS_ZIP			VARCHAR(100) = ''--ПРЕБЫВАНИЕ: Индекс Должника	
,@AS_Country		VARCHAR(100) = ''--ПРЕБЫВАНИЕ: Страна Должника	
,@AS_RegionType		VARCHAR(100) = ''--ПРЕБЫВАНИЕ: область или край (тип) Должника	
,@AS_Region			VARCHAR(100) = ''--ПРЕБЫВАНИЕ: область или край Должника	
,@AS_AreaType		VARCHAR(100) = ''--ПРЕБЫВАНИЕ: район (тип) Должника	
,@AS_Area			VARCHAR(100) = ''--ПРЕБЫВАНИЕ: район Должника	
,@AS_LocalityType	VARCHAR(100) = ''--ПРЕБЫВАНИЕ: Тип. Нас. Пункта Должника	
,@AS_Locality		VARCHAR(100) = ''--ПРЕБЫВАНИЕ: Нас. Пункт Должника	
,@AS_StreetType		VARCHAR(100) = ''--ПРЕБЫВАНИЕ: тип улицы Должника	
,@AS_Street			VARCHAR(100) = ''--ПРЕБЫВАНИЕ: Улица Должника	
,@AS_House			VARCHAR(100) = ''--ПРЕБЫВАНИЕ: Дом Должника	
,@AS_Corpus			VARCHAR(100) = ''--ПРЕБЫВАНИЕ: Корпус Должника	
,@AS_Flat			VARCHAR(100) = ''--ПРЕБЫВАНИЕ: квартира Должника	
,@AS_KLadr			VARCHAR(100) = ''--ПРЕБЫВАНИЕ: строка адреса Должника	
AS
BEGIN

SET @ClientID = 0


-------------------------------------------------------------------------------------------------------------
/*SET @ClientFullName = 'Гафиятуллин Дамир Тагирович'
SET @Gender = 'Мужской'
SET @Doc_Type = '21'
SET @Doc_Ser  = '9215'
SET @Doc_Num  = '731962'
SET @Doc_Date = '20070303'
SET @Doc_Org  = 'ОВД Алексеевского района'
SET @Doc_OrgCode = '168-548'
SET @BirthPlace = 'c. Подлесная шентала'
SET @BirthDate = '19870211'

SET @PhoneM = '89274158592'
SET @PhoneH = ''
SET @PhoneW = ''

SET @AR_ZIP = '420141'
SET @AR_Country = 'РОССИЯ'
SET @AR_RegionType = 'Респ'
SET @AR_Region  = 'Татарстан'
SET @AR_AreaType = ''
SET @AR_Area  = ''
SET @AR_LocalityType  = 'город'
SET @AR_Locality  = 'Казань'
SET @AR_StreetType  = 'улица'
SET @AR_Street  = 'Салиха Батыева'
SET @AR_House  = '21'
SET @AR_Corpus  = ''
SET @AR_Flat  = '207'
SET @AR_Kladr  = ''


SET @AS_ZIP = ''
SET @AS_Country = 'РОССИЯ'
SET @AS_RegionType = 'Респ'
SET @AS_Region  = 'Татарстан'
SET @AS_AreaType = 'район'
SET @AS_Area  = 'Алексеевский'
SET @AS_LocalityType  = 'село'
SET @AS_Locality  = 'Степная Шентала'
SET @AS_StreetType  = 'улица'
SET @AS_Street  = 'Ямашева'
SET @AS_House  = '21'
SET @AS_Corpus  = ''
SET @AS_Flat  = '207'
SET @AS_Kladr  = ''

*/
-------------------------------------------------------------------------------------------------------------

DECLARE @_ClientLastName  VARCHAR(100)
DECLARE @_ClientFirstName VARCHAR(100)
DECLARE @_ClientMiddleName VARCHAR(100)
DECLARE @_ClientBrief VARCHAR(100)
DECLARE @_Gender TINYINT
DECLARE @_DocTypeID NUMERIC(15,0)
DECLARE @_BirthDate SMALLDATETIME


--------------------------------------------------------------------------------------------------------------
------------------------------------------ Клиент ------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

SET @ClientFullName = RTRIM(LTRIM(@ClientFullName))
SET @ClientFullName = REPLACE(@ClientFullName,'    ',' ')
SET @ClientFullName = REPLACE(@ClientFullName,'   ',' ')
SET @ClientFullName = REPLACE(@ClientFullName,'  ',' ')

DECLARE @posS INT
DECLARE @posF INT
SET @posS = 1
SET @posF = 0

SELECT @posF = CHARINDEX(' ',@ClientFullName)

SET @_ClientLastName = SUBSTRING(@ClientFullName,@posS,@posF-@posS)

SET @PosS = @posF + 1
SELECT @posF = CHARINDEX(' ',@ClientFullName,@PosS)
IF @posF = 0 SET @posF = LEN(@ClientFullName)+1
SET @_ClientFirstName = SUBSTRING(@ClientFullName,@posS,@posF-@posS)

SET @PosS = @posF + 1
SET @posF = LEN(@ClientFullName)+1

IF @posF - @PosS = -1
SET @_ClientMiddleName = ''
ELSE
SET @_ClientMiddleName = SUBSTRING(@ClientFullName,@posS,@posF-@posS)

SET @_ClientBrief = @_ClientLastName + ' ' + SUBSTRING(@_ClientFirstName,1,1) + '.'

IF @_ClientMiddleName != ''
BEGIN
	SET @_ClientBrief = @_ClientBrief + ' ' + SUBSTRING(@_ClientMiddleName,1,1) + '.'
END

--------------------------------------------------------------------------------------------------------------
------------------------------------------ Пол ---------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

SET @Gender = LTRIM(RTRIM(@Gender))
IF SUBSTRING(@Gender,1,1) IN ('м','m')
BEGIN
	SET @_Gender = 0
END
ELSE
BEGIN
	SET @_Gender = 1
END

--------------------------------------------------------------------------------------------------------------
------------------------------------------ Документ ----------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

SET @Doc_Type = RIGHT('00' + ISNULL(@Doc_Type,''),2)

SELECT @_DocTypeID = DocTypeID FROM tDocType WHERE Brief = @Doc_Type

SELECT @ClientID = InstitutionID
FROM tInstLicense il
WHERE REPLACE(il.DocSeries,' ','') = @Doc_Ser
	AND REPLACE(il.NumDoc,' ','') = @Doc_Num
	AND DocTypeID = @_DocTypeID 

IF @ClientID = 0
BEGIN

SELECT @ClientID = InstitutionID
FROM tInstLicense il
WHERE REPLACE(il.DocSeries,' ','') = @Doc_Ser
	AND REPLACE(il.NumDoc,' ','') = @Doc_Num

END


IF @ClientID = 0 AND @ClientINN != '' AND dbo.fCheckTaxCode(@ClientINN) != 1
BEGIN

SELECT @ClientID = InstitutionID
FROM tInstitution WHERE INN = LTRIM(RTRIM(@ClientINN))

END


IF @ClientID != 0
BEGIN	
	return;
END

--создание клиента
DECLARE @ObjClassifierID NUMERIC(15,0)
SELECT @ObjClassifierID = ObjClassifierID FROM tObjClassifier WHERE Brief = 'Внутр_клиенты' AND ObjType = 1

EXEC [API_gl_Institution_Insert]
 @InstitutionID         = @ClientID OUT
,@CountryID             = 1
--,@InstGroupID           = 0
,@Name					= @_ClientLastName
,@Brief					= @_ClientBrief
,@Bic					= ''
,@INN                   = @ClientINN
,@PropDealPart			= 0
,@Name1					= @_ClientFirstName
--,@UserID                DSIDENTIFIER    = NULL,
,@Name2					= @_ClientMiddleName
,@BirthDay				= @BirthDate
,@BirthPlace			= @BirthPlace
,@Sex					= @_Gender
,@MainMember			= 1
,@ObjClassifierID		= @ObjClassifierID 
--,@BirthCountryID        DSIDENTIFIER    = NULL,

--создание документа


IF @Doc_Type = '21'
BEGIN
	SET @Doc_ser = REPLACE(@Doc_ser,'  ','')
	SET @Doc_ser = REPLACE(@Doc_ser,' ','')
	SET @Doc_ser = SUBSTRING(@Doc_ser,1,2) + ' ' + SUBSTRING(@Doc_ser,3,2)
END



DECLARE @InstLicenseID NUMERIC(15,0)

EXEC [InstLicense_Insert]
 @InstLicenseID  = @InstLicenseID output
,@InstitutionID  = @ClientID
,@DocTypeID      = @_DocTypeID
,@NumDoc         = @Doc_num
,@DateDoc        = @Doc_Date 
,@RegTmp         = 0 
,@DateEnd        = '19000101'
,@RegName        = @Doc_Org
,@AlterRegName   = ''
,@Comment        = ''
,@Type           = 0
,@DocSeries      = @Doc_ser
,@isDefault      = 1
,@Failed         = 0
,@Code			 = @Doc_OrgCode
 

 
--------------------------------------------------------------------------------------------------------------
------------------------------------------ @BirthPlace -------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

SELECT  @BirthPlace = LTRIM(RTRIM(ISNULL(@BirthPlace,'')))

--------------------------------------------------------------------------------------------------------------
------------------------------------------ @BirthDate --------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

SELECT @_BirthDate = convert(smalldatetime,@BirthDate)

--------------------------------------------------------------------------------------------------------------
------------------------------------------ Адрес -------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
DECLARE @A_Kladr VARCHAR(100) 
,@CountryID NUMERIC(15,0) 
,@RegionID NUMERIC(15,0)
,@AreaID NUMERIC(15,0) 
,@CityID NUMERIC(15,0) 
,@LocalityID NUMERIC(15,0) 
,@StreetID NUMERIC(15,0) 


EXEC pVKAB_API_Address_Get 
 @A_ZIP				= @AR_ZIP	OUTPUT	
,@A_Country			= @AR_Country		
,@A_RegionType		= @AR_RegionType		
,@A_Region			= @AR_Region			
,@A_AreaType		= @AR_AreaType		
,@A_Area			= @AR_Area			
,@A_LocalityType	= @AR_LocalityType	
,@A_Locality		= @AR_Locality		
,@A_StreetType		= @AR_StreetType		
,@A_Street			= @AR_Street			
,@A_House			= @AR_House			
,@A_Corpus   		= @AR_Corpus		
,@A_Building   		= ''
,@A_Flat			= @AR_Flat			

,@A_Kladr			= @A_Kladr OUTPUT
,@CountryID			= @CountryID	 OUTPUT
,@RegionID			= @RegionID	 OUTPUT
,@AreaID			= @AreaID	 OUTPUT
,@CityID			= @CityID	 OUTPUT
,@LocalityID		= @LocalityID OUTPUT
,@StreetID			= @StreetID	 OUTPUT

--SELECT @A_Kladr
DECLARE @Street VARCHAR(100)

IF @StreetID = 0
BEGIN
	SET @Street = @AR_Street + ' ' + @AR_StreetType
END
ELSE
BEGIN
	SET @Street = ''
END

DECLARE @InstAddressID NUMERIC(15,0)

EXEC [API_gl_InstAddress_Insert]
 @InstAddressID    = @InstAddressID out
,@InstitutionID    = @ClientID
,@AddressTypeID    = 5 -- Адрес регистрации
,@Name             = @A_Kladr
,@AlterName        = ''
,@TranslitName     = ''
,@CountryID        = @CountryID
,@PostIndex        = @AR_ZIP
,@RegionID         = @RegionID
,@AreaID           = @AreaID
,@CityID           = @CityID
,@City1ID          = @LocalityID
,@StreetID         = @StreetID
,@Street           = @Street
,@House            = @AR_House
,@Frame            = @AR_Corpus
,@Construction     = ''
,@Flat             = @AR_Flat
,@Sign             = 1




EXEC pVKAB_API_Address_Get 
 @A_ZIP				= @AS_ZIP	OUTPUT		
,@A_Country			= @AS_Country		
,@A_RegionType		= @AS_RegionType		
,@A_Region			= @AS_Region			
,@A_AreaType		= @AS_AreaType		
,@A_Area			= @AS_Area			
,@A_LocalityType	= @AS_LocalityType	
,@A_Locality		= @AS_Locality		
,@A_StreetType		= @AS_StreetType		
,@A_Street			= @AS_Street			
,@A_House			= @AS_House			
,@A_Corpus   		= @AS_Corpus		
,@A_Building   		= ''
,@A_Flat			= @AS_Flat			

,@A_Kladr			= @A_Kladr    OUTPUT
,@CountryID			= @CountryID  OUTPUT
,@RegionID			= @RegionID	  OUTPUT
,@AreaID			= @AreaID	  OUTPUT
,@CityID			= @CityID	  OUTPUT
,@LocalityID		= @LocalityID OUTPUT
,@StreetID			= @StreetID	  OUTPUT

IF @StreetID = 0
BEGIN
	SET @Street = @AS_Street + ' ' + @AS_StreetType
END
ELSE
BEGIN
	SET @Street = ''
END

EXEC [API_gl_InstAddress_Insert]
 @InstAddressID    = @InstAddressID out
,@InstitutionID    = @ClientID
,@AddressTypeID    = 6 -- Адрес пребывания
,@Name             = @A_Kladr
,@AlterName        = ''
,@TranslitName     = ''
,@CountryID        = @CountryID
,@PostIndex        = @AS_ZIP
,@RegionID         = @RegionID
,@AreaID           = @AreaID
,@CityID           = @CityID
,@City1ID          = @LocalityID
,@StreetID         = @StreetID
,@Street           = ''
,@House            = @AS_House
,@Frame            = @AS_Corpus
,@Construction     = ''
,@Flat             = @AS_Flat
,@Sign             = 0

--------------------------------------------------------------------------------------------------------------
------------------------------------------ Телефоны ----------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#tmpContacts') IS NOT NULL
	DROP TABLE #tmpContacts

CREATE TABLE #tmpContacts
(
  ContactTypeID NUMERIC(15,0)
, Phone VARCHAR(40)
)


INSERT INTO #tmpContacts
SELECT ContactTypeID,@PhoneH
FROM tContactType
WHERE Brief = 'ДомТелефон'
	AND NULLIF(@PhoneH,'') IS NOT NULL

INSERT INTO #tmpContacts
SELECT ContactTypeID,@PhoneW
FROM tContactType
WHERE Brief = 'РабТелефон'
	AND NULLIF(@PhoneW,'') IS NOT NULL

INSERT INTO #tmpContacts
SELECT ContactTypeID,@PhoneM
FROM tContactType
WHERE Brief = 'МобТелефон'
	AND NULLIF(@PhoneM,'') IS NOT NULL

DECLARE @ContactTypeID NUMERIC(15,0)
DECLARE @InstContactID NUMERIC(15,0)
DECLARE @Phone VARCHAR(40)

DECLARE mycur CURSOR FOR SELECT ContactTypeID , Phone FROM #tmpContacts
OPEN mycur 

FETCH mycur INTO @ContactTypeID,@Phone

WHILE @@FETCH_STATUS = 0
BEGIN	

			
	EXEC [API_gl_InstContact_Insert]
		@InstContactID	  = @InstContactID output,
		@ContactTypeID    =	@ContactTypeID ,
		@InstitutionID    = @ClientID ,
		@Brief            = @Phone,
		@Flag             = 0		
	
	FETCH mycur INTO @ContactTypeID,@Phone	
END

CLOSE mycur 
DEALLOCATE mycur

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
END

