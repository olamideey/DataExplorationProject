
select*
from CovidPortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select*
--from CovidPortfolioProject..CovidVaccinations$
--order by 3,4

--Selecting the data that will be used

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidPortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Exploring the Total cases versus Total Deaths

--The likelihood of dying if you contract covid-19 in your country


Select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases), 0)) * 100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths$
where continent is not null
and location like '%Nigeria%'
order by 1,2

--Exploring the Total Cases versus Population

--The percentage of population got covid-19

Select Location, date, Population, total_cases, (total_cases/population) * 100 as PercentPopulationCases
From CovidPortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Exploring the countries with highest infection rate to the population

--3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--4.

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
Group by Location, Population, date
order by PercentPopulationInfected desc

--The countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotaldeathCount
from CovidPortfolioProject..CovidDeaths$
--where location like '%Africa%'
where continent is not null
Group by Location
order by TotaldeathCount desc

--Exploring the data by continent

--The continent with highest death per population

--2.

Select continent, MAX(cast(total_deaths as int)) as TotaldeathCount
from CovidPortfolioProject..CovidDeaths$
--where location like '%Africa%'
where continent is  not null
and location not in ('World', 'European Union', 'International')
Group by continent
order by TotaldeathCount desc




--Exploring Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF (SUM(new_cases), 0)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2

--1.

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF (SUM(new_cases), 0)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths$
where continent is not null
--Group by date
order by 1,2


--The Total Population versus Vaccinations (rolling count)

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidPortfolioProject..CovidDeaths$ dea
join CovidPortfolioProject..CovidVaccinations$  vac
	On dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
--and dea.location like '%Nigeria%'
order by 2,3

--The Total Population versus Vaccinations (rolling count) in your country

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidPortfolioProject..CovidDeaths$ dea
join CovidPortfolioProject..CovidVaccinations$  vac
	On dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
and dea.location like '%Nigeria%'
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
from CovidPortfolioProject..CovidDeaths$ dea
join CovidPortfolioProject..CovidVaccinations$  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%Nigeria%'
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentRollingvac
from PopvsVac




--TEMP TABLE

Drop Table if exists #PercentagePoplationVaccinated
Create Table #PercentagePoplationVaccinated
(
Coontinent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentagePoplationVaccinated
select dea.continent, dea.location, dea.date, dea.Population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
from CovidPortfolioProject..CovidDeaths$ dea
join CovidPortfolioProject..CovidVaccinations$  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%Nigeria%'
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as PercentRollingvac
from #PercentagePoplationVaccinated



--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidPortfolioProject..CovidDeaths$ dea
join CovidPortfolioProject..CovidVaccinations$  vac
	On dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
--and dea.location like '%Nigeria%'
--order by 2,3

select*
from PercentPopulationVaccinated

Create View PercentPopulationVaccinatedNigeria as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidPortfolioProject..CovidDeaths$ dea
join CovidPortfolioProject..CovidVaccinations$  vac
	On dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
and dea.location like '%Nigeria%'
--order by 2,3

