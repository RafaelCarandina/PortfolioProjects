-- Checking out the table

SELECT
	*
FROM 
	ProjectPortifolio.dbo.Nashville

-- Checking the data types
-- Standardize 'SaleDate'(datetime to date)

ALTER TABLE ProjectPortifolio.dbo.Nashville
ALTER COLUMN SaleDate DATE

-- Checking for Nulls in 'PropertyAddress'

SELECT
	PropertyAddress
FROM
	ProjectPortifolio.dbo.Nashville
WHERE
	PropertyAddress IS NULL

-- Populate PropertyAdress 

SELECT
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM
	ProjectPortifolio.dbo.Nashville AS a
JOIN ProjectPortifolio.dbo.Nashville AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress IS NULL
	

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	ProjectPortifolio.dbo.Nashville AS a
JOIN ProjectPortifolio.dbo.Nashville AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress IS NULL

-- Breaking out address into individual columns (address, city, state)

SELECT
	PropertyAddress
FROM
	ProjectPortifolio.dbo.Nashville

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS address
FROM
	ProjectPortifolio.dbo.Nashville

 -- Breaking out OwnerAddress

 SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
 FROM
	ProjectPortifolio.dbo.Nashville

ALTER TABLE ProjectPortifolio.dbo.Nashville
ADD PropertySplitAddress Nvarchar(255);

UPDATE ProjectPortifolio.dbo.Nashville
SET PropertySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE ProjectPortifolio.dbo.Nashville
ADD PropertySplitCity Nvarchar(255);

UPDATE ProjectPortifolio.dbo.Nashville
SET PropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE ProjectPortifolio.dbo.Nashville
ADD PropertySplitState Nvarchar(255);

UPDATE ProjectPortifolio.dbo.Nashville
SET PropertySplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y to 'Yes' and N to 'No' in 'SoldASVacant'

SELECT
	DISTINCT(SoldAsVacant)
FROM
	ProjectPortifolio.dbo.Nashville

SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldASVacant)
FROM
	ProjectPortifolio.dbo.Nashville
GROUP BY
	SoldAsVacant
ORDER BY
	2

SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM
	ProjectPortifolio.dbo.Nashville

UPDATE ProjectPortifolio.dbo.Nashville
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY
			UniqueID
				) row_num
FROM
	ProjectPortifolio.dbo.Nashville
)

DELETE
FROM 
	RowNumCTE
WHERE
	row_num > 1

-- Delete Unused Columns

ALTER TABLE ProjectPortifolio.dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

