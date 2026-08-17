SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing]



--1: STANDARDIZE DATE FORMAT



SELECT SaleDate, CONVERT(Date,SaleDate) SaleDateConverted
FROM [PortfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD SaleDateConverted date

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)







--2:POPULATE PROPERTY ADDRESS DATA

--Same ParcelId's have same PropertyAddress


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID AND
a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID AND
a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is NULL





--3:BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(Address,state,city)


--PropertyAddress
SELECT PropertyAddress, 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) Address, 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) state
FROM [PortfolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD PropertySplitAddress nvarchar(250), PropertySplitCity nvarchar(250)

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
    PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) 




--OwnerAddress
SELECT PARSENAME(Replace(OwnerAddress,',','.'), 1) state,
PARSENAME(Replace(OwnerAddress,',','.'), 2) city,
PARSENAME(Replace(OwnerAddress,',','.'), 3) Address
FROM [PortfolioProject].[dbo].[NashvilleHousing]
WHERE OwnerAddress IS NOT NULL

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD OwnerSplitAddress nvarchar(250), 
    OwnerSplitCity nvarchar(250), 
    OwnerSplitState nvarchar(250)

UPDATE [PortfolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3),
    OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2),
	OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)





--4:CHANGE 'Y' AND 'N' TO 'yes' AND 'No' IN "SoldAsVacant" FIELD



SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
                    END
FROM PortfolioProject..NashvilleHousing

--Check

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant






--5:REMOVE DUPLICATES


--Finds Duplicate
WITH CTE_RowNum AS
(
SELECT * ,
ROW_NUMBER() OVER
(PARTITION BY ParcelID,
			  PropertyAddress,
			  SaleDate,
			  LegalReference
			  ORDER BY UniqueId) row_num

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)


SELECT *
--DELETE
FROM CTE_RowNum
WHERE row_num>1








--6:DELETE UNUSED COLUMNS



--SELECT *
DELETE*
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress,OwnerAddress






--7:FIXING SPELLING ERRORS


--Finding typos
SELECT LandUse, COUNT(LandUse)
FROM PortfolioProject..NashvilleHousing
GROUP BY LandUse
HAVING LandUse LIKE 'VACANT%'
ORDER BY LandUse

--Fixing typos
SELECT LandUse,
CASE 
	WHEN LandUse = 'VACANT RES LAND' or LandUse = 'VACANT RESIENTIAL LAND' THEN 'VACANT RESIDENTIAL LAND'
	ELSE LandUse
	
END
FROM PortfolioProject..NashvilleHousing
--WHERE LandUse LIKE 'VACANT%'
ORDER BY LandUse

--Updating typos
UPDATE PortfolioProject..NashvilleHousing
SET LandUse = 
CASE 
	WHEN LandUse = 'VACANT RES LAND' or LandUse = 'VACANT RESIENTIAL LAND' THEN 'VACANT RESIDENTIAL LAND'
	ELSE LandUse
	
END



