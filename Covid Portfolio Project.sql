--Data Exploration for Covid Deaths--

--To eliminate the c1,c2,c3, etc column names in SQLite

CREATE TABLE CovidDeathsModified (
  iso_code TEXT,
  continent TEXT,
  location TEXT,
  date INTEGER,
  population INTEGER,
  total_cases INTEGER,
  new_cases INTEGER,
  new_cases_smoothed INTEGER,
  total_deaths INTEGER,
  new_deaths INTEGER,
  new_deaths_smoothed FLOAT,
  total_cases_per_million FLOAT,
  new_cases_per_million FLOAT,
  new_cases_smoothed_per_million FLOAT,
  total_deaths_per_million FLOAT,
  new_deaths_per_million FLOAT,
  new_deaths_smoothed_per_million FLOAT,
  reproduction_rate FLOAT,
  icu_patients FLOAT,
  icu_patients_per_million FLOAT,
  hosp_patients FLOAT,
  hosp_patients_per_million FLOAT,
  weekly_icu_admissions FLOAT,
  weekly_icu_admissions_per_million FLOAT,
  weekly_hosp_admissions FLOAT,
  weekly_hosp_admissions_per_million FLOAT
);
  

INSERT INTO CovidDeathsModified (iso_code, continent, location, date, population, total_cases, new_cases,	new_cases_smoothed,	total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million,	new_cases_per_million, new_cases_smoothed_per_million, total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million, reproduction_rate, icu_patients, icu_patients_per_million, hosp_patients,	hosp_patients_per_million,	weekly_icu_admissions, weekly_icu_admissions_per_million, weekly_hosp_admissions, weekly_hosp_admissions_per_million)
SELECT c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26
FROM CovidDeaths
WHERE rowid > 1;


DROP TABLE CovidDeaths;


SELECT date, typeof(date)
FROM CovidDeathsModified
LIMIT 5;


--Modified Table

SELECT *
FROM CovidDeathsModified
Where continent is not NULL;

--PRAGMA table_info(CovidDeathsModified);

-- Select the data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeathsModified 
Where continent is not NULL
ORDER BY location, DATE(date) ASC;


-- Looking at Total Cases vs Total Deaths
-- Shows the percentage of death compared to the affected cases

SELECT location, date, total_cases, total_deaths, ROUND (100.0 * total_deaths/total_cases, 2)  AS DeathPercentage
FROM CovidDeathsModified
WHERE location like '%states%' -- example: states
and continent is not NULL
ORDER BY location, DATE(date);


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date,population, total_cases, CAST( total_cases as REAL) / population * 100  AS PercentPopulationInfected
FROM CovidDeathsModified
--WHERE location like '%states%'
ORDER BY location, DATE(date) ASC;



--Showing which country has the highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX(CAST(total_cases AS REAL) / population) * 100 as PercentPopulationInfected
FROM CovidDeathsModified
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC;

-- debugging 

--SELECT DISTINCT location from CovidDeathsModified ORDER by location; 

--Showing coutries with highest death count as per their population

SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM CovidDeathsModified
Where continent is not NULL
	and location not in ('World', 'Europe', 'Asia', 'Africa', 'North America', 'South America', 'Oceania', 'European Union')
GROUP BY location 
ORDER BY TotalDeathCount DESC;

-- debugging 

--SELECT DISTINCT continent from CovidDeathsModified ORDER by continent; 


--Showing continents with highest death count as per population 

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeathsModified
WHERE continent is not NULL 
AND TRIM(continent) != ''
group by continent
order by TotalDeathCount desc;

/*
-- GLOBAL NUMBERS 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths,  SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeathsModified
WHERE continent is not NULL
order by 1, 2;
*/

--PRAGMA table_info(CovidVaccinations);


--Data Exploration for Covid Vaccinations--

--To eliminate the c1,c2,c3, etc column names in SQLite

