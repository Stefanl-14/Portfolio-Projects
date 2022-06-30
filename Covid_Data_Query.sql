select *
from [Portfolio Project]. .[Covid Deaths]
where continent is not null
order by 3,4

--select *
--from [Portfolio Project]. .[Covid Vacinations]
--order by 3,4


--Select Data

Select location,date,total_cases, new_cases, total_deaths, population
From [Portfolio Project]..[Covid Deaths]
order by 1,2


--Total Cases Vs. Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..[Covid Deaths]
order by 1,2


--Total Cases Vs Total Deaths
--Chance of dying of Covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..[Covid Deaths]
where location like '%Saint Kitts and Nevis%'
order by 1,2



---Total Cases vs Population
-- Percentage of population that contracted covid
select location, date, total_cases,population, (total_cases/population)*100 as PercentageofPopulationInfected
From [Portfolio Project]..[Covid Deaths]
where location like '%Saint Kitts and Nevis%'
order by 1,2



--Daily infection rate
--Calculate infection rate per 1000 residents
select location, date, new_cases,population, (new_cases/population)*1000 as InfectionRate
From [Portfolio Project]..[Covid Deaths]
where location like '%Saint Kitts and Nevis%'
order by 1,2

--Countries with highest infection rate
--Calculate infection rate per 1000 residents
select location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRate
From [Portfolio Project]..[Covid Deaths]
--where location like '%Saint Kitts and Nevis%'
Group by location, population
order by InfectionRate desc


--Countries with highest death count per population
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
--where location like '%Saint Kitts and Nevis%'
where continent is not null
Group by location
order by TotalDeathCount desc


---Continental Breakdown
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
--where location like '%Saint Kitts and Nevis%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..[Covid Deaths]
--where location like '%Saint Kitts and Nevis%'
where continent is not null
--Group by date
order by 1,2



Select *
From [Portfolio Project] ..[Covid Deaths] dea
Join [Portfolio Project] ..[Covid Vacinations] vac
on dea.location = vac.location
and dea.date = vac.date

--Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
From [Portfolio Project] ..[Covid Deaths] dea
Join [Portfolio Project] ..[Covid Vacinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Total Population Vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date ROWS Unbounded Preceding) as RollingPeopleVaccinated,
(Roll
From [Portfolio Project] ..[Covid Deaths] dea
Join [Portfolio Project] ..[Covid Vacinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



--Use CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date ROWS Unbounded Preceding) as RollingPeopleVaccinated
From [Portfolio Project] ..[Covid Deaths] dea
Join [Portfolio Project] ..[Covid Vacinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location like '%Saint Kitts and Nevis%'
--where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/Population)*100 as PercentagePopVaccinated
From PopVsVac


--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
contient nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date ROWS Unbounded Preceding) as RollingPeopleVaccinated
From [Portfolio Project] ..[Covid Deaths] dea
Join [Portfolio Project] ..[Covid Vacinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location like '%Saint Kitts and Nevis%'
--where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/Population)*100 as PercentagePopVaccinated
From #PercentPopulationVaccinated




----Creating View to Store Data for later Visualizations

Create View GlobalNumbers as
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[Covid Deaths]
--where location like '%Saint Kitts and Nevis%'
where continent is not null
Group by continent
--order by TotalDeathCount desc


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date ROWS Unbounded Preceding) as RollingPeopleVaccinated
From [Portfolio Project] ..[Covid Deaths] dea
Join [Portfolio Project] ..[Covid Vacinations] vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.location like '%Saint Kitts and Nevis%'
where dea.continent is not null
--order by 2,3

