use SQL_Server;
-- Covid Deaths Table
select 
   *
from CovidDeaths
where continent is not null
order by location, date;

-- Covid Vaccinations Table
select 
   *
from CovidVaccinations
where continent is not null
order by location, date;


-- Retrieve data data that we are going to be use
-- We are using covid-19 date from 2020-01-04 to 2021-04-30
-- We are going to use more than one year covid data

select 
   continent, location, date, total_cases, 
   new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by location, date;

-- Looking Total Cases vs Toal deaths
-- Show likehood of dying If you contract covid-19 in your country (India)

select 
   location, date, total_cases, 
   new_cases, total_deaths,
   ROUND((total_deaths/total_cases)*100, 2) as death_pct
from CovidDeaths
where 
   continent is not null and
   location= 'India'
order by location, date;

-- Looking Total Cases vs populations
-- Shows what percentage of population infected with Covid

select 
   location, date, total_cases, 
   new_cases, total_deaths,   population,
   ROUND((total_cases/population)*100, 2) as population_Infected_ptc
from CovidDeaths
where 
     continent is not null and 
     location= 'India'
order by location, date;

-- Countries with Highest Infection Rate compared to Population 
-- Andorra is the highest infection rate (~18%) to population 

WITH highest_Caes_Infected 
AS
(
    select 
		 location, population, 
	     MAX(total_cases) as highest_cases_infected
	from CovidDeaths
	where continent is not null
	group by location, population
)
select 
    *,
	ROUND((highest_cases_infected/population)*100, 2) as population_Infected_ptc
from highest_Caes_Infected
where highest_cases_infected is not null
order by population_Infected_ptc desc;

-- Countries with Highest Death Count per Population 

select 
	location, 
	ROUND(population/1000000,2) as population_mln, 
	MAX(cast(total_deaths as int)) as highest_deaths
from CovidDeaths
where continent is not null
group by location, population
order by highest_deaths desc

-- -- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select 
	continent,
    MAX(cast(total_deaths as int)) as Total_death_Count
from CovidDeaths
where continent is not null
group by continent
order by Total_death_Count desc

-- GLOBAL NUMBER

-- Total new cases every day in the world
-- Total new death every day in the world
-- Total death percentage every day in the world

select 
	date,
	SUM(new_cases) as total_new_cases,
	SUM(cast(new_deaths as int)) as total_new_deaths,
	ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100, 3) as death_pct
from CovidDeaths
where 
    continent is not null and 
	new_deaths<>0
group by date
order by date 

--creating view



-- Total cases are 149.004 mln in the world
-- Total deaths are 3 mln in the world
-- Total deaths are 2.134% in the world

select 
	ROUND(SUM(new_cases)/1000000, 3) as total_cases_mln,
	ROUND(SUM(cast(new_deaths as int))/1000000, 6)as total_deaths_mln,
	ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100, 3) as death_pct
from CovidDeaths
where 
    continent is not null and 
	new_deaths<>0

-- Total vaccinations VS Populaton

-- Use CTE (comman tabel expression)

With vaccinations_VS_Populaton
AS
(  select 
	   vac.continent, vac.location, vac.date,
	   dea.population, vac.new_vaccinations,
	   SUM(cast(vac.new_vaccinations as int)) over(partition by vac.location order by vac.location ,vac.date) as running_Total_vaccinations
   from CovidVaccinations  vac
   join CovidDeaths dea
		on vac.date = dea.date and
		   vac.location = dea.location
   where vac.continent is not null
)

select 
    *,
	(running_Total_vaccinations/population)*100  as running_Total_vaccinations_pct
from vaccinations_VS_Populaton;

-- Total vaccinations by continets

select 
   vac.continent,
   ROUND(SUM(cast(vac.new_vaccinations as int))/1000000, 2) as total_vaccinations_mln
from CovidVaccinations  vac
join CovidDeaths dea
    on vac.date = dea.date and
	   vac.location = dea.location
where vac.continent is not null
group by vac.continent
order by vac.continent

-- Temp Tabel

drop Table if exists #Running_total_Vaccinations
create Table #Running_total_Vaccinations
(
continent nvarchar(225),
location nvarchar(220),
date datetime,
population numeric,
new_vaccinations numeric,
running_total_Vaccinations numeric
)
insert into #Running_total_Vaccinations
	  select 
		   vac.continent, vac.location, vac.date,
		   dea.population, vac.new_vaccinations,
		   SUM(cast(vac.new_vaccinations as int)) over(partition by vac.location order by vac.location ,vac.date) as running_Total_vaccinations
	   from CovidVaccinations  vac
	   join CovidDeaths dea
			on vac.date = dea.date and
			   vac.location = dea.location
	   where vac.continent is not null

-- Creating view to store data for later visual

create view cases_VS_deaths as
select 
	date,
	SUM(new_cases) as total_new_cases,
	SUM(cast(new_deaths as int)) as total_new_deaths,
	ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100, 3) as death_pct
from CovidDeaths
where 
    continent is not null and 
	new_deaths<>0
group by date

select
   *
from cases_VS_deaths


