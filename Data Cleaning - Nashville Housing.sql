/* Cleaning Data */

select *
from PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate Date

select *
from PortfolioProject.dbo.NashvilleHousing


-- Populate Property Address

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]

UPDATE a
SET PropertyAddress = COALESCE(b.PropertyAddress,a.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


-- Breaking out address into individual columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
from PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

select *
from PortfolioProject.dbo.NashvilleHousing


-- Remove Duplicates

WITH RowNum AS (
select *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
)
DELETE
from RowNum
where row_num > 1

-- double check on duplicates
WITH RowNum AS (
select *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
)
select *
from RowNum
where row_num > 1
order by PropertyAddress

select *
from PortfolioProject.dbo.NashvilleHousing


-- Create View with the Needed Columns

select *
from PortfolioProject.dbo.NashvilleHousing

CREATE VIEW final_nashville_housing_data as
select *
from PortfolioProject.dbo.NashvilleHousing

ALTER VIEW final_nashville_housing_data as
select [UniqueID ], SaleDate, SalePrice, ParcelID, LandUse, LegalReference, SoldAsVacant, OwnerName, Acreage,
LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath, PropertySplitAddress,
PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState 
from PortfolioProject.dbo.NashvilleHousing

select *
from final_nashville_housing_data


-- Delete Unused Columns
--ALTER TABLE PortfolioProject.dbo.NashvilleHousing
--DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

--select *
--from PortfolioProject.dbo.NashvilleHousing