select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2


-- Total Cases & Total Deaths
-- Shows likelihood of dying in case of having covid
-- Note for me."cast" is used for converting data type to float, since it was nvarchar.

select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as Death_Percentage
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2


-- Total Cases & Population
-- Shows the percentage of populatoin got covid

select location, date, population, total_cases, (cast(total_cases as float)/population)*100 as Infection_Percentage
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2

--Countries with highest Infection rate compared to population

select location, population, max(cast(total_cases as float)) as highest_Infection, max((cast(total_cases as float)/population)*100) as Infection_Percentage
from PortfolioProject..CovidDeath
where continent is not null
group by location, population
order by Infection_Percentage desc

--Highest death count by countries

select location, max(cast(total_deaths as int)) as highest_TotalDeath 
from PortfolioProject..CovidDeath
where continent is not null
group by location
order by highest_TotalDeath desc


--Highest death count by continents
select continent, max(cast(total_deaths as int)) as highest_TotalDeath 
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by highest_TotalDeath desc



--Global numbers

select date, sum(new_cases) as daily_New_Cases, sum(new_deaths) as daily_New_Death, ((sum(new_deaths))/(sum(new_cases)))*100 as Death_Percentage
from PortfolioProject..CovidDeath
where new_cases!=0 and continent is not null 
group by date
order by 1,2

select sum(new_cases) as daily_New_Cases, sum(new_deaths) as daily_New_Death, ((sum(new_deaths))/(sum(new_cases)))*100 as Death_Percentage
from PortfolioProject..CovidDeath
where new_cases!=0 and continent is not null 
order by 1,2



--Total population vs Vaccination
select d.continent, d.location, d.date, population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location,d.date) as sumUp_newVac
from PortfolioProject..CovidDeath d
join PortfolioProject..CovidVaccination v
     on d.location=v.location
     and d.date=v.date
where d.continent is not null 
order by 2,3


--Using CTE

with PopulvsVaccin (continent, location, date, population, new_vaccinations,sumUp_newVac)
as
(
select d.continent, d.location, d.date, population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location,d.date) as sumUp_newVac
from PortfolioProject..CovidDeath d
join PortfolioProject..CovidVaccination v
     on d.location=v.location
     and d.date=v.date
where d.continent is not null 
)
select *, (sumUp_newVac/population)*100
from PopulvsVaccin



--Temp table


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
sumUp_newVac numeric
)
insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location,d.date) as sumUp_newVac
from PortfolioProject..CovidDeath d
join PortfolioProject..CovidVaccination v
     on d.location=v.location
     and d.date=v.date
--where d.continent is not null 

select *, (sumUp_newVac/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualization

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location,d.date) as sumUp_newVac
from PortfolioProject..CovidDeath d
join PortfolioProject..CovidVaccination v
     on d.location=v.location
     and d.date=v.date
where d.continent is not null 



