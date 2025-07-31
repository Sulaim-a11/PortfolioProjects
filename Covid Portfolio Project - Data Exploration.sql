--Data Exploration for Covid Deaths--

SELECT *
FROM CovidDeaths
Where continent is not NULL;

--PRAGMA table_info(CovidDeaths);

-- Select the data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths 
Where continent is not NULL
ORDER BY location, DATE(date) ASC;


-- Looking at Total Cases vs Total Deaths
-- Shows the percentage of death compared to the affected cases

SELECT location, date, total_cases, total_deaths, ROUND (100.0 * total_deaths/total_cases, 2)  AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%' -- example: states
and continent is not NULL
ORDER BY location, DATE(date);


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date,population, total_cases, CAST( total_cases as REAL) / population * 100  AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY location, DATE(date) ASC;



--Showing which country has the highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX(CAST(total_cases AS REAL) / population) * 100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC;

-- debugging 

--SELECT DISTINCT location from CovidDeaths ORDER by location; 

--Showing coutries with highest death count as per their population

SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM CovidDeaths
Where continent is not NULL
	and location not in ('World', 'Europe', 'Asia', 'Africa', 'North America', 'South America', 'Oceania', 'European Union')
GROUP BY location 
ORDER BY TotalDeathCount DESC;

-- debugging 

--SELECT DISTINCT continent from CovidDeaths ORDER by continent; 


--Showing continents with highest death count as per population 

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL 
AND TRIM(continent) != ''
group by continent
order by TotalDeathCount desc;

/*
-- GLOBAL NUMBERS 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths,  SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
order by 1, 2;
*/

--PRAGMA table_info(CovidVaccinations);


--Data Exploration for Covid Vaccinations--

--To eliminate the c1,c2,c3, etc column names in SQLite

SELECT * 
FROM CovidVaccinations
LIMIT 20;


-- Looking at total population vs vaccinations

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS integer)) OVER (PARTITION by deaths.location ORDER by deaths.location, DATE(deaths.date)) as RollingPeopleVaccinated
FROM CovidDeaths AS deaths
JOIN CovidVaccinationsModified AS vac 
  on deaths.location = vac.location
  and deaths.date = vac.date
where deaths.continent is not NULL
AND deaths.continent != ''
order by 2, DATE(3);


-- Using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS integer)) OVER (PARTITION by deaths.location ORDER by deaths.location, DATE(deaths.date)) as RollingPeopleVaccinated
FROM CovidDeaths AS deaths
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
FROM CovidDeaths AS deaths
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
FROM CovidDeaths AS deaths
JOIN CovidVaccinationsModified AS vac 
  on deaths.location = vac.location
  and deaths.date = vac.date
where deaths.continent is not NULL
AND deaths.continent != '' ;


SELECT *
FROM PercentPopulationVaccinated











