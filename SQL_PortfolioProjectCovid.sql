select * from portfolio_project..CovidDeaths$
where continent is not null
order by 3,4


--select * from portfolio_project..covid_vaccinations1$
--order by 3,4

select location,date, new_cases, total_cases, total_deaths, population
from portfolio_project..CovidDeaths$
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if u contract covid in ur country

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio_project..CovidDeaths$
where location like '%india%'
order by 1,2


--looking at total cases vs population
--shows what population of the country got covid
select location,date, total_cases, population, (total_cases/population)*100 as population_percentageInfected
from portfolio_project..CovidDeaths$
where location like '%india%'
order by 1,2

--looking at the countries with highest infection rate as per the population

select location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationPercentageInfected
from portfolio_project..CovidDeaths$
group by location, population
order by PopulationPercentageInfected desc

--countries with highest death count per population
select location,  MAX(cast (total_deaths as int)) as totalDeathCount
from portfolio_project..CovidDeaths$
where continent is not null
group by location
order by totalDeathCount desc

--let's break things down by continent

select location,  MAX(cast (total_deaths as int)) as totalDeathCount
from portfolio_project..CovidDeaths$
where continent is null
group by location
order by totalDeathCount desc

--global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from portfolio_project..CovidDeaths$
where continent is not null
group by date
order by 1,2


--joing the two tables
select  *
  from portfolio_project.. covidDeaths$ dea
join portfolio_project..covid_vaccinations1$ vac
on dea.location= vac.location
and
dea.date= vac.date	


-- loooking at total population vs vaccination

select  
 dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations 
From portfolio_project.. covidDeaths$ dea
join portfolio_project..covid_vaccinations1$ vac
on dea.location= vac.location
and
dea.date= vac.date	
where dea.continent is not null
order by 2,3


select  
 dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations) )  OVER (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
 
From portfolio_project.. covidDeaths$ dea
join portfolio_project..covid_vaccinations1$ vac
on dea.location= vac.location
and
dea.date= vac.date	
where dea.continent is not null
order by 2,3

--new code
--use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select  
 dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
 SUM(cast (vac.new_vaccinations as bigint) ) OVER (partition by dea.location order by dea.location,dea.date)
   as RollingPeopleVaccinated
 
From portfolio_project.. covidDeaths$ dea
join portfolio_project..covid_vaccinations1$ vac
on dea.location= vac.location
and 
dea.date= vac.date	
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated)/(population)*100                         -- giving erro
 From PopvsVac


 -- from net same code copied from net
 With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths$ dea
Join Portfolio_Project..Covid_Vaccinations1$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population) * 100	
From PopvsVac



--TEMP Table

 drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths$ dea
Join Portfolio_Project..Covid_Vaccinations1$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population) * 100	
From #PercentPopulationVaccinated




-- Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths$ dea
Join Portfolio_Project..Covid_Vaccinations1$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

select * from PercentPopulationVaccinated