CREATE TABLE CovidVaccinationsModified (
  iso_code TEXT,
  continent TEXT,
  location TEXT,
  date INTEGER,
  new_tests INTEGER,
  total_tests INTEGER,
  total_tests_per_thousand FLOAT,
  new_tests_per_thousand FLOAT,
  new_tests_smoothed FLOAT,
  new_tests_smoothed_per_thousand FLOAT,
  positive_rate FLOAT,
  tests_per_case FLOAT,
  tests_units FLOAT,
  total_vaccinations FLOAT,
  people_vaccinated FLOAT,
  people_fully_vaccinated FLOAT,
  new_vaccinations FLOAT,
  new_vaccinations_smoothed FLOAT,
  total_vaccinations_per_hundred FLOAT,
  people_vaccinated_per_hundred FLOAT,
  people_fully_vaccinated_per_hundred FLOAT,
  new_vaccinations_smoothed_per_million FLOAT,
  stringency_index FLOAT,
  population FLOAT,
  population_density FLOAT,
  median_age FLOAT,
  aged_65_older FLOAT,
  aged_70_older FLOAT,
  gdp_per_capita FLOAT,
  extreme_poverty FLOAT,
  cardiovasc_death_rate FLOAT, 
  diabetes_prevalence FLOAT, 
  female_smokers FLOAT, 
  male_smokers FLOAT, 
  handwashing_facilities FLOAT, 
  hospital_beds_per_thousand FLOAT, 
  life_expectancy FLOAT, 
  human_development_index FLOAT
  
);


INSERT INTO CovidVaccinationsModified (iso_code, continent, location, date, new_tests,total_tests,total_tests_per_thousand,new_tests_per_thousand,new_tests_smoothed,new_tests_smoothed_per_thousand,positive_rate,tests_per_case,tests_units,total_vaccinations,people_vaccinated,people_fully_vaccinated,new_vaccinations,new_vaccinations_smoothed,total_vaccinations_per_hundred,people_vaccinated_per_hundred,people_fully_vaccinated_per_hundred,new_vaccinations_smoothed_per_million,stringency_index,population,population_density,median_age,aged_65_older,aged_70_older,gdp_per_capita,extreme_poverty,cardiovasc_death_rate,diabetes_prevalence,female_smokers,male_smokers,handwashing_facilities,hospital_beds_per_thousand,life_expectancy, human_development_index)
SELECT c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22,c23,c24,c25,c26,c27,c28,c29,c30,c31,c32,c33,c34,c35,c36,c37,c38
FROM CovidVaccinations
WHERE rowid > 1;


DROP TABLE CovidVaccinations;


--Modified Table

SELECT * 
FROM CovidVaccinationsModified
LIMIT 20;


-- Looking at total population vs vaccinations

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS integer)) OVER (PARTITION by deaths.location ORDER by deaths.location, DATE(deaths.date)) as RollingPeopleVaccinated
FROM CovidDeathsModified AS deaths
JOIN CovidVaccinationsModified AS vac 
  on deaths.location = vac.location
  and deaths.date = vac.date
where deaths.continent is not NULL
AND deaths.continent != ''
order by 2, DATE(3);


-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS integer)) OVER (PARTITION by deaths.location ORDER by deaths.location, DATE(deaths.date)) as RollingPeopleVaccinated
FROM CovidDeathsModified AS deaths
JOIN CovidVaccinationsModified AS vac 
  on deaths.location = vac.location
  and deaths.date = vac.date
where deaths.continent is not NULL
AND deaths.continent != ''
--order by 2, DATE(3)
)
SELECT *, ROUND(100 * RollingPeopleVaccinated/population, 2)
FROM PopvsVac;


-- TEMP TABLE 

--drop table IF EXISTS PercentPopulationVaccinated;

CREATE TEMP TABLE PercentPopulationVaccinated (
  continent TEXT,
  location TEXT,
  date datetime,
  population REAL,
  new_vaccinations REAL,
  RollingPeopleVaccinated REAL
);

INSERT INTO PercentPopulationVaccinated (continent, location,date, population,new_vaccinations, RollingPeopleVaccinated)
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS integer)) OVER (PARTITION by deaths.location ORDER by deaths.location, DATE(deaths.date)) as RollingPeopleVaccinated
FROM CovidDeathsModified AS deaths
JOIN CovidVaccinationsModified AS vac 
  on deaths.location = vac.location
  and deaths.date = vac.date
where deaths.continent is not NULL
AND deaths.continent != '' ;
--order by 2, DATE(3)

SELECT *, ROUND(100 * RollingPeopleVaccinated/population, 2)
FROM PercentPopulationVaccinated;
 



-- Creating view to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS integer)) OVER (PARTITION by deaths.location ORDER by deaths.location, DATE(deaths.date)) as RollingPeopleVaccinated
FROM CovidDeathsModified AS deaths
JOIN CovidVaccinationsModified AS vac 
  on deaths.location = vac.location
  and deaths.date = vac.date
where deaths.continent is not NULL
AND deaths.continent != '' ;


SELECT *
FROM PercentPopulationVaccinated











