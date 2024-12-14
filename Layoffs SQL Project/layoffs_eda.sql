-- Exploratory Data Analysis
SELECT * FROM layoff_staging2;

-- 1: Get the date range of layoffs in the dataset.
SELECT MIN(`date`) start_date, MAX(`date`) end_date
FROM layoff_staging2;

-- 2: Retrieve the record with the maximum number of employees laid off.
SELECT * FROM layoff_staging2
WHERE total_laid_off = (SELECT MAX(total_laid_off) FROM layoff_staging2);

-- 3: Find the company with the highest percentage of employees laid off, sorted by funds raised.
SELECT company, funds_raised_millions, percentage_laid_off
FROM layoff_staging2
WHERE percentage_laid_off = (SELECT MAX(percentage_laid_off)
FROM layoff_staging2)
ORDER BY funds_raised_millions DESC;

-- 4: Find the company with the highest percentage of layoffs, sorted by the total number of employees laid off.
SELECT company, total_laid_off, percentage_laid_off
FROM layoff_staging2
WHERE percentage_laid_off = (SELECT MAX(percentage_laid_off)
FROM layoff_staging2)
ORDER BY total_laid_off DESC;

-- 5: Total layoffs grouped by company, sorted in descending order.
SELECT company, SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company
ORDER BY 2 DESC;

-- 6: Total layoffs grouped by industry, sorted in descending order.
SELECT industry, SUM(total_laid_off) Total_layoffs
FROM layoff_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- 7: Total layoffs grouped by country, sorted in descending order.
SELECT country, SUM(total_laid_off) Total_layoffs
FROM layoff_staging2
GROUP BY country
ORDER BY 2 DESC;

-- 8: Total layoffs grouped by year, sorted in descending order.
SELECT YEAR(`date`), SUM(total_laid_off) Total_layoffs
FROM layoff_staging2
GROUP BY 1
ORDER BY 1 DESC;

-- 9: Total layoffs grouped by company stage, sorted by layoffs.
SELECT stage, SUM(total_laid_off) Total_layoffs
FROM layoff_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- 10: Monthly layoffs grouped by year and month, excluding null values.
SELECT SUBSTRING(`date`, 1, 7) `Month`, SUM(total_laid_off) Total_layoffs
FROM layoff_staging2
GROUP BY `Month`
HAVING `Month` IS NOT NULL
ORDER BY 1;

-- 11: Cumulative rolling total of layoffs by month.
WITH rolling_total_layoffs AS
(
	SELECT SUBSTRING(`date`, 1, 7) `Month`, SUM(total_laid_off) Total_layoffs
	FROM layoff_staging2
	GROUP BY `Month`
	HAVING `Month` IS NOT NULL
	ORDER BY 1
)

SELECT `Month`, Total_layoffs,
SUM(Total_layoffs) OVER(ORDER BY `Month`) rolling_total
FROM rolling_total_layoffs;

-- 12: Annual layoffs grouped by company, sorted by layoffs in descending order.
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging2
GROUP BY 1,2
ORDER BY 3 DESC;

-- 13: Top 5 companies with the highest layoffs each year.
WITH company_year (company, years, total_laid_offs) AS
(
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoff_staging2
	GROUP BY 1,2
), company_year_ranking AS 
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_offs DESC) Ranking
FROM company_year
WHERE years IS NOT NULL
)

SELECT * FROM company_year_ranking
WHERE Ranking <= 5;



