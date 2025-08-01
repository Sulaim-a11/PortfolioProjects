-- Data Cleaning in SQL Queries 

SELECT *
FROM NashvilleHousingDataforDataCleaning;

--PRAGMA table_info(NashvilleHousingDataforDataCleaning);

CREATE TABLE NashvilleHousingData (
  UniqueID integer,
  ParcelID FLOAT,
  LandUse TEXT,
  PropertyAddress nvarchar (255), 
  SaleDate nvarchar (255),
  SalePrice FLOAT,
  LegalReference nvarchar (255),
  SoldAsVacant TEXT,
  OwnerName nvarchar (255),
  OwnerAddress nvarchar (255),
  Acreage FLOAT,
  TaxDistrict TEXT,
  LandValue FLOAT,
  BuildingValue FLOAT,
  TotalValue FLOAT,
  YearBuilt INTEGER,
  Bedrooms INTEGER,
  FullBath INTEGER,
  HalfBath INTEGER
  );
  
INSERT INTO NashvilleHousingData (UniqueID ,ParcelID,LandUse,PropertyAddress,SaleDate,SalePrice,LegalReference,SoldAsVacant,OwnerName,OwnerAddress,Acreage,TaxDistrict,LandValue,BuildingValue,TotalValue,YearBuilt,Bedrooms,FullBath, HalfBath)
SELECT c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19
FROM NashvilleHousingDataforDataCleaning
WHERE rowid > 1;


DROP TABLE NashvilleHousingDataforDataCleaning;

SELECT *
FROM NashvilleHousingData
LIMIT 10;


-- Standardize date format 
--mysql 

SELECT saledate, CONVERT (Date, saledate)
FROM NashvilleHousingData;

-- or: 

UPDATE NashvilleHousingData
SET Saledate = CONVERT (Date, saledate);
 
-- or:

ALTER TABLE NashvilleHousingData
ADD SaleDateConverted date;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT (Date, saledate);



-- Standardize date format 
-- SQLite 

--ALTER TABLE NashvilleHousingData
--DROP COLUMN saledateconverted;

ALTER TABLE NashvilleHousingData
ADD COLUMN SaleDateConverted date;

UPDATE NashvilleHousingData
SET SaleDateConverted = 
  CASE 
    WHEN saledate LIKE 'January%' THEN '01'
    WHEN saledate LIKE 'February%' THEN '02'
    WHEN saledate LIKE 'March%' THEN '03'
    WHEN saledate LIKE 'April%' THEN '04'
    WHEN saledate LIKE 'May%' THEN '05'
    WHEN saledate LIKE 'June%' THEN '06'
    WHEN saledate LIKE 'July%' THEN '07'
    WHEN saledate LIKE 'August%' THEN '08'
    WHEN saledate LIKE 'September%' THEN '09'
    WHEN saledate LIKE 'October%' THEN '10'
    WHEN saledate LIKE 'November%' THEN '11'
    WHEN saledate LIKE 'December%' THEN '12'
  END || '/' || 
  substr(saledate, instr(saledate, ' ') + 1, instr(saledate, ',') - instr(saledate, ' ') - 1) || '/' ||
  substr(saledate, -2);


SELECT *
from NashvilleHousingData
WHERE propertyaddress IS NULL;
--ORDER BY parcelid;

--Populate Property Address Data  
--mysql 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
	JOIN NashvilleHousingData b 
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;


UPDATE a
SET propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
	JOIN NashvilleHousingData b 
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;


--Populate Property Address Data 
-- sqlite 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
	JOIN NashvilleHousingData b 
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;


UPDATE a
SET propertyaddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData a
	JOIN NashvilleHousingData b 
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;



--Breaking out Address into Individual Columns (Address, City, State)
-- mysql 

SELECT 
SUBSTRING (propertyaddress, 1, CHARINDEX (',', propertyaddress) -1) AS Address,
SUBSTRING (propertyaddress, CHARINDEX (',', propertyaddress) +1, LEN(propertyaddress))  AS Address
FROM NashvilleHousingData;


ALTER TABLE NashvilleHousingData
ADD PropertySpiltAddress nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySpiltAddress = SUBSTRING (propertyaddress, 1, CHARINDEX (',', propertyaddress) -1);


ALTER TABLE NashvilleHousingData
ADD PropertySpiltCity nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING (propertyaddress, CHARINDEX (',', propertyaddress) +1, LEN(propertyaddress)) ;



--Breaking out Address into Individual Columns (Address, City, State) 
--sqlite 

SELECT propertyaddress
from NashvilleHousingData;


SELECT 
SUBSTRING (propertyaddress, 1, INSTR (propertyaddress, ',') -1) AS Address,
SUBSTRING (propertyaddress, INSTR (propertyaddress, ',') +1, length(propertyaddress))  AS Address
FROM NashvilleHousingData;


ALTER TABLE NashvilleHousingData
ADD PropertySpiltAddress nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySpiltAddress = SUBSTRING (propertyaddress, 1, INSTR (propertyaddress, ',') -1);


ALTER TABLE NashvilleHousingData
ADD PropertySpiltCity nvarchar(255);

UPDATE NashvilleHousingData
SET propertyspiltcity = SUBSTRING (propertyaddress, INSTR (propertyaddress, ',') +1, length(propertyaddress));


SELECT *
FROM NashvilleHousingData;



