-- EXPLORATORY DATA ANALYSIS
select * from layoffs_staging2 
order by `date`;

select * from layoffs_staging2 
order by percentage_laid_off desc limit 1;

select company, max(total_laid_off) 
from layoffs_staging2 group by company order by 2 desc;

select country, max(total_laid_off) 
from layoffs_staging2 group by country order by 2 desc;

select year(`date`), max(total_laid_off) 
from layoffs_staging2 group by year(`date`) order by 1 desc;

-- MONTH WISE LAYOFF
select substring(`date`,1,7) as `Month`, sum(total_laid_off) from layoffs_staging2 
group by `Month` order by `Month`;

-- ROLLING SUM OF MONTH WISE LAYOFF -> creating a cte rolling_total 
with rolling_total as 
(
select substring(`date`,1,7) as `Month`, sum(total_laid_off) as total_off from layoffs_staging2 
group by `Month` order by `Month`asc
)
select `Month`, total_off , sum(total_off) over (order by `Month`) as Rolling_Total
from rolling_total;


SELECT company, year(`date`), MAX(total_laid_off) 
FROM layoffs_staging2 
GROUP BY company, year(`date` )
order by company;

-- RANKING TOP 5 COMPANIES BASED ON THE LAYOFF HAPPENED EACH YEAR
with company_year (company, years ,total_laid_off) as 
(
SELECT company, year(`date`), sum(total_laid_off) 
FROM layoffs_staging2 
GROUP BY company, year(`date` )
),
company_year_rank as
( 
select * , dense_rank() over (partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select * from company_year_rank
where ranking  <= 5;
