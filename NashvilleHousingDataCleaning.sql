/* 

Cleaning Data in SQL Queris

*/

SELECT *
FROM [Portfolio Projects]..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Changing Date Format From DateTime to Date 

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM [Portfolio Projects]..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConv Date;

UPDATE NashvilleHousing
SET SaleDateConv = Convert(Date, SaleDate)

--Checking if the column updated Properly
SELECT SaleDateConv, CONVERT(DATE, SaleDate)
FROM [Portfolio Projects]..NashvilleHousing



------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data


SELECT *
FROM [Portfolio Projects]..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

--There are nullls on property address however parcelID can be used as a reference point 
--to fill in missing data when the unique ID does not match 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Projects]..NashvilleHousing a
JOIN [Portfolio Projects]..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Projects]..NashvilleHousing a
JOIN [Portfolio Projects]..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null







------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT *
FROM [Portfolio Projects]..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM [Portfolio Projects]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyStreet Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT OwnerStreet, OwnerCity, OwnerState
FROM [Portfolio Projects]..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Projects]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerStreet Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant"


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Projects]..NashvilleHousing
Group BY SoldAsVacant
Order By 2



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
FROM [Portfolio Projects]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END

------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
)row_num
FROM [Portfolio Projects]..NashvilleHousing
)
DELETE
FROM RowNumCTE
Where row_num > 1
--Order by [UniqueID ]


------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Unused columns 

SELECT *
FROM [Portfolio Projects]..NashvilleHousing

ALTER TABLE [Portfolio Projects]..NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict

--Renamed SaleDateConv to SaleDate using the object explorer

------------------------------------------------------------------------------------------------------------------------------------------------------------------
