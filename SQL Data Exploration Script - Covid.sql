select *
from PortfolioProject..CovidDeaths
where continent is NOT NULL
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is NOT NULL
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the odds of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%malaysia%'
order by 1,2 desc


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%malaysia%'
where continent is NOT NULL
order by 1,2 desc


-- Looking at Countries with Highest Infection Rate compared to Population
select Location, Population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%malaysia%'
where continent is NOT NULL
group by Location, Population
order by 4 desc


-- Showing Countries with Highest Death Count per Population
select Location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
--where location like '%malaysia%'
where continent is NOT NULL
group by Location
order by 2 desc

select Location, Population, MAX(cast(total_deaths as int)) as total_death_count, MAX(((cast(total_deaths as int))/population))*100 as death_per_population
from PortfolioProject..CovidDeaths
--where location like '%malaysia%'
where continent is NOT NULL
group by Location, Population
order by 4 desc


-- Break things down by Continent
select continent, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
--where location like '%malaysia%'
where continent is NOT NULL
group by continent
order by 2 desc


-- Debugging the location/continent mix up and inaccurate count
select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
--where location like '%malaysia%'
where continent is NULL
group by location
order by 2 desc

select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
--where location like '%malaysia%'
where continent is NULL AND location NOT LIKE '%income%'
group by location
order by 2 desc


-- GLOBAL NUMBERS
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is NOT NULL
group by date
order by 1 desc

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is NOT NULL
--group by date
order by 1


-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is NOT NULL
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
SUM(cast(vac.new_people_vaccinated_smoothed as bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is NOT NULL

-- CTE
WITH PopVSVac AS (
select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
SUM(CONVERT(bigint, vac.new_people_vaccinated_smoothed)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is NOT NULL
)
select *, (rolling_people_vaccinated/population)*100 as vacc
from PopVSVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_people_vaccinated_smoothed numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
SUM(CONVERT(bigint, vac.new_people_vaccinated_smoothed)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is NOT NULL

select *, (rolling_people_vaccinated/population)*100 as vacc_percentage
from #PercentPopulationVaccinated 
order by 2,3


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
SUM(CONVERT(bigint, vac.new_people_vaccinated_smoothed)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is NOT NULL

select *
from PercentPopulationVaccinated
