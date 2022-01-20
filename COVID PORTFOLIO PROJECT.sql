select *
from [Portfolio project]..CovidDeaths where continent is not null 
order by 3,4

--select *
--from [Portfolio project]..CovidVaccinations
--order by 3,4

--select data that we are going to be using 

select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio project]..CovidDeaths where continent is not null 
order by 1,2

--looking at the total cases vs total deaths
--shows the likelihood of dying if you contract covid in our country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulation
from [Portfolio project]..CovidDeaths 
where continent is not null 
and location like '%india%'
order by 1,2


--looking at the total cases vs population 

select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio project]..CovidDeaths
where continent is not null 
and location like '%india%'
order by 1,2

--looking at countries with highest infection rate. 

select Location, population, MAX(total_cases) as HighestInfetionCount, MAX((total_cases/population))*100 as 
PercentPopulationInfected
from [Portfolio project]..CovidDeaths
--Where location like '%india%'
group by Location, population
order by PercentPopulationInfected desc

--looking at the highest death counts for death population 

select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
--Where location like '%india%'
where continent is not null 
group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT 

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
--Where location like '%india%'
where continent is null 
group by location
order by TotalDeathCount desc


select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
--Where location like '%india%'
where continent is not null 
group by continent 
order by TotalDeathCount desc

--showing the continents with higest death counts. 

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio project]..CovidDeaths
--Where location like '%india%'
where continent is null 
group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio project]..CovidDeaths
--where location like '%india%'
 where continent is not null 
 --group by date
 order by 1,2


 --looking at total population vaccinations

select  dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--  USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
select  dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project]..CovidDeaths dea
Join [Portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- creating view to store data for later visualizations

Create View #PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project]..CovidDeaths dea
Join [Portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * 
from #PercentPopulationVaccinated

