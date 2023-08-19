/*
Cleaning Data in SQL Queries
*/
-------------------------------------------------------------------------------------------------------------------

SELECT *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

/*                                          --USE THE MAGIC KEY--
Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)
*/

-------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, a.UniqueID, b.UniqueID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySpliteAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySpliteAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySpliteCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySpliteCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..NashvilleHousing

                           ---------------------------------------------------

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT OwnerAddress
, TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)) AS Address
, TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)) AS City
, TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)) AS State
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSpliteAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSpliteAddress = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3))


ALTER TABLE NashvilleHousing
ADD OwnerSpliteCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSpliteCity = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2))


ALTER TABLE NashvilleHousing
ADD OwnerSpliteState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSpliteState = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1))


SELECT *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing
WHERE SoldAsVacant = 'Y'
OR SoldAsVacant = 'N'


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

-------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
	) AS row_num

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *      --------------------------------> /* USE DELETE */
FROM RowNumCTE
WHERE row_num != 1
--ORDER BY PropertyAddress


SELECT *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

