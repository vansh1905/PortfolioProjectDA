--Data Cleaning Queries

Select * from master..NashvilleHousing
------------------------------------------------------------------------------------------------------------------------------

--Standardize date column

Alter table master..NashvilleHousing
Alter Column SaleDate date
------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

Select * from master..NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select 
a.ParcelID,
a.PropertyAddress AS Address_Before,
b.PropertyAddress AS Address_To_Fill,
ISNULL(a.PropertyAddress, b.PropertyAddress)
from master..NashvilleHousing a
join
master..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from master..NashvilleHousing a
join
master..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------

--Breaking Out address into individual columns (Address, City, State)

Select PropertyAddress from master..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,	
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from master..NashvilleHousing

Alter table master..NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update master..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)	


Alter table master..NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update master..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select OwnerAddress from master..NashvilleHousing

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from master..NashvilleHousing

Alter table master..NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update master..NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

Alter table master..NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update master..NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table master..NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update master..NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in SoldAsVacant Column

Select Distinct SoldAsVacant, Count(SoldAsVacant)
from master..NashvilleHousing
group by SoldAsVacant
order by 2
 
Select SoldAsVacant 
,Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End
from master..NashvilleHousing

Update master..NashvilleHousing
Set SoldAsVacant = 
Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End

------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

Select * from master..NashvilleHousing


With RowNumCTE as
(
Select *,
	Row_Number() Over(
	Partition By ParcelID,
	PropertyAddress,
	SaleDate,
	LegalReference
	order by [UniqueID ]) as row_num
from master..NashvilleHousing
)
Delete from RowNumCTE
where row_num > 1
order by PropertyAddress

------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select * from master..NashvilleHousing

Alter Table master..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

