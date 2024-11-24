-- EXploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- Maximum layoff count and layoff percentage
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off =1
ORDER by funds_raised_millions DESC;

-- Total layoffs by company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Earliest to last date of layoff
SELECT MIN(`date`),MAX(`date`)
FROM layoffs_staging2;

-- Total layoff by company per year
SELECT company, YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
ORDER BY 3 DESC;

-- Ranking top 5 companies by layoffs per year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
ORDER BY 3 DESC
), Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC )AS Ranking
FROM Company_Year
WHERE years IS NOT NULL 
)
SELECT *
FROM Company_year_Rank
WHERE Ranking <= 5  
;



