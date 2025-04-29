# downloaded layoff data file from kaggle

# data cleaning
# remove duplicates
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

select * 
from layoffs;

-- create a secondary layoff table called layoff_staging where we can make all the changes safely.
CREATE table layoffs_staging
LIKE layoffs;

select * 
from layoffs_staging;

-- copy all the values from main layoffs table
insert into layoffs_staging
select * from layoffs;


-- start data cleaning by identifying any duplicate rows
with duplicate_cte as 
(
select *, ROW_NUMBER() OVER(
partition by company, 
    location, 
    industry,
	total_laid_off, 
	percentage_laid_off, 
	'date',
    stage,
    country,
    funds_raised
	) 
as row_num
from layoffs_staging
)
select *
from duplicate_cte 
where row_num>1;

-- these identifies duplicate rows cannot be directly deleted as in mssql.alter hence why we create another table layoff_staging2


-- select * from layoffs_staging 
-- where company = 'McMakler';


-- we can create the same table by just copying the table schema from the tables layoffs_staging and copying the create statement
-- add new column called row_num to count the total number of repeated rows
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

drop table layoffs_staging2;

select * from layoffs_staging2;

insert into layoffs_staging2
select *, ROW_NUMBER() OVER(
partition by company, 
    location, 
    industry,
	total_laid_off, 
	percentage_laid_off, 
	"date", 
    stage,
    country,
    funds_raised
	) 
as row_num
from layoffs_staging;

-- display duplicate rows
select *
from layoffs_staging2 
where row_num > 1 ;

-- delete duplicate rows
delete
from layoffs_staging2 
where row_num > 1 ;

select *
from layoffs_staging2 ;

-- standardization of data --> finding issues and then fixing it
-- 2023-05-04T00:00:00.000Z --> ISO 8601 format
-- SUBSTRING_INDEX(str, delimiter, count)
-- string you want to cut, delimiter you want to cut around and how many you want to keep(for -1 it keeps the last part, 1 it keeps the initial part)

select *
from layoffs_staging2 ;



UPDATE layoffs_staging2
SET date= SUBSTRING_INDEX(date, 'T', 1);

-- modify the date type to date from text
ALTER TABLE layoffs_staging2
MODIFY date DATE;

-- remove uncessary columns
ALTER TABLE layoffs_staging2
drop column row_num;


select *
from layoffs_staging2
where industry = '';

select *
from layoffs_staging2
where company = 'Appsmith';

select *
from layoffs_staging2
where company = 'relevel';

select * 
from layoffs_staging2
where percentage_laid_off = '';


-- here, we cleaned the data via removal of duplicates, removal of unnecessary columns, standardization, removal of null values


