/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
(Completed my esther - resource Alextheanalyst)
*/

SELECT *
FROM PortfolioPoject..CovidDeaths$
WHERE Continent is NOT null
ORDER BY 3,4 

--SELECT *
--FROM PortfolioPoject..CovidVaccine$
--ORDER BY 3,4 

--SELECT data that we are going to be using 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioPoject..CovidDeaths$


-- Looking at total cases vs Total deaths - (a calauation = how many cases in a country vs how many deaths they have for the cases)
-- Here we have divided total deaths by total cases and times by 100 to = a percentage
--Also shoes the likelyhood of dying if ou contract covid in your conutry
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM PortfolioPoject..CovidDeaths$
WHERE Location like '%united kingdom%'

-- Looking at total cases vs Population 
-- shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage 
FROM PortfolioPoject..CovidDeaths$
WHERE Location like '%United Kingdom%'


-- countries with the highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM PortfolioPoject..CovidDeaths$
-- WHERE Location like '%United Kingdom%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing countries with the highest death count per population
-- changing the varchar to a int (this caused an issue with the inaccurcy)
SELECT Location, MAX(cast(Total_Deaths as int)) as TotaDeathCount
FROM PortfolioPoject..CovidDeaths$
-- WHERE Location like '%United Kingdom%'
WHERE continent is not null
GROUP BY location
ORDER BY TotaDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioPoject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioPoject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioPoject..CovidDeaths$
-- WHERE Location like '%United Kingdom%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Covid Vaccine table query's
--Selecting all 
SELECT *
FROM PortfolioPoject..CovidVaccine$

--Joining the two tables together  
SELECT *
FROM PortfolioPoject..CovidVaccine$ dea
JOIN PortfolioPoject..CovidDeaths$ vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioPoject..CovidDeaths$ dea
Join PortfolioPoject..CovidVaccine$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


-- Using a CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioPoject..CovidDeaths$ dea
Join PortfolioPoject..CovidVaccine$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
from PopvsVac

--TEMP TABLE
Create table #percentPopulationVaccinated
(
contintent nvarchar(255),
Location varchar(225),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #percentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioPoject..CovidDeaths$ dea
Join PortfolioPoject..CovidVaccine$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


SELECT *, (RollingPeopleVaccinated/Population) * 100
from #percentPopulationVaccinated


--Creating a view for later visualations!!!!! in tableau

CREATE view percentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioPoject..CovidDeaths$ dea
Join PortfolioPoject..CovidVaccine$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



--can use to select for when viewing  in tableau
-- View 1 - selectig all
SELECT *
FROM percentPopulationVaccinated

