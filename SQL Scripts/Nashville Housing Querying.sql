/*
--cleaning data in SQL Queries
--this project's purpose was to clean/correct/make data neat for a more optimal use 
*/ 

select * 
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

--standarized date format

select SaleDate
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

select SaleDate, CONVERT(date, SaleDate) as FormatedSaleDate 
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

update [Nashville Housing Data for Data Cleaning]
set SaleDate = CONVERT(date, SaleDate)

--populate property address data

select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) PopulatedProperty
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] a
join PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] a
join PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into individual colums (address, city, state)

select PropertyAddress
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

alter table PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
add PropertySplitAddress varchar(255); 

update [Nashville Housing Data for Data Cleaning]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

alter table PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
add PropertySplitCity varchar(255); 

update [Nashville Housing Data for Data Cleaning]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

--break apart owner address

select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

select OwnerAddress
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State 
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

--fill missing data

alter table PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
add OwnerSplitAddress nvarchar(255); 

update [Nashville Housing Data for Data Cleaning]
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

alter table PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
add OwnerSplitCity nvarchar(255); 

update [Nashville Housing Data for Data Cleaning]
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

alter table PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
add OwnerSplitState varchar(50); 

update [Nashville Housing Data for Data Cleaning]
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 

select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

--note: more efficent to set apart data as small as possible

--change 0/1 to Yes/No in "sold in vacant" field

select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

select distinct(SoldAsVacant), COUNT(SoldAsVacant) AS VacantCount
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
group by SoldAsVacant
order by 2


--case statement
--convert data type conversion error

select Convert(nvarchar, SoldAsVacant) as SoldAsVacant
,case when Convert(nvarchar, SoldAsVacant) = 1 then 'Yes'
	when Convert(nvarchar, SoldAsVacant) = 0 then 'No'
	else Convert(nvarchar, SoldAsVacant)
	end as CorrectedSoldAsVacant
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]


alter table PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
add SoldAsVacantConvert nvarchar(50); 

update [Nashville Housing Data for Data Cleaning]
set SoldAsVacantConvert = case when Convert(nvarchar, SoldAsVacant) = 1 then 'Yes'
	when Convert(nvarchar, SoldAsVacant) = 0 then 'No'
	else Convert(nvarchar, SoldAsVacant)
	end 

select distinct(SoldAsVacantConvert), COUNT(SoldAsVacant) AS VacantCount
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
group by SoldAsVacantConvert
order by 2

--remove duplicates
--write a cte, use windows function to find duplicates
--write query 1st

--check for duplicates
select *,
	ROW_NUMBER() over (
	partition by ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
	order by UniqueID
	) row_num
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
order by ParcelID

--cte table
with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
	order by UniqueID
	) row_num
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
--order by ParcelID
)
--delete
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress
--all duplcate should be gone

select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

--delete unused columns
select *
from PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]

alter table PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.[Nashville Housing Data for Data Cleaning]
drop column SoldAsVacant, SaleDate
