/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * from master..CovidDeaths
where continent is not null
order by 3,4


Select * from master..CovidVaccinations
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
from master..CovidDeaths
where continent is not null
order by 1, 2


--Looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from master..CovidDeaths
where location like '%india%'
and continent is not null
order by 1, 2

--Looking at total cases vs population

Select Location, date, population, total_cases, (total_cases/population)*100 as Total_populaton_got_covid
from master..CovidDeaths
--where location like '%india%'
where continent is not null
order by 1, 2

--Looking at Countries with Highest Infection rate as compared to Population

Select Location, population, date, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentOfPopulationInfected
from master..CovidDeaths
--where location like '%india%'
group by location, population, date
order by PercentOfPopulationInfected desc


--Showing Countries with highest Death Count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from master..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc	


Select Location, Sum(cast(new_deaths as int)) as TotalDeathCount
from master..CovidDeaths
--where location like '%india%'
where continent is null
and location not in ('European Union','World','International')
group by location
order by TotalDeathCount desc

-- Break things Down by continents


--Showing the continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from master..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc	

-- Global Numbers

Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from master..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1, 2

--Looking at total Population vs vaccination

Select Dea.continent, Dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(PARTITION by dea.location order by dea.location, dea.date) as rollingPeopleVacccinated
--(rollingPeopleVacccinated)/dea.population * 100 
from master..CovidDeaths as Dea
Join 
master..CovidVaccinations as vac
on Dea.location = vac.location
and Dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USE CTE

With PopvsVac (Continent, Location, Date, population, new_vaccination, rollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(PARTITION by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated)/population * 100 
from master..CovidDeaths as Dea
Join 
master..CovidVaccinations as vac
on Dea.location = vac.location
and Dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (rollingPeopleVaccinated)/population * 100  from PopvsVac


--Temp Table 

Drop table if exists #PerPopVaccinated
Create table #PerPopVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert Into #PerPopVaccinated
Select Dea.continent, Dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(PARTITION by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated)/population * 100 
from master..CovidDeaths as Dea
Join 
master..CovidVaccinations as vac
on Dea.location = vac.location
and Dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

Select *, (rollingPeopleVaccinated/population) * 100  
from #PerPopVaccinated

--Creating View for later visualization

Create View PercentagePoplVaccinated as
Select Dea.continent, Dea.location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(PARTITION by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated)/population * 100 
from master..CovidDeaths as Dea
Join 
master..CovidVaccinations as vac
on Dea.location = vac.location
and Dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select * from PercentagePoplVaccinated