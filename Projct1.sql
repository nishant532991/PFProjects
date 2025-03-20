
select * from CovidDeaths$
where continent is not null
order by 3,4;

select * from Covidvaccine$;

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not null
 order by 1,2;

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths, round((total_deaths/total_cases) *100,2)  as deathpercentage
from CovidDeaths$
where location like '%India%'
and continent is not null
 order by 1,2;
 
 -- looking at the total cases vs population
 
 select location, date, total_cases, population, round((total_cases/population) *100,2)  as casepercentage
from CovidDeaths$
where continent is not null
-- where location like '%India%'
order by 1,2;

-- countries with highest infection rate compared to population

 select location, population, max(total_cases) as highest_infectioncount,  max((total_cases/population) *100)  as perctpopinfc
from CovidDeaths$
where continent is not null
group by location, population 
-- where location like '%India%'
order by perctpopinfc desc;

-- looking at highest total deaths counts per population

 select location,  max(cast(total_deaths as int)) as deathcount
from CovidDeaths$
where continent is not null
group by location 
-- where location like '%India%'
order by deathcount desc;

-- Breaking by continent
select location,  max(cast(total_deaths as int)) as deathcount
from CovidDeaths$
where continent is null
group by location 
-- where location like '%India%'
order by deathcount desc;



-- showing continent with highest deathcount

select location,  max(cast(total_deaths as int)) as deathcount
from CovidDeaths$
where continent is not null
group by location 
-- where location like '%India%'
order by deathcount desc;

-- breaking global numbers

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage --total_deaths, round((total_deaths/total_cases) *100,2)  as deathpercentage
from CovidDeaths$
--where location like '%India%'
where continent is not null
--group by date
 order by 1,2;


 -- total population vs vaccination
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated --- convert is same as cast
--, (rollingpeoplevaccinated/population)*100
 from CovidDeaths$ dea
  join Covidvaccine$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

  --use cte
	 with cte as ( 
	  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated --- convert is same as cast
	--, (rollingpeoplevaccinated/population)*100
	 from CovidDeaths$ dea
	  join Covidvaccine$ vac
	  on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null
	  --order by 2,3
	  )
	  select *, (rollingpeoplevaccinated/population)*100 as vaccntdpercnt
	  from cte

-- Temp Table
drop table if exists percentpopvaccinated
create table percentpopvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations int,
rollingpeoplevaccinated numeric
)

insert into percentpopvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated --- convert is same as cast
	--, (rollingpeoplevaccinated/population)*100
	 from CovidDeaths$ dea
	  join Covidvaccine$ vac
	  on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null
	  --order by 2,3
	   select *, (rollingpeoplevaccinated/population)*100 as vaccntdpercnt
	  from percentpopvaccinated

--creating views to store data for later visualzation

create view percentpopvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated --- convert is same as cast
	--, (rollingpeoplevaccinated/population)*100
	 from CovidDeaths$ dea
	  join Covidvaccine$ vac
	  on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null
	 -- order by 2,3

select * 
from percentpopvaccinated 
	  