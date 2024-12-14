SELECT * FROM layoffs;

-- 1. Remove duplicates
-- 2. Standardize the data 
-- 3. Null values or blank values
-- 4. Remove any columns

CREATE TABLE layoff_staging
LIKE layoffs;

SELECT * FROM layoff_staging;

INSERT layoff_staging
SELECT * FROM layoffs;

SELECT * FROM layoff_staging;

-- 1. Remove duplicates

SELECT ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off,`date`, 
stage, country, funds_raised_millions) row_num, 
layoff_staging.* 
FROM layoff_staging;

WITH duplicate_cte AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
	total_laid_off, percentage_laid_off,`date`, 
	stage, country, funds_raised_millions) row_num, 
	layoff_staging.* 
	FROM layoff_staging
)

#SELECT row_num, COUNT(*) FROM duplicate_cte
#GROUP BY row_num
SELECT * FROM duplicate_cte
WHERE row_num > 1;

SELECT * FROM layoff_staging
WHERE company = 'Casper';

WITH drop_duplicate_cte AS
(
	SELECT ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
	total_laid_off, percentage_laid_off,`date`, 
	stage, country, funds_raised_millions) row_num, 
	layoff_staging.* 
	FROM layoff_staging
)

DELETE FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE layoff_staging2 (
  `row_num` INT,
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_staging2
SELECT ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
	total_laid_off, percentage_laid_off,`date`, 
	stage, country, funds_raised_millions) row_num, 
	layoff_staging.* 
FROM layoff_staging;

DELETE FROM layoff_staging2
WHERE row_num > 1;

SELECT * FROM layoff_staging2
WHERE row_num > 1;

SELECT COUNT(*) Total_rows,
(SELECT COUNT(*) FROM layoff_staging2) unique_rows
FROM layoffs;

-- 2. Standardizing data
SELECT company, TRIM(company) 
FROM layoff_staging2;

UPDATE layoff_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoff_staging2
ORDER BY 1;

# Fin-Tech and Finance are two different industries
# finance => Traditional Methods and Fin-tech => combines finance with technology
SELECT * FROM layoff_staging2
WHERE industry LIKE 'Fin%';

# Crypto and Cryptocurrency are same industries
SELECT * FROM layoff_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoff_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

SELECT DISTINCT location
FROM layoff_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoff_staging2
ORDER BY 1;

UPDATE layoff_staging2
SET country = 'United States'
WHERE country = 'United States.';

SELECT DISTINCT stage FROM layoff_staging2;


SHOW COLUMNS FROM layoff_staging2
WHERE field = 'date';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') date_conversion
FROM layoff_staging2;

UPDATE layoff_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoff_staging2
MODIFY COLUMN `date` DATE;

-- 3. Null values or blank values
SELECT * FROM layoff_staging2
WHERE industry IS NULL
OR industry = '';

SELECT * FROM layoff_staging2
WHERE company = "Airbnb";

SELECT t1.industry, t2.industry
FROM layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

# By updating blank values to NULL, you can more explicitly mark missing data and 
# later change it to another value. This distinction helps in data processing and 
# logical conditions, as NULL is easier to handle as "missing" data compared to blanks.
UPDATE layoff_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT COUNT(*) FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- 4. Remove any columns
ALTER TABLE layoff_staging2
DROP COLUMN row_num;

SELECT * FROM layoff_staging2;