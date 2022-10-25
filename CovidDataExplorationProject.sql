--SELECTING DATA  WE ARE USING FOR QUERIES

--1.TOTAL CASES VS TOTAL DEATHS PER COUNTRY
--Percentage of death of people infected by covid

SELECT location,date,population,total_cases,total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--2.TOTAL CASES V/S POPULATION
--percentage of population got Covid

SELECT location,date,population,total_cases, (total_cases/population)*100 InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'India'
ORDER BY 1,2

--3.Highest Infection Rate

SELECT location,population,MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 desc

--4.Countries with Highest Death Count per Population

SELECT location,MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY 2 desc

--5.Continents with Highest Death Count per Population

SELECT location,MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL 
GROUP BY location
ORDER BY 2 desc

--6. Global Numbers

Select --date,
SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) DeathPerceentage
From PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2



--7.Looking at vaccination data
SELECT vac.location,vac.date,total_vaccinations,new_vaccinations,dea.population
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL 
ORDER BY 1,2

--8. Total population VS/ new vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


--USE CTE 

WITH popVSvac (Continent, date,location,population,New_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL AND dea.location like 'India'
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 PercentageOfPeopleVaccinated
FROM popVSvac

--9.Creating view for future visualisation

CREATE VIEW PercentageOfPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentageOfPeopleVaccinated





