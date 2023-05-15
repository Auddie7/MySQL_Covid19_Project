/*  CLEANING HOUSING DATA WITH SQL QUERIES */

Select * 
From NashvilleHousingProject.dbo.NashvilleHousing

/*Standardizing the sale date format to remove the time stamp at the end 
by creating a new column called SaleDateConverted*/

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing 
Set SaleDateConverted = Convert (date, SaleDate);

/*Populating PropertyAddress columns that display NULL. The 
reason why it displays NULL sometimes is that the ParcelID
repeats accross some rows, and when that happens the PropertyAddress
then displays NULL.  To accomplish this, a self join is used*/
 
Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from NashvilleHousingProject.dbo.NashvilleHousing a
JOIN NashvilleHousingProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
   WHERE a.PropertyAddress is null

   /*Verifying that it works by selecting rows where PropertyAddress is NULL.  It retuns none, so it worked*/
   Select *
   from NashvilleHousingProject.dbo.NashvilleHousing
   where PropertyAddress is null


/* Breaking Down The PropertyAddress Column into 2 new columns: Address, City 
First Running a test query to modify the select the data wanted in the new columns*/

Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)  as Address,
Substring(PropertyAddress,  CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from NashvilleHousingProject.dbo.NashvilleHousing

/*Now creating the street address and city columns and adding them to the table*/

Alter Table NashvilleHousing
Add PropertyStreetAddress Nvarchar(255);

Update NashvilleHousing 
Set PropertyStreetAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertyCity Nvarchar(255);

Update NashvilleHousing 
Set PropertyCity = Substring(PropertyAddress,  CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

/*Verifying that the columns were successfully added*/
   Select *
   from NashvilleHousingProject.dbo.NashvilleHousing



/*Repeating the process of spliting address into columns, this time the owner address, and  using Parsename*/

Alter Table NashvilleHousing
Add OwnerStreetAddress Nvarchar(255);

Update NashvilleHousing 
Set OwnerStreetAddress = Parsename(Replace(OwnerAddress, ',','.'),3)

Alter Table NashvilleHousing
Add OwnerCity Nvarchar(255);

Update NashvilleHousing 
Set OwnerCity = Parsename(Replace(OwnerAddress, ',','.'),2)

Alter Table NashvilleHousing
Add OwnerState Nvarchar(255);

Update NashvilleHousing 
Set OwnerState = Parsename(Replace(OwnerAddress, ',','.'),1)

/*Verifying that the columns were successfully added*/
   Select *
   from NashvilleHousingProject.dbo.NashvilleHousing

/*The SoldAsVacant column has inconsistent entries with sometimes Y or Yes, 
and sometimes N or No.  Changing all Y to Yes and all N to No for consistency*/


 Update NashvilleHousing
 Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
						 When SoldAsVacant = 'N' Then 'No'
						 Else SoldAsVacant
						 End
/*Now verifying that the cells were corrected by doing a count of the SoldAsVacant column*/

Select SoldAsVacant, Count(SoldAsVacant) as CountCells
from NashvilleHousingProject.dbo.NashvilleHousing
Group By SoldAsVacant

/*Removing duplicate entries with Partition by and CTEs, then deleting the duplicate rows*/

With RowNumberCTE As (
Select *,
       Row_number() OVER (
	   Partition by ParcelID, 
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
					)
					row_num
from NashvilleHousingProject.dbo.NashvilleHousing
)
Delete 
from RowNumberCTE
Where row_num >1

