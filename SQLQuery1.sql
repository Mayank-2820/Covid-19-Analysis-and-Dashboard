select *
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from [Portfolio Project]..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2


-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [Portfolio Project]..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at total cases  vs population
-- shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
from [Portfolio Project]..CovidDeaths$
--where location like '%states%' and continent is not null
order by 1,2 


-- Looking at countries at highest infection rate compared to population

select location, max(total_cases) as highest_infection_count, population, max((total_cases/population))*100 as hihgest_infected_percentage
from [Portfolio Project]..CovidDeaths$
--where location like '%states%' and continent is not null
Group by location, population
order by hihgest_infected_percentage desc


-- Showing countries with the highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location
order by total_death_count desc


-- Lets break things down by continent

select location, max(cast(total_deaths as int)) as total_death_count
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is null
Group by location
order by total_death_count desc


--This is showing continent with highest death count per population

select continent, max(cast(total_deaths as int)) as total_death_count
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by total_death_count desc


--Global Numbers 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccination

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- Using CTE

with popvsvac(continent, location, date,population, new_vaccinations, rolling_peopel_vaccinations)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_peopel_vaccinations/population)*100 
from popvsvac


-- Temp Table

Drop table if exists  percent_people_vaccinated
Create table percent_people_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinations numeric
)

insert into percent_people_vaccinated

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rolling_people_vaccinations/population)*100 
from percent_people_vaccinated



-- Creating view to store data for later visualization


use [Portfolio Project]

go

CREATE VIEW Pop_percentage_vaccinated as

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (rolling_people_vaccinations/population)*100 
from Pop_percentage_vaccinated