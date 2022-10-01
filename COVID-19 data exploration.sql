4--creating my tables--
--creating covid_deaths--

CREATE TABLE covid_deaths(
iso_code VARCHAR,
continent VARCHAR,
location_ VARCHAR,
date_ DATE,
population NUMERIC,
total_cases NUMERIC,
new_cases NUMERIC,
new_cases_smoothed DECIMAL,
total_deaths NUMERIC,
new_deaths NUMERIC,
new_deaths_smoothed DECIMAL,
total_cases_per_million DECIMAL,
new_cases_per_million DECIMAL,
new_cases_smoothed_per_million DECIMAL,
total_deaths_per_million DECIMAL,
new_deaths_per_million DECIMAL,
new_deaths_smoothed_per_million DECIMAL,
reproduction_rate DECIMAL,
icu_patients NUMERIC,
icu_patients_per_million DECIMAL,
hosp_patients NUMERIC,
hosp_patients_per_million DECIMAL,
weekly_icu_admissions DECIMAL,
weekly_icu_admissions_per_million DECIMAL,
weekly_hosp_admissions DECIMAL,
weekly_hosp_admissions_per_million DECIMAL
);

--creating covid vaccinations--

CREATE TABLE covid_vaccinations(
iso_code VARCHAR,
continent VARCHAR,
location_ VARCHAR,
date_ DATE,
new_tests NUMERIC,
total_tests NUMERIC,
total_tests_per_thousand DECIMAL,
new_tests_per_thousand DECIMAL,
new_tests_smoothed DECIMAL,
new_tests_smoothed_per_thousand DECIMAL,
positive_rate DECIMAL,
tests_per_case DECIMAL,
tests_units VARCHAR,
total_vaccinations NUMERIC,
people_vaccinated NUMERIC,
people_fully_vaccinated NUMERIC,
total_boosters NUMERIC,	
new_vaccinations NUMERIC,
new_vaccinations_smoothed DECIMAL,
total_vaccinations_per_hundred DECIMAL,
people_vaccinated_per_hundred DECIMAL,
people_fully_vaccinated_per_hundred DECIMAL,
total_boosters_per_hundred DECIMAL,
new_vaccinations_smoothed_per_million DECIMAL,
new_people_vaccinated_smoothed NUMERIC,
new_people_vaccinated_smoothed_per_hundred DECIMAL,
stringency_index DECIMAL,
population_density DECIMAL,
median_age DECIMAL,
aged_65_older DECIMAL,
aged_70_older DECIMAL,
gdp_per_capita DECIMAL,
extreme_poverty DECIMAL,
cardiovasc_death_rate DECIMAL,
diabetes_prevalence DECIMAL,
female_smokers DECIMAL,
male_smokers DECIMAL,
handwashing_facilities DECIMAL,
hospital_beds_per_thousand DECIMAL,
life_expectancy DECIMAL,
human_development_index DECIMAL
);


--checking my tables--

SELECT * 
FROM covid_deaths
WHERE continent IS NOT NULL;

SELECT * FROM covid_vaccinations
WHERE continent IS NOT NULL;

--selecting data to start with--

SELECT location_, date_, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--checking out the total cases vs total deaths--
--this shows the likelihood of dying from covid--

SELECT location_, date_, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2 DESC;

--checking out the total cases vs total deaths in some locations--
--likelihood of dying if infected with covid in the united states--

SELECT location_, date_, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
WHERE location_ LIKE '%States%'
AND continent IS NOT NULL
ORDER BY 1,2 DESC;

--likelihood of dying if infected with covid in germany--

SELECT location_, date_, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
WHERE location_ ='Germany'
AND continent IS NOT NULL
ORDER BY 1,2 DESC;

--checking out the total cases vs population--
--shows what percentage of the US population got covid--

SELECT location_, date_,population, total_cases,  (total_cases/population)*100 as percentpopulationinfected
FROM covid_deaths
WHERE location_ LIKE '%States%'
ORDER BY 1,2;

--shows what percentage of germany's population got covid--

SELECT location_, date_,population, total_cases,  (total_cases/population)*100 as percentpopulationinfected
FROM covid_deaths
WHERE location_ = 'Germany'
ORDER BY 1,2;

--countries with highest infection rate compared to population--

SELECT location_, population, MAX(total_cases)  AS highestinfection_count, max((total_cases/population))*100 as percentpopulationinfected
FROM covid_deaths
WHERE total_cases IS NOT NULL
AND population IS NOT NULL
AND continent IS NOT NULL
GROUP BY 1,2
ORDER BY percentpopulationinfected DESC;

--showing countries with the highest death count per population--

SELECT location_, population, MAX(total_deaths)  AS totaldeath_count
FROM covid_deaths
WHERE continent IS NOT NULL
AND total_deaths IS NOT NULL
GROUP BY 1,2
ORDER BY totaldeath_count DESC;

--LET's CHECK WHAT'S HAPPENING BY CONTINENT--

SELECT continent, MAX(total_deaths)  AS totaldeath_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY totaldeath_count DESC;

--showing continents with the highest death count--

SELECT continent, population, MAX(total_deaths)  AS totaldeath_count
FROM covid_deaths
WHERE continent IS NOT NULL
AND total_deaths IS NOT NULL
GROUP BY 1,2
ORDER BY totaldeath_count DESC;

