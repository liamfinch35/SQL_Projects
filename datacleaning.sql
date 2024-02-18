SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [project_2_datacleaning].[dbo].[NashVilleHousing]

Select * 
from project_2_datacleaning..NashVilleHousing

-- Change sale date

Select SaleDate, CONVERT(Date, SaleDate)
from project_2_datacleaning..NashVilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashVilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate missing property addresses data

select *
from NashVilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from project_2_datacleaning..NashVilleHousing a
JOIN project_2_datacleaning..NashVilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a 
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from project_2_datacleaning..NashVilleHousing a
JOIN project_2_datacleaning..NashVilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- breaking the address into individual columns (address, city, state)

Select PropertyAddress
From project_2_datacleaning..NashVilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as City
FROM project_2_datacleaning..NashVilleHousing

ALTER TABLE NashvilleHousing
ADD Property_Address NVARCHAR(255);

UPDATE NashVilleHousing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
ADD Property_City NVARCHAR(255);

UPDATE NashVilleHousing
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))


Select *
From project_2_datacleaning..NashVilleHousing


-- PARSENAME Separating data with different method 

SELECT OwnerAddress
From project_2_datacleaning..NashVilleHousing


select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From project_2_datacleaning..NashVilleHousing



ALTER TABLE project_2_datacleaning..NashVilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update project_2_datacleaning..NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE project_2_datacleaning..NashVilleHousing
Add OwnerSplitCity Nvarchar(255);

Update project_2_datacleaning..NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE project_2_datacleaning..NashVilleHousing
Add OwnerSplitState Nvarchar(255);

Update project_2_datacleaning..NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From project_2_datacleaning..NashVilleHousing


-- Change Y and N to Yes and No in "Sold as vacant" field

Select *
From project_2_datacleaning..NashVilleHousing



Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' Then 'No'
	  ELSE SoldAsVacant
	  END
From project_2_datacleaning..NashVilleHousing

Update project_2_datacleaning..NashVilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' Then 'No'
	  ELSE SoldAsVacant
	  END
From project_2_datacleaning..NashVilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From project_2_datacleaning..NashVilleHousing
Group by SoldAsVacant
Order by 2

-- Remove duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From project_2_datacleaning..NashVilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From project_2_datacleaning..NashVilleHousing

-- deleting columns that are unused

Select *
From project_2_datacleaning..NashVilleHousing

ALTER TABLE project_2_datacleaning..NashVilleHousing
DROP COLUMN OwnerAddress