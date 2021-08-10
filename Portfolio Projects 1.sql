/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From PortfolioProjects..CovidDeaths
where continent is not null
order by 3, 4

-- Select data that will be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
order by 1, 2

-- Shows the likelyhood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProjects..CovidDeaths
Where location = 'Poland'
order by 1, 2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, population, total_cases, (total_cases/population)*100 as infection_percentage
From PortfolioProjects..CovidDeaths
Where location = 'Poland'
order by 1, 2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infection_rate
From PortfolioProjects..CovidDeaths
-- Where location = 'Poland'
group by location, population
order by infection_rate DESC

-- Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProjects..CovidDeaths
where continent is not null
group by location
order by total_death_count DESC


-- BREAKING THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProjects..CovidDeaths
where continent is not null
group by continent
order by total_death_count DESC

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from	PortfolioProjects..CovidDeaths
where continent is not null
group by date
order by 1, 2

-- Overall

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from	PortfolioProjects..CovidDeaths
where continent is not null
--group by date
order by 1, 2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

With popvsvac (Continent, Location, Date, Population, New_vaccinations,  total_people_vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_people_vaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, total_people_vaccinated/Population* 100
From popvsvac




-- Creating view to store data for later visualization

CREATE VIEW popvsvac AS
With popvsvac (Continent, Location, Date, Population, New_vaccinations,  total_people_vaccinated)
as 
(	
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_people_vaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, total_people_vaccinated/Population* 100 as vaccination_rate
From popvsvac


select *
from popvsvac