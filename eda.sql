
-- exploratory data analysis

select * 
from layoffs_staging2
order by date;

select max(total_laid_off) AS laid_max, max(percentage_laid_off)
from layoffs_staging2;

select *
from layoffs_staging2
where company = 'Twitter';

select year(`date`) AS year, SUM(total_laid_off) laid_max
from layoffs_staging2
group by year
order by year DESC;

select company, industry, substring_index(industry, 'h', -1) health
from layoffs_staging2
where company='23andMe';

-- here substring(str, index, offset)
-- of date values, 6th index is reached from beginning(1-6) and from there 2 chars are chosen.

select date, substring(date, 1, 7) Month, sum(total_laid_off) Month_laid_off
from layoffs_staging2
group by substring(date, 1, 7);

with month_cte as 
(
	select substring(date, 1, 7) Months, sum(total_laid_off) as month_laid_off
    from layoffs_staging2
    group by  Months
    order by Months
)
select * from month_cte;

select month_cte, sum(month_laid_off) CF
from layoffs_staging2;

with rolling_total as
(
select substring(date, 1, 7) Months, sum(total_laid_off) as month_laid_off
from layoffs_staging2
group by  Months
order by Months
) 
select Months, month_laid_off, 
	sum(month_laid_off) OVER(order by Months) as rolling_total
from rolling_total;

select * from layoffs_staging2;

-- in strict mode, mysql expects every non aggregated function in select statement to also be in group by statement

select company,  YEAR(`date`), SUM(total_laid_off) as company_laid_off
from layoffs_staging2
 group by company, YEAR(`date`)
 order by 3 desc; 
 
 -- find out ranking based on which company ranked highest layed off
 with company_year(company, years, total_laid_off) as
 (
 select company,  YEAR(`date`), SUM(total_laid_off) as company_laid_off
from layoffs_staging2
 group by company, YEAR(`date`)
 )
 select  * from company_year;
select *, dense_rank() over(partition by company order by total_laid_off desc) as rank

from company_year;



-- Check current mode
SELECT @@sql_mode;

-- Remove ONLY_FULL_GROUP_BY from the mode
SET GLOBAL sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

