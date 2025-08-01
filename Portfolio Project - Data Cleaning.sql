-- Data Cleaning in SQL Queries 

SELECT *
FROM NashvilleHousingDataforDataCleaningforDataCleaning;

--PRAGMA table_info(NashvilleHousingDataforDataCleaningforDataCleaning);

SELECT *
FROM NashvilleHousingDataforDataCleaning
LIMIT 10;


-- Standardize date format 
 
SELECT saledate, CONVERT (Date, saledate)
FROM NashvilleHousingDataforDataCleaning;

-- or: 

UPDATE NashvilleHousingDataforDataCleaning
SET Saledate = CONVERT (Date, saledate);
 
-- or:

ALTER TABLE NashvilleHousingDataforDataCleaning
ADD SaleDateConverted date;

UPDATE NashvilleHousingDataforDataCleaning
SET SaleDateConverted = CONVERT (Date, saledate);

SELECT *
from NashvilleHousingDataforDataCleaning
WHERE propertyaddress IS NULL;
--ORDER BY parcelid;

--Populate Property Address Data  

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingDataforDataCleaning a
	JOIN NashvilleHousingDataforDataCleaning b 
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;


UPDATE a
SET propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingDataforDataCleaning a
	JOIN NashvilleHousingDataforDataCleaning b 
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;


--Breaking out Address into Individual Columns (Address, City, State)

SELECT 
SUBSTRING (propertyaddress, 1, CHARINDEX (',', propertyaddress) -1) AS Address,
SUBSTRING (propertyaddress, CHARINDEX (',', propertyaddress) +1, LEN(propertyaddress))  AS Address
FROM NashvilleHousingDataforDataCleaning;


ALTER TABLE NashvilleHousingDataforDataCleaning
ADD PropertySpiltAddress nvarchar(255);

UPDATE NashvilleHousingDataforDataCleaning
SET PropertySpiltAddress = SUBSTRING (propertyaddress, 1, CHARINDEX (',', propertyaddress) -1);


ALTER TABLE NashvilleHousingDataforDataCleaning
ADD PropertySpiltCity nvarchar(255);

UPDATE NashvilleHousingDataforDataCleaning
SET PropertySplitCity = SUBSTRING (propertyaddress, CHARINDEX (',', propertyaddress) +1, LEN(propertyaddress)) ;

SELECT *
FROM NashvilleHousingDataforDataCleaning;



--Making use of parsename instead of substrings
SELECT 
PARSENAME (REPLACE(owneraddress, ',' , '.'), 3),
PARSENAME (REPLACE(owneraddress, ',' , '.'), 2),
PARSENAME (REPLACE(owneraddress, ',' , '.'), 1)
FROM NashvilleHousingDataforDataCleaning;

ALTER TABLE NashvilleHousingDataforDataCleaning
ADD OwnerSplitAdddress nvarchar (255);

UPDATE NashvilleHousingDataforDataCleaning
SET OwnerSplitAdddress = PARSENAME (REPLACE(owneraddress, ',' , '.'), 3);

ALTER TABLE NashvilleHousingDataforDataCleaning
ADD OwnerSplitCity nvarchar (255); 

UPDATE NashvilleHousingDataforDataCleaning
SET OwnerSplitCity = PARSENAME (REPLACE(owneraddress, ',' , '.'), 2);


ALTER TABLE NashvilleHousingDataforDataCleaning
ADD OwnerSplitState nvarchar (255);

UPDATE NashvilleHousingDataforDataCleaning
SET OwnerSplitState = (REPLACE(owneraddress, ',' , '.'), 1);

SELECT *
from NashvilleHousingDataforDataCleaning;


-- Change Y and N to Yes and No in "Sold as Vacant" field 

SELECT DISTINCT(soldasvacant), COUNT (soldasvacant)
from NashvilleHousingDataforDataCleaning
GROUP by soldasvacant
ORDER BY 2;

SELECT soldasvacant,
CASE
	when soldasvacant = 'Y' then 'Yes'
    WHEN soldasvacant = 'N' THEN 'No'
    ELSE soldasvacant
 END
from NashvilleHousingDataforDataCleaning;


UPDATE NashvilleHousingDataforDataCleaning
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
 FROM NashvilleHousingDataforDataCleaning
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
 FROM NashvilleHousingDataforDataCleaning
  )
DELETE
from RowNumCTE
WHERE row_num > 1;

-- delete unused columns  

SELECT * 
from NashvilleHousingDataforDataCleaning;

ALTER table NashvilleHousingDataforDataCleaning
DROP COLUMN owneraddress, taxdistrict, propertyaddress, saledate;


