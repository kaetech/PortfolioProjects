SELECT * 
FROM [Portfolio Projects]..CovidDeaths
Where continent is not null
ORDER BY 3,4

--Select data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Projects]..CovidDeaths
ORDER BY 1,2 

-- Looking at Total Cases vs Total Deaths 
-- Shows the likelihood of dying if contracted covid in your country 
SELECT Location, date, total_cases, total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM [Portfolio Projects]..CovidDeaths
Where location like '%states%'
ORDER BY 1,2 

--Total cases vs population 
-- Percent of populaton with covid
SELECT Location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as CasePercentage
FROM [Portfolio Projects]..CovidDeaths
Where location like '%states%'
ORDER BY 1,2 

-- Countries with highest infectiion rate by population 
SELECT Location, population, MAX(total_cases) AS MaxInfectionRate, Max((cast(total_cases as float))/cast(population as float))*100 as CasePercentage
FROM [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
GROUP BY Location, population
ORDER BY CasePercentage DESC

--Death Rate by country population
SELECT Location, population, MAX(cast (total_deaths as int)) AS TotalDeaths, Max((cast(total_deaths as float))/cast(population as float))*100 as NationalDeathRate
FROM [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
Where continent is not null 
GROUP BY Location, population
ORDER BY NationalDeathRate DESC

--By Continent
--data is misleading, only accounts for country with highest death in continent not the summation of all country death counts 
SELECT continent, MAX(cast (total_deaths as int)) AS TotalDeaths
FROM [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeaths DESC

--testing for more accurate numbers 
SELECT location, MAX(cast (total_deaths as int)) AS TotalDeaths
FROM [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
Where continent is null
GROUP BY location
ORDER BY TotalDeaths DESC

-- Global Numbers

SELECT date, Sum(new_cases)TotalNewCases, Sum(Cast(new_deaths as float)) TotalNewDeaths, Sum(Cast(new_deaths as float))/Sum(new_cases)*100 as GlobalDeathPercentage
FROM [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
Where continent is not null
GROUP BY date
ORDER BY 1,2 

-- Total population vs vaccinations 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations as float)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) RollingVaxCount
FROM [Portfolio Projects]..CovidDeaths deaths
JOIN [Portfolio Projects]..CovidVaccinations vax
	ON deaths.location = vax.location
	and deaths.date = vax.date
	WHERE deaths.continent is not null
ORDER BY 2,3

-- Use CTE
WITH PopvsVax (continent, location, date, population, new_vaccinations, RollingVaxCount)
as 
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations as float)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) RollingVaxCount
FROM [Portfolio Projects]..CovidDeaths deaths
JOIN [Portfolio Projects]..CovidVaccinations vax
	ON deaths.location = vax.location
	and deaths.date = vax.date
	WHERE deaths.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingVaxCount/population)*100 VaxxedPop
FROM PopvsVax
ORDER BY 2,3

--Use Temp table
DROP TABLE IF EXISTS #PercentPopVaxxed
Create table #PercentPopVaxxed
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaxCount numeric
)
Insert into #PercentPopVaxxed
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations as float)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) RollingVaxCount
FROM [Portfolio Projects]..CovidDeaths deaths
JOIN [Portfolio Projects]..CovidVaccinations vax
	ON deaths.location = vax.location
	and deaths.date = vax.date
	WHERE deaths.continent is not null
SELECT *, (RollingVaxCount/population)*100 VaxxedPop
FROM #PercentPopVaxxed
ORDER BY 2,3

-- Creating View for visualizations
CREATE VIEW PercentPopVaxxed AS 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations as float)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.date) RollingVaxCount
FROM [Portfolio Projects]..CovidDeaths deaths
JOIN [Portfolio Projects]..CovidVaccinations vax
	ON deaths.location = vax.location
	and deaths.date = vax.date
	WHERE deaths.continent is not null
	
