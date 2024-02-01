select *
from PortofolioProject ..CovidDeaths
order by 3,4

--select *
--from PortofolioProject ..CovidVaccination
--order by 3,4

--data we are going to use
select location,date,total_cases,new_cases,total_deaths,population
from PortofolioProject ..CovidDeaths
order by 1,2

--total cases vs total deaths in india
Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from PortofolioProject ..CovidDeaths
where total_cases is not null and location like '%india%'
order by  1,2

--total cases vs population
Select location, date, population,total_cases, (CONVERT(float, total_cases) / population)*100 as PopulationInfected
from PortofolioProject ..CovidDeaths
where total_cases is not null --location like '%india%'
order by  1,2

--countries whith highest covid cases
Select location, population,MAX (total_cases) as CovidCases, MAX (CONVERT(float, total_cases) / population)*100 as CountriesMaxCases
from PortofolioProject ..CovidDeaths
--where location like '%india%'
Group by location, population 
order by  CountriesMaxCases desc


--countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject ..CovidDeaths
where continent is not null
Group by location
order by  TotalDeathCount desc

--Continents with covid cases
Select continent, MAX(cast(total_cases as int)) as TotalCaseCount
from PortofolioProject ..CovidDeaths
where continent is not null
Group by continent
order by  TotalCaseCount desc

--continents with highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject ..CovidDeaths
where continent is not null
Group by continent
order by  TotalDeathCount desc

--global numbers for total cases
Select date, sum(NULLIF(CONVERT(float, total_cases), 0)) as TotalGlobalCases, SUM(CAST(total_deaths as int)) as TotalGlobalDeaths
from PortofolioProject ..CovidDeaths
where total_cases is not null --and location like '%india%'
group by date
order by  1,2

--global numbers for new cases
Select date, sum(new_cases) as NewGlobalCases,SUM(CAST(new_deaths as int)) as NewGlobalDeaths,SUM(CAST(new_deaths as int))/sum(new_cases)*100 as NewDeaths
from PortofolioProject ..CovidDeaths
where total_cases is not null --and location like '%india%'
group by date
order by  1,2

--Total new cases,deaths
Select sum(new_cases) as NewGlobalCases,SUM(CAST(new_deaths as int)) as NewGlobalDeaths,SUM(CAST(new_deaths as int))/sum(new_cases)*100 as NewDeaths
from PortofolioProject ..CovidDeaths
where total_cases is not null --and location like '%india%'
--group by date
order by  1,2


--join 2 tables

select *
from PortofolioProject ..CovidDeaths dea
join PortofolioProject ..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

--total population vs vaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortofolioProject ..CovidDeaths dea
join PortofolioProject ..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--Rolling count of people vacinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated

from PortofolioProject ..CovidDeaths dea
join PortofolioProject ..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3 

--Use CTE

with PopvsVac(Continent,Location,Date,Population,New_Vacinations,RollingPeopleVacinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated

from PortofolioProject ..CovidDeaths dea
join PortofolioProject ..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 
)

select *,(RollingPeopleVacinated/Population)*100 as TotalVacinated
from PopvsVac



--Temp Table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVacinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacinated

from PortofolioProject ..CovidDeaths dea
join PortofolioProject ..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select *,(RollingPeopleVacinated/Population)*100 as TotalVacinated
from #PercentPopulationVaccinated

