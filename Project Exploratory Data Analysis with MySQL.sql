-- Exploratory Data Analysis --

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
-- from this we know that the most total laid off is 12k people.
-- there's even a 100% laid off percentage.

-- Let's find out what companies have 100% employee layoffs.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;
-- from here we know that there are a lot of companies that lay off their employees up to 100% 
-- with a total of 116 companies.

-- we sort by the most total laid off
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
-- The company with the highest number of layoffs is Katerra in the US with a total of 2434 people. 

-- we sort again by funds_raised_millions to find which companies get the most funds
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- based on funds_raised_millions the company that gets the most funds is Britishvolt (UK) with a total of 2400 millions in funds.

-- Now we check the most total laid off by company to find out which company has the most total laid off in this dataset.
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- we check the date range that we have in this data
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- now we know that this data was taken from 2020-03-11 to 2023-03-06.
-- maybe one of the reasons for this many layoffs is the effect of the Covid-19 pandemic at that time.

-- Let's see which industry has the most employee layoffs by calculating the total laid off by industry.
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
-- and we can see that the consumer and retail industries are the top industries with the most employee layoffs.
-- yes, that's natural because during the pandemic, many stores were closed.
-- besides that this covid has a huge impact on many fields such as transportation, finance, health, etc.

-- now let's check what countries have the most total layoffs.
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- woah the US is in the top 1 with 256k followed by India and the Netherlands, 
-- I'm surprised that my country Indonesia is in 12th place most layoffs employees

-- let's look at the total laid off per year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- it turns out that the total laid off always increases from 2020 to 2022 and drops back in 2023,
-- with a peak in 2022 with a total of 160k.

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- we look at the percentage because it reflects how much of the company is being laid off.
SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- rolling total layoffs
-- we make rolling total layoffs based on the month of the year.
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS (
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC )
SELECT `MONTH`, total_off
, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- from this rolling total we can know that
-- starting from 2020-03 the total layoffs = 9628
-- at the end of 2020, 80998 people were laid off.
-- then at the beginning of 2021 increased by 6813 to 87811
-- at the end of 2021 as many as 96821 have been laidoffs
-- the beginning of 2022 increased again to 97331
-- by the end of 2022 it had reached 257482
-- then at the beginning of 2023 it reached 342196
-- and by March of 2023, 383159 people had been laid off from their jobs.
-- so from March 2020 to March 2023, 383159 people have been laid off from their jobs.


-- next we will calculate how many total laid off from the company per year.
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;

-- next we will calculate how many total laid off from the company per year.
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

