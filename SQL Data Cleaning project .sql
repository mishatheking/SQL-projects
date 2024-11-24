-- Data Cleaning

SELECT * 
FROM layoffs;

-- 1 Remove duplicates
-- 2 Standardize the data
-- 3 Null/Blank values
-- 4 Remove unnecessary columns

-- Creating a work table
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- 1. finding duplicates by using Row_Number window fuction to id duplicate values from a column set
SELECT * ,
ROW_NUMBER()  OVER(
PARTITION BY company,location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging;

-- Pulling out the duplicates based on row number 
WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER()  OVER(
PARTITION BY company,location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company ="Yahoo";

SELECT *
FROM layoffs_staging
WHERE company ="Casper";

WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER()  OVER(
PARTITION BY company,location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;
-- Because the delete query wont work in mysql( for lack of direct modification of CTEs)
-- a good option is to save the output to a new table and remove the rows with row_num >1


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

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER()  OVER(
PARTITION BY company,location, industry, total_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num >= 2;  


-- 2. Standardizing data (finding issuses in data and fixing it)

SELECT *
FROM layoffs_staging2;

-- company column
SELECT company, TRIM(company) 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- industry column
SELECT DISTINCT industry 
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE "crypto%";

UPDATE layoffs_staging2
SET industry = "Crypto"
WHERE industry LIKE "crypto%";

-- 
SELECT DISTINCT location 
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country 
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE "United State%";

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


-- TIme series
SELECT *
FROM layoffs_staging2;

-- converting text back to date
SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

-- coverting the date column into date format
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3 Null/Blank values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = "Bally's Interactive";

SELECT t1.company, t1.location, t1.industry,t2.company, t2.location, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry is NULL OR t1.industry = '')
AND t2.industry IS NOT NULL 
-- The query finds all records in the layoffs_staging2 table where the industry field is either NULL or empty for a particular company (t1), 
-- and there is at least one other record for the same company (t2) where the industry field is not NULL.
;

SELECT *
FROM layoffs_staging2
WHERE company = "Carvana";

-- updating 
-- turning blanks to null
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- join table on itself, find company with duplicate entries 
-- and fill the indusrty for the blank one if availbale
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry is NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE company = "Juul";

SELECT *
FROM layoffs_staging2
WHERE company = "Carvana";

-- 4 Remove unnecessary rows
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
OR percentage_laid_off IS NULL;

-- Removing row number
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2
WHERE (total_laid_off IS NULL OR total_laid_off = '') 
OR (percentage_laid_off IS NULL OR percentage_laid_off = '')
;

-- Our Job is almost done 