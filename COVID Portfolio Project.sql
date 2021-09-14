Select *
From PortfolioProject..COVID_Deaths
Where continent is not null
order by 3,4


--Select *
--From PortfolioProject..COVID_Vaccinations
--order by 3,4


-- Select Data that will be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..COVID_Deaths
order by 1,2


-- Looking at Total Caes vs Total Deaths
-- Shows likelihood of dying if you catch COVID by country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..COVID_Deaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population that caught COVID

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..COVID_Deaths
Where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..COVID_Deaths
-- Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc


-- Showing Countries with highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..COVID_Deaths
-- Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Showing Continents with the highest Death Count


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..COVID_Deaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases) * 100 as DeathPercentage
From PortfolioProject..COVID_Deaths
--Where location like '%states%'
where continent is not null
-- Group by date
order by 1,2


-- Looking at Total Population vs Vacinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/Population) * 100
From PortfolioProject..COVID_Deaths dea
Join PortfolioProject..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/Population) * 100
From PortfolioProject..COVID_Deaths dea
Join PortfolioProject..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac


-- TEMP TABLE


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/Population) * 100
From PortfolioProject..COVID_Deaths dea
Join PortfolioProject..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/Population) * 100
From PortfolioProject..COVID_Deaths dea
Join PortfolioProject..COVID_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated