-- DATA CLEANING 
use world_layoffs;
SELECT * FROM layoffs order by total_laid_off desc ;


-- 1. REMOVE DUPLICATES
-- 2. STANDARDIZE THE DATE 
-- 3. NULL VALUES OR BLANK VALES
-- 4. REMOVE ANY COLUMNS OR ROWS


CREATE TABLE  layoffs_staging
like layoffs;

insert layoffs_staging
select * from layoffs;

-- NOW WE ARE CREATING A ROW NUMBER. IF THE ROW NUMBER IS 1 THEN THERE THIS NO REPEATED VALUES  -> WINDOW FUNCTION
select * , 
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;

-- CREATING A CTE TO CHECK OF THERE IS ANY ROW_NUM WITH MORE VALUE MORE THAN 1 -> CTE
WITH duplicate_cte as 
(
select * , 
row_number() over(
partition by company,location, industry, total_laid_off, percentage_laid_off, `date`, stage,country, funds_raised_millions) as row_num
from layoffs_staging
)
SELECT *  from duplicate_cte where row_num > '1';

WITH duplicate_cte as 
(
select * , 
row_number() over(
partition by company,location, industry, total_laid_off, percentage_laid_off, `date`, stage,country, funds_raised_millions) as row_num
from layoffs_staging
)
DELETE from duplicate_cte where row_num > '1';


 -- HERE WE HAVE CREATE A NEW TABLE layoffs_staging2 BECAUSE WE CANNOT DELETE THE REPEATED VALUES USING THE CTE 

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
 
 select * from layoffs_staging2;
 
 -- NOW COPPING THE VALUE FROM THE WINDOW FUNCTION INCLUDING ROW_NUM
insert into layoffs_staging2
select * , 
row_number() over(
partition by company,location, industry, total_laid_off, percentage_laid_off, `date`, stage,country, funds_raised_millions) 
as row_num
from layoffs_staging;

select * from layoffs_staging2 where row_num > 1;

delete from layoffs_staging2 where row_num > 1;


-- show variables like 'event%';
-- SET SQL_SAFE_UPDATES = 0;

-- STANDARDIZING DATA 
-- HERE USING TRIM TO REMOVE ANY WHITE SPACES 
SELECT company, (trim(company)) from layoffs_staging2;
update layoffs_staging2 set company = trim(company);

-- now checking thee industry and fixing it
select distinct(industry) from layoffs_staging2 order by 1 ;

select industry from layoffs_staging2 where industry like 'crypto%';

update layoffs_staging2 set industry = 'Crypto'
where industry like 'Crypto%';

select distinct(country) from layoffs_staging2 order by 1 ;

-- here we are removing the the . from the country using like and update
update layoffs_staging2 set country = 'United States'
where country like 'United States%';

-- here we are removing the . using trailing
update layoffs_staging2 set country = trim(trailing'.' from country)
where country like 'United States%';

-- now changing the date from string to date format
update layoffs_staging2 set `date` = str_to_date(`date`, '%m/%d/%Y');
select * from layoffs_staging2 order by company asc ;

-- changing the datatype of the date colum

alter table layoffs_staging2 modify column `date` Date;

-- NULL AND BLANK VALUES

select * from layoffs_staging2 where total_laid_off is null
and percentage_laid_off is null;

select * from layoffs_staging2; 

update layoffs_staging2 set industry = null
where industry = '';

-- populating the the null values in industry using the values beloongs to the same company with anyother entries
select t1.industry, t2.industry from layoffs_staging2 as t1
		join layoffs_staging2 as t2 
        on t1.company = t2.company 
        and t1.location = t2.location
where (t1.industry is null or t1.industry = ' ')
and t2.industry is not null; 

update layoffs_staging2 t1
join layoffs_staging2 as t2 
        on t1.company = t2.company 
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = ' ')
and t2.industry is not null; 
       
-- deleting rows where total_laid_off and percentage_laid_off is null

delete 
from layoffs_staging2 where total_laid_off is null
and percentage_laid_off is null;	

-- now droping a column row_num
alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2;

