/* Queries for Tableau */

--1
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is NOT NULL


--2
select location, SUM(cast(new_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
--where location like '%malaysia%'
where continent is NULL AND location NOT IN ('World', 'European Union', 'International')
AND location NOT LIKE '%income%'
group by location
order by 2 desc


--3
select Location, Population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%malaysia%'
where continent is NOT NULL
group by Location, Population
order by 4 desc


--4
select Location, Population, date, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%malaysia%'
where continent is NOT NULL
group by Location, Population, date
order by 5 desc
