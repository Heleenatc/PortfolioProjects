-- Portfolio Project - 3
-- Nashville Housing Database for Data cleaning
-- Guided project - Ref: AlexTheAnalyst YouTube channel

create database NashvilleHousing;


-- Fields ---
-- UniqueID ,ParcelID,LandUse,PropertyAddress,SaleDate,SalePrice,LegalReference,SoldAsVacant,OwnerName,OwnerAddress,Acreage,TaxDistrict,
-- LandValue,BuildingValue,TotalValue,YearBuilt,Bedrooms,FullBath,HalfBath

-- ***************************************************************************************************
LOAD DATA INFILE 
	'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NashvilleHousing.csv'
INTO TABLE
	`NashvilleHousing`
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
-- Error code 1262: Row 1 was truncated; it contained more data than there were input columns
-- Problem is that some fields already have commas

-- Opened the csv in notepad. Added sep=| as first line and saved. (| pipe symbol)

LOAD DATA INFILE 
	'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NashvilleHousing.csv'
INTO TABLE
	`NashvilleHousing`
FIELDS TERMINATED BY '|'
IGNORE 1 LINES;
-- Didn't work:- All the fields got filled in the first column as we didnt replace , with | to separate fields
-- Replacing all commas that separates the fields is not a good idea

-- Tried changing the delimiter through Excel
-- Clear Excel Options -> Advanced -> Editing Options -> Use system separators
-- Set Decimal separator to , (a comma)
-- set Thousand separator to . (a period)
-- Saved the csv. Tried to open this in notepad. Found that the field separators are ; (semicolon) now
LOAD DATA INFILE 
	'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NashvilleHousing.csv'
INTO TABLE
	`NashvilleHousing`
FIELDS TERMINATED BY ';'
IGNORE 1 LINES;

-- Error Code: 1261. Row 1714 doesn't contain data for all columns
-- Couldnt fix it. Looks like there may be some problem while identifying line breaks. Not sure though
-- ********************************************************************************************************


-- Why cant give a try with Table Import wizard?
-- Tried... It works perfectly this time. Took around 5 mins only to load all the 56477 rows. 
-- Not sure why it didnt work in the covid file

USE NashvilleHousing;

-- Quick look at the database
SELECT * 
FROM
NashvilleHousing;

-- --------------------------------------------------------------------
-- **************** Task-I ***********************
-- Standardize Date format 
-- Now it is like April 9, 2013 
SELECT SaleDate, str_to_date(SaleDate, "%M %d, %Y") AS SaleDateFixed
FROM
NashvilleHousing;

UPDATE NashvilleHousing 
SET SaleDate = str_to_date(SaleDate, "%M %d, %Y");
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **************** Task-II ***********************
-- Populate property address field with relevent data
-- Some cells are empty now
SELECT *
FROM NashvilleHousing
-- WHERE trim(PropertyAddress) =''
ORDER BY ParcelID;

-- To check how many ParcelIDs are repeating
SELECT ParcelID, PropertyAddress, Count(ParcelID) OVER (PARTITION BY ParcelID) AS ParcelIDCount
FROM NashvilleHousing
ORDER BY ParcelIDCount DESC;

-- Each ParcelID has its own address
-- So, if the address is missing in one cell, it means that we can populate this cell with the address of another cell with the same parcelID
-- Check by self joining the table
-- a.UniqueID <> b.UniqueID ensures that same row is not joined
SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress
FROM NashvilleHousing a 
INNER JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE trim(a.PropertyAddress) = ''
ORDER BY a.ParcelID;

-- Update the cells with relevant PropertyAddress
UPDATE NashvilleHousing  a 
INNER JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE trim(a.PropertyAddress) = '';
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **************** Task-III ***********************
-- Splitting up Property Address into different columns (Address, City)

SELECT PropertyAddress, 
	   substr(PropertyAddress, 1, position(',' IN PropertyAddress)-1) AS Address,
       trim(substr(PropertyAddress, position(',' IN PropertyAddress)+1, length(PropertyAddress))) AS City
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD COLUMN Address varchar(255);

UPDATE NashvilleHousing
SET Address = substr(PropertyAddress, 1, position(',' IN PropertyAddress)-1); 

ALTER TABLE NashvilleHousing
ADD COLUMN City varchar(255);

UPDATE NashvilleHousing
SET City = trim(substr(PropertyAddress, position(',' IN PropertyAddress)+1, length(PropertyAddress)));

SELECT PropertyAddress, Address, City 
FROM NashvilleHousing;
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **************** Task-IV ***********************
-- Split OwnerAddress into different columns (Address, City, State)
-- substring_index(str, delim, count) used to split the text based on a delimiter
-- if count is negative it returns all to the right of the delimiter
-- In SQLServer, ParseName is used to split a string based on '.' delimiter
SELECT OwnerAddress, substring_index(OwnerAddress, ',', 1) As OwnerSplitAddress,
	substring_index(substring_index(OwnerAddress, ',', -2), ',',1) As OwnerCity,
	substring_index(OwnerAddress, ',', -1) As OwnerState
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitAddress varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = substring_index(OwnerAddress, ',', 1);

ALTER TABLE NashvilleHousing
ADD COLUMN OwnerCity varchar(255);

UPDATE NashvilleHousing
SET OwnerCity = substring_index(substring_index(OwnerAddress, ',', -2), ',',1);

ALTER TABLE NashvilleHousing
ADD COLUMN OwnerState varchar(255);

UPDATE NashvilleHousing
SET OwnerState = substring_index(OwnerAddress, ',', -1);

SELECT OwnerAddress, OwnerSplitAddress, OwnerCity, OwnerState
FROM NashvilleHousing;
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **************** Task-V ***********************
-- Replace Y and N with Yes and No in 'Sold as vacant' column

SELECT DISTINCT SoldAsVacant
FROM NashvilleHousing;

SELECT SoldAsVacant, Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant;

-- # SoldAsVacant	Count(SoldAsVacant)
-- No	51403
-- N	399
-- Yes	4623
-- Y	52


SELECT DISTINCT SoldAsVacant,
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
        END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = 
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
        END;
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **************** Task-VI ***********************
-- Remove Duplicate rows
-- In realtime projects, don't delete any columns or rows from the database
-- Use Temptable instead to perform the cleanup

-- Show the duplicate rows using row_number window function
WITH CTE_DUPLICATE AS
	(SELECT *, 
		ROW_NUMBER() OVER (
        PARTITION BY ParcelId,
					 PropertyAddress,
                     SaleDate,
                     SalePrice,
                     LegalReference
                     ORDER BY UniqueID) AS RowNo        
	FROM NashvilleHousing)

	SELECT * 
    FROM CTE_DUPLICATE;
 
 -- Now let's delete the duplicate rows
    WITH CTE_DUPLICATE AS
	(SELECT  *,
		ROW_NUMBER() OVER (
        PARTITION BY ParcelId,
					 PropertyAddress,
                     SaleDate,
                     SalePrice,
                     LegalReference
                     ORDER BY UniqueID) AS RowNum        
	FROM NashvilleHousing)

	DELETE
    FROM CTE_DUPLICATE
    WHERE RowNum > 1;
-- Error Code: 1288. The target table CTE_DUPLICATE of the DELETE is not updatable

ALTER TABLE NashvilleHousing
ADD COLUMN RowNum int;

WITH CTE_DUPLICATE AS
	(SELECT *,
		ROW_NUMBER() OVER (
        PARTITION BY ParcelId,
					 PropertyAddress,
                     SaleDate,
                     SalePrice,
                     LegalReference
                     ORDER BY UniqueID) AS RN        
	FROM NashvilleHousing)
	
    UPDATE NashvilleHousing 
    SET RowNum = (
				SELECT RN
                FROM CTE_DUPLICATE
                WHERE NashvilleHousing.UniqueID = CTE_DUPLICATE.UniqueID);
	-- Error Code: 2013. Lost connection to MySQL server during query
    -- May be the query takes a lot of time to execute

	WITH CTE_DUPLICATE AS
	(SELECT *, 
		ROW_NUMBER() OVER (
        PARTITION BY ParcelId,
					 PropertyAddress,
                     SaleDate,
                     SalePrice,
                     LegalReference
                     ORDER BY UniqueID) AS RowNo        
	FROM NashvilleHousing)

	UPDATE NashvilleHousing 
    JOIN CTE_DUPLICATE
    ON NashvilleHousing.UniqueID = CTE_DUPLICATE.UniqueID
    SET NashvilleHousing.RowNum = RowNo;
-- None of the above methods worked to update the RowNum column

	ALTER TABLE NashvilleHousing
    DROP COLUMN RowNum;
    
-- Done with a subquery
-- Not an efficient method though
	WITH CTE_DUPLICATE AS
	(SELECT *, 
		ROW_NUMBER() OVER (
        PARTITION BY ParcelId,
					 PropertyAddress,
                     SaleDate,
                     SalePrice,
                     LegalReference
                     ORDER BY UniqueID) AS RowNo        
	FROM NashvilleHousing)
    
    DELETE FROM NashvilleHousing
    WHERE UniqueID IN
		(SELECT UniqueID FROM CTE_DUPLICATE
		 WHERE RowNo > 1);


-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **************** Task-VII ***********************
-- Remove unnecessary columns
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress;



SELECT * FROM NashvilleHousing;
-- --------------------------------------------------------------------