--Making use of parsename instead of substrings
--mysql 
SELECT 
PARSENAME (REPLACE(owneraddress, ',' , '.'), 3),
PARSENAME (REPLACE(owneraddress, ',' , '.'), 2),
PARSENAME (REPLACE(owneraddress, ',' , '.'), 1)
FROM NashvilleHousingData;

ALTER TABLE NashvilleHousingData
ADD OwnerSplitAdddress nvarchar (255);

UPDATE NashvilleHousingData
SET OwnerSplitAdddress = PARSENAME (REPLACE(owneraddress, ',' , '.'), 3);

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity nvarchar (255); 

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME (REPLACE(owneraddress, ',' , '.'), 2);


ALTER TABLE NashvilleHousingData
ADD OwnerSplitState nvarchar (255);

UPDATE NashvilleHousingData
SET OwnerSplitState = (REPLACE(owneraddress, ',' , '.'), 1);


--sqlite 

WITH Temp AS (
  SELECT 
    owneraddress,
    INSTR(owneraddress, ',') AS first_comma,
    INSTR(SUBSTR(owneraddress, INSTR(owneraddress, ',') + 1), ',') AS second_comma_pos
  FROM NashvilleHousingData
)

SELECT 
  TRIM(SUBSTR(owneraddress, 1, first_comma - 1)) AS Address,
  TRIM(SUBSTR(owneraddress, first_comma + 1, second_comma_pos - 1)) AS City,
  TRIM(SUBSTR(owneraddress, first_comma + second_comma_pos + 1)) AS State
FROM Temp;

ALTER TABLE NashvilleHousingData
DROP COLUMN OwnerSplitAddress;

ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress TEXT;

UPDATE NashvilleHousingData
SET OwnerSplitAddress = TRIM(SUBSTR(owneraddress, 1, INSTR(owneraddress, ',') - 1));
  

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity TEXT; 

UPDATE NashvilleHousingData
SET OwnerSplitCity = TRIM(SUBSTR(
    owneraddress,
    INSTR(owneraddress, ',') + 1,
    INSTR(SUBSTR(owneraddress, INSTR(owneraddress, ',') + 1), ',') - 1
  ));


ALTER TABLE NashvilleHousingData
ADD OwnerSplitState TEXT;

UPDATE NashvilleHousingData
SET OwnerSplitState = TRIM(SUBSTR(
    owneraddress,
    INSTR(owneraddress, ',') +
    INSTR(SUBSTR(owneraddress, INSTR(owneraddress, ',') + 1), ',') + 1
  ));

SELECT *
from NashvilleHousingData;


-- Change Y and N to Yes and No in "Sold as Vacant" field 

SELECT DISTINCT(soldasvacant), COUNT (soldasvacant)
from NashvilleHousingData
GROUP by soldasvacant
ORDER BY 2;


SELECT soldasvacant,
CASE
	when soldasvacant = 'Y' then 'Yes'
    WHEN soldasvacant = 'N' THEN 'No'
    ELSE soldasvacant
 END
from NashvilleHousingData;


UPDATE NashvilleHousingData
set soldasvacant = CASE
	when soldasvacant = 'Y' then 'Yes'
    WHEN soldasvacant = 'N' THEN 'No'
    ELSE soldasvacant
 END;


--Removing duplicates 
-- Using CTE - check for duplicates 

With RowNumCTE AS(
  SELECT *,
  ROW_NUMBER() OVER (
    PARTITION BY parcelid,
    			 propertyaddress,
    			 saleprice,
    		     saledate,
    			 legalreference
    ORDER BY
    		uniqueid )
  			row_num
 FROM NashvilleHousingData
  )

SELECT *
from RowNumCTE
WHERE row_num > 1
ORDER by propertyaddress;

-- remove duplicates mysql 

With RowNumCTE AS(
  SELECT *,
  ROW_NUMBER() OVER (
    PARTITION BY parcelid,
    			 propertyaddress,
    			 saleprice,
    		     saledate,
    			 legalreference
    ORDER BY
    		uniqueid )
  			row_num
 FROM NashvilleHousingData
  )
DELETE
from RowNumCTE
WHERE row_num > 1;

-- removing duplicates 
-- sqlite 

-- Step 1: Create a temp table with row numbers
WITH RowNumCTE AS (
  SELECT 
    rowid AS real_rowid,
    ROW_NUMBER() OVER (
      PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
      ORDER BY uniqueid
    ) AS row_num
  FROM NashvilleHousingData
)

-- Step 2: Delete from base table where row number > 1
DELETE FROM NashvilleHousingData
WHERE rowid IN (
  SELECT real_rowid FROM RowNumCTE WHERE row_num > 1
);

SELECT * 
from NashvilleHousingData;



-- delete unused columns mysql 

SELECT * 
from NashvilleHousingData;

ALTER table NashvilleHousingData
DROP COLUMN owneraddress, taxdistrict, propertyaddress, saledate;



-- delete unused columns - in sqlite multiple columns cannot be dropped at once 
ALTER TABLE NashvilleHousingData DROP COLUMN owneraddress;

ALTER TABLE NashvilleHousingData DROP COLUMN taxdistrict;

ALTER TABLE NashvilleHousingData DROP COLUMN propertyaddress;

ALTER TABLE NashvilleHousingData DROP COLUMN saledate;

