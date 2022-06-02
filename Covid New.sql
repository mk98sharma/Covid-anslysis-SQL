-- just checking our data
select *
from portfolioproject ..CovidDeaths
where continent is not null
order by 3,4
-- will use it later
--select *
--from portfolioproject..CovidVaccinations
--order by 3,4

--just selecting things which matter for now
select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..CovidDeaths
order by 1,2

-- calculating Death Percentage
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where continent is not null
order by 1,2

-- Death percentage in India
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where location like '%India%'
order by 1,2

select location,date,total_cases,population,(total_cases/population)*100 as InfectionPercentage
from portfolioproject..CovidDeaths
where location like '%India%'
order by 1,2

select location,date,total_cases,population,(total_cases/population)*100 as InfectionPercentage
from portfolioproject..CovidDeaths
--where location like '%India%'
order by 1,2

-- highest infection rate
select location,population,MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
from portfolioproject..CovidDeaths
--where location like '%India%'
Group by location, Population
order by PercentagePopulationInfected desc

select location,MAX(cast(total_deaths as int)) AS TotalDeath
from portfolioproject..CovidDeaths
--where location like '%India%'
where continent is not null
Group by location, Population
order by TotalDeath desc

-----continent

select location,MAX(cast(total_deaths as int)) AS TotalDeath
from portfolioproject..CovidDeaths
--where location like '%India%'
where continent is null
Group by location
order by TotalDeath desc


-- showing continent with highest death count
select location,MAX(cast(total_deaths as int)) AS TotalDeath
from portfolioproject..CovidDeaths
--where location like '%India%'
where continent is null
Group by location
order by TotalDeath desc

-- breaking global numbers

select date,SUM(new_cases) AS TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths,Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPERCENTAGE
from portfolioproject..CovidDeaths
--where location like '%India%'
where continent is not null
group by date
order by 1,2

---total case in world and death pert
select SUM(new_cases) AS TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths,Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPERCENTAGE
from portfolioproject..CovidDeaths
--where location like '%India%'
where continent is not null
--group by date
order by 1,2


-- combining date and location of both death and vaccination table
select *
from portfolioproject..CovidDeaths dea
Join portfolioproject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

	--Looking at total population vs vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	from portfolioproject..CovidDeaths dea
	Join portfolioproject..Covidvaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	order by 1,2,3

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	 ,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
	---- (rollingPeopleVaccinated)*100
	from portfolioproject..CovidDeaths dea
	Join portfolioproject..Covidvaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	-- use CTE
with PopvsVac (continent,location,date,population,new_vaccinations, rollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	 dea.date) as rollingPeopleVaccinated
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingPeopleVaccinated/population)*100
from PopvsVac


-----temp table

Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	 dea.date) as rollingPeopleVaccinated
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(rollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--- creating view to store data for later visualiization
Create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
	,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	 dea.date) as rollingPeopleVaccinated
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated