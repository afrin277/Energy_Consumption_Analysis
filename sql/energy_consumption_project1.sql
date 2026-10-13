CREATE DATABASE energy_consumption_project;
USE energy_consumption_project;

SHOW TABLES;

select * from country_3;
select * from population_3;
select * from production_3;
select * from gdp_3;
select * from consum_3;
select * from emission_3;

DESCRIBE country_3;
DESCRIBE emission_3;
DESCRIBE population_3;
DESCRIBE production_3;
DESCRIBE gdp_3;
DESCRIBE consum_3;


-- RELATIONSHIPS TO CREATE
-- 4. Once data is imported , use alter to create relationships between tables
-- Note: check the er-diagraam to create relationships between the tables

-- We’ll do this in 2 parts:
-- PART A — CHANGE COLUMN TYPES
-- 1) Parent table country_3
ALTER TABLE country_3
MODIFY COLUMN country VARCHAR(100);

-- 2) emission_3
ALTER TABLE emission_3
MODIFY COLUMN country VARCHAR(100);

-- 3) production_3
ALTER TABLE production_3
MODIFY COLUMN country VARCHAR(100);

-- 4) consum_3
ALTER TABLE consum_3
MODIFY COLUMN country VARCHAR(100);

-- 5) gdp_3
ALTER TABLE gdp_3
MODIFY COLUMN country VARCHAR(100);

-- 6) population_3
ALTER TABLE population_3
MODIFY COLUMN countries VARCHAR(100);

-- PART B — CREATE RELATIONSHIPS
ALTER TABLE country_3
ADD UNIQUE (country);

-- 1) country → emission_3
ALTER TABLE emission_3
ADD CONSTRAINT fk_emission_country
FOREIGN KEY (country)
REFERENCES country_3(country);

-- 2) country → population_3
ALTER TABLE population_3
ADD CONSTRAINT fk_population_country
FOREIGN KEY (countries)
REFERENCES country_3(country);

-- 3) country → production_3
ALTER TABLE production_3
ADD CONSTRAINT fk_production_country
FOREIGN KEY (country)
REFERENCES country_3(country);

-- 4) country → consum_3
ALTER TABLE consum_3
ADD CONSTRAINT fk_consum_country
FOREIGN KEY (country)
REFERENCES country_3(country);

-- 5) country → gdp_3
ALTER TABLE gdp_3
ADD CONSTRAINT fk_gdp_country
FOREIGN KEY (country)
REFERENCES country_3(country);



-- SECTION A: GENERAL & COMPARATIVE ANALYSIS
-- Q1. Total emission per country for most recent year

-- checking the most recent year 
SELECT DISTINCT year
FROM emission_3
ORDER BY year DESC;

SELECT MAX(year) AS most_recent_year
FROM emission_3;

SELECT year,
       country,
       SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY year, country
ORDER BY total_emission DESC;

-- Q2. Top 5 countries by GDP
SELECT country, value as GDP
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY value DESC
LIMIT 5;

-- Q3. Compare production and consumption

-- CHECKING AVAILABLE YEARS IN BOTH TABLES
SELECT DISTINCT year
FROM production_3
ORDER BY year;

SELECT DISTINCT year
FROM consum_3
ORDER BY year;

-- DATA REALLY HAS ZERO VALUES
SELECT *
FROM consum_3
WHERE country = 'Afghanistan';

SELECT *
FROM production_3
WHERE country = 'Afghanistan';

SELECT p.country, p.year,
       p.production,
       c.consumption
FROM production_3 p
JOIN consum_3 c
ON p.country = c.country
AND p.year = c.year;

-- Q4. Which energy types contribute most to emissions across all countries?
DESCRIBE emission_3;

SELECT `energy type`,
       SUM(emission) AS total_emission
FROM emission_3
GROUP BY `energy type`
ORDER BY total_emission DESC;

-- Trend Analysis Over Time
-- Q5. How have global emissions changed year over year?
SELECT year,
       SUM(emission) AS global_emission
FROM emission_3
GROUP BY year
ORDER BY year;

-- Q6. What is the trend in GDP for each country over the given years?
SELECT country,
       year,
       value AS GDP
FROM gdp_3
ORDER BY country, year;

-- Q7. How has population growth affected total emissions in each country?
SELECT p.countries AS country,
       p.year,
       p.value AS population,
       SUM(e.emission) AS total_emission
FROM population_3 p
JOIN emission_3 e
ON p.countries = e.country
AND p.year = e.year
GROUP BY p.countries, p.year, p.value
ORDER BY p.countries, p.year;

-- Q8. Has energy consumption increased or decreased over the years for major economies?
SELECT country,
       year,
       SUM(consumption) AS total_consumption
FROM consum_3
WHERE country IN ('China','United States','India','Japan','Germany')
GROUP BY country, year
ORDER BY country, year;

-- Q9. What is the average yearly change in emissions per capita for each country?
SELECT country,
       AVG(`per capita emission`) AS avg_yearly_change
FROM emission_3
GROUP BY country
ORDER BY avg_yearly_change DESC;

-- Ratio & Per Capita Analysis
-- Q10. What is the emission-to-GDP ratio for each country by year?
SELECT e.country,
       e.year,
       (SUM(e.emission) / g.value) AS emission_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g
ON e.country = g.country
AND e.year = g.year
GROUP BY e.country, e.year, g.value
ORDER BY e.country, e.year;

-- Q11. Energy consumption per capita over the last decade
SELECT c.country,
       c.year,
       (SUM(c.consumption) / p.value) AS consumption_per_capita
FROM consum_3 c
JOIN population_3 p
ON c.country = p.countries
AND c.year = p.year
GROUP BY c.country, c.year, p.value
ORDER BY c.country, c.year;

-- Q12. Energy production per capita across countries
SELECT pr.country,
       pr.year,
       (SUM(pr.production) / p.value) AS production_per_capita
FROM production_3 pr
JOIN population_3 p
ON pr.country = p.countries
AND pr.year = p.year
GROUP BY pr.country, pr.year, p.value
ORDER BY pr.country, pr.year ;

-- Q13. Highest energy consumption relative to GDP
SELECT c.country,
       c.year,
       (SUM(c.consumption) / g.value) AS consumption_gdp_ratio
FROM consum_3 c
JOIN gdp_3 g
ON c.country = g.country
AND c.year = g.year
GROUP BY c.country, c.year, g.value
ORDER BY consumption_gdp_ratio DESC;

-- Q14. Correlation between GDP growth and energy production growth
SELECT g.country,
       g.year,
       g.value AS GDP,
       SUM(p.production) AS production
FROM gdp_3 g
JOIN production_3 p
ON g.country = p.country
AND g.year = p.year
GROUP BY g.country, g.year, g.value
ORDER BY g.country, g.year;

-- Global Comparisons
-- Q15. Top 10 countries by population and their emissions
SELECT p.countries AS country,
       p.value AS population,
       SUM(e.emission) AS total_emission
FROM population_3 p
JOIN emission_3 e
ON p.countries = e.country
AND p.year = e.year
GROUP BY p.countries, p.value
ORDER BY population DESC
LIMIT 10;

-- Q16. Countries reducing per capita emissions
SELECT country,
       MIN('per capita emission') AS lowest_emission
FROM emission_3
GROUP BY country
ORDER BY lowest_emission ASC;

-- Q17. Global share (%) of emissions by country
SELECT country,
       (SUM(emission) * 100 /
        (SELECT SUM(emission) FROM emission_3)) AS emission_share_percent
FROM emission_3
GROUP BY country
ORDER BY emission_share_percent DESC;

-- Q18. Global average GDP, emission, population by year
SELECT e.year,
       AVG(g.value) AS avg_gdp,
       AVG(e.emission) AS avg_emission,
       AVG(p.value) AS avg_population
FROM emission_3 e
JOIN gdp_3 g
ON e.country = g.country AND e.year = g.year
JOIN population_3 p
ON e.country = p.countries AND e.year = p.year
GROUP BY e.year
ORDER BY e.year;