--GLOBAL NUMBERS--
--total deaths and death percentage per day globally--

SELECT date_,SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,SUM(new_deaths)/SUM(new_cases)*100 AS Deathpercentage
FROM covid_deaths
WHERE CONTINENT IS NOT NULL
GROUP BY 1
ORDER BY 1,2;

--total deaths and death percentage globally --

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,SUM(new_deaths)/SUM(new_cases)*100 AS Deathpercentage
FROM covid_deaths
WHERE CONTINENT IS NOT NULL
ORDER BY 1,2;

--joining the two tables--

SELECT *
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location_ = vac.location_
AND dea.date_ = vac.date_;

--lets's check out the earlierst countries to be vaccinated--

SELECT dea.continent, dea.location_, dea.date_, dea.population, vac.new_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location_ = vac.location_
AND dea.date_ = vac.date_
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL
ORDER BY 3;

--countries with the highest daily vaccinations --

SELECT location_, date_, SUM(new_vaccinations) AS totalnewvaccinations
FROM covid_vaccinations
WHERE continent IS NOT NULL
AND new_vaccinations IS NOT NULL
GROUP BY 1,2
ORDER BY 3 DESC;

--bringing in the population column from covid_vaccinations table--

SELECT dea.location_, dea.date_, dea.population, SUM(vac.new_vaccinations) AS daily_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location_ = vac.location_
AND dea.date_ = vac.date_
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL
GROUP BY 1,2,3
ORDER BY 4 DESC;

--countries with the highest total vaccinations--

SELECT dea.location_, SUM(vac.new_vaccinations) AS total_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location_ = vac.location_
AND dea.date_ = vac.date_
WHERE dea.continent IS NOT NULL
AND new_vaccinations IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

--countries with the highest totalboosters--
SELECT dea.location_, SUM(vac.total_boosters) AS total_boosters
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location_ = vac.location_
AND dea.date_ = vac.date_
WHERE dea.continent IS NOT NULL
AND vac.total_boosters IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

--total population vs vaccination--
--shows the percentage of the population that has received at least one covid vaccine--

SELECT dea.continent, dea.location_, dea.date_, dea.population, 
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location_ ORDER BY dea.location_
							   ,dea.date_) AS rollingpeoplevaccinated
							-- ,(rollingpeoplevaccinated)/population * 100
							  
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location_ = vac.location_
AND dea.date_ = vac.date_
WHERE dea.continent IS NOT NULL
AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3;

--
--using CTE to perform calculation on partition by in previous query--

with popvsvac(continent,location_,date_,population,rollingpeoplevaccinated,new_vaccinations)
AS
(
SELECT dea.continent, dea.location_, dea.date_, dea.population, 
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location_ ORDER BY dea.location_
							   ,dea.date_) AS rollingpeoplevaccinated
							 -- ,(rollingpeoplevaccinated)/population * 100
							  
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location_ = vac.location_
AND dea.date_ = vac.date_
WHERE dea.continent IS NOT NULL
AND vac.new_vaccinations IS NOT NULL
--ORDER BY 2,3;
)
SELECT * , ROUND((rollingpeoplevaccinated/population),4)*100 AS percentagevaccinated
FROM popvsvac;


--using TEMP TABLE to perform calculation on partition by in previous query--
--DROP TABLE IF EXISTS percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(continent VARCHAR,
 location_ VARCHAR,
 date_ DATE,
 population NUMERIC,
 new_vaccinations NUMERIC,
 rollingpeoplevaccinated NUMERIC
)

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location_, dea.date_, dea.population, 
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location_ ORDER BY dea.location_
							   ,dea.date_) AS rollingpeoplevaccinated
							 -- ,(rollingpeoplevaccinated)/population * 100
							  
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location_ = vac.location_
AND dea.date_ = vac.date_
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * , (rollingpeoplevaccinated/population)*100 AS percentagevaccinated
FROM percentpopulationvaccinated;

-- population vs total boosted--

with popvsboosted(continent,location_,date_,population,rollingpeopleboosted,total_boosters)
AS
(
SELECT dea.continent, dea.location_, dea.date_, dea.population, 
vac.total_boosters,
SUM(vac.total_boosters) OVER (PARTITION BY dea.location_ ORDER BY dea.location_
							   ,dea.date_) AS rollingpeopleboosted
							 -- ,(rollingpeopleboosted)/population * 100
							  
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location_ = vac.location_
AND dea.date_ = vac.date_
WHERE dea.continent IS NOT NULL
AND vac.total_boosters IS NOT NULL
--ORDER BY 2,3;
)
SELECT * , ROUND((rollingpeopleboosted/population),4)*100 AS percentageboosted
FROM popvsboosted;

--creating view for later visualizations--

CREATE VIEW percentpopulationvaccinated AS 
SELECT dea.continent, dea.location_, dea.date_, dea.population, 
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location_ ORDER BY dea.location_
							   ,dea.date_) AS rollingpeoplevaccinated
							 -- ,(rollingpeoplevaccinated)/population * 100
							  
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location_ = vac.location_
AND dea.date_ = vac.date_
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
;
			
SELECT *
FROM percentpopulationvaccinated;
