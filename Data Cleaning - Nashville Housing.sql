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
