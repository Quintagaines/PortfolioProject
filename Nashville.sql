/*
Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing

--Standardize Date Format----------------------------------------------------------------------------------------------------

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing



-- Alter Table to Add SaleDateConverted column
ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date;

-- Update values in SaleDateConverted using CONVERT function
UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

/*
Populate Property Address Data-----------------------------------------------------------------------------------

*/

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is Null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress )
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress )
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

---Breaking out Address into Individual Columns (Address, City, State)---------------------------------------------------------------



Select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing

-- Alter Table to Add PropertySplitAddress column
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

-- Update values in PropertySplitAddress using SUBSTRING
UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

-- Alter Table to Add PropertySplitCity column
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

-- Update values in PropertySplitCity using SUBSTRING
UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));





Select 
PARSENAME(REPLACE(OwnerAddress, ',' ,  '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',' ,  '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',' ,  '.') , 1)
From PortfolioProject..NashvilleHousing




ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);


UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,  '.') , 3)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);


UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' ,  '.') , 1)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);


UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' ,  '.') , 2)



Exec sp_rename 'NashvilleHousing.OwnerSplitAddress2', 'OwnerSplitAddress'

---Change Y and N to Yes and No in "Sold As Vacant field"
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 1



Select Distinct(ParcelID)
From PortfolioProject..NashvilleHousing

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing



----Remove Duplicates-------------------------------------------------------------------------------------------------


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

)

SELECT *
FROM RowNumCTE
Where row_num >1
Order by PropertyAddress





---DELETE UNUSED COLUMNS

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN 
		OwnerAddress,
		TaxDistrict,
		PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN 
		SalePrice