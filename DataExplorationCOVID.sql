Select Location, date, total_cases, new_cases, total_deaths, population
From project1..CovidDeaths
where continent is not null
order by 1,2

--Total Cases vs Total Deaths
--Likelihood of dying due to covid in India

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From project1..CovidDeaths
where location like '%India%'
order by 1,2


----Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)*100 as Infected
From project1..CovidDeaths
--where location like '%India%'
order by 1,2


--Countries with highest infection rate compared to population
 
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Infected
From project1..CovidDeaths
--where location like '%India%'
group by location, population
order by Infected desc

--Countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From project1..CovidDeaths
--where location like '%India%'
where continent is not null
group by location
order by TotalDeathCount desc

--EXPLORE BY CONTINENT

--Continents with highest death count (accurate)

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From project1..CovidDeaths
--where location like '%India%'
where continent is null
group by location
order by TotalDeathCount desc


--Continents with highest death count (has some discrepancies)

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From project1..CovidDeaths
--where location like '%India%'  
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From project1..CovidDeaths
--Where location like '%india%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Percentage of Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project1..CovidDeaths dea
Join project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project1..CovidDeaths dea
Join project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
From project1..CovidDeaths dea
Join project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project1..CovidDeaths dea
Join project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * 
from PercentPopulationVaccinated