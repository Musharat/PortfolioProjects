
Select *
From PortfolioProject..CovidDeaths
Where continent is not Null
Order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Data that I will be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.. CovidDeaths
Where continent is not Null
order by 1,2

-- LOOKING AT THE TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject.. CovidDeaths
Where location like '%canada%'
order by 1,2

--LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENT OF POPULATION GOT COVID IN CANADA

Select Location, date,population, total_cases, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))*100 as PercentPoulationInfected
From PortfolioProject.. CovidDeaths
order by 1,2


-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

Select Location,population, MAX(total_cases) AS HighestInfectionCount, MAX(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))*100 as PercentPoulationInfected
From PortfolioProject.. CovidDeaths
Group by Location,population
order by PercentPoulationInfected desc

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

Select Location, MAX(cast(total_deaths as int)) TotalDeathCount
From PortfolioProject.. CovidDeaths
Where continent is not Null
Group by Location
order by TotalDeathCount desc

-- I AM GOING TO BREAK THINGS DOWN BY CONTINENT.
-- SHOWING CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION.

Select continent, MAX(cast(total_deaths as int)) TotalDeathCount
From PortfolioProject.. CovidDeaths
Where continent is not Null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as int)) as total_death, 
       CASE WHEN SUM(new_cases) = 0 THEN 0
            ELSE SUM(cast(new_deaths as int))/SUM(new_cases)*100 
       END as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1, 2;

-- LOOKING AT TOTAL POPULATION VS VACCINATION

with PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    --(RollingPeopleVaccinated/population)*100
    From PortfolioProject..CovidDeaths dea
    Join PortfolioProject..CovidVaccinations vac
        On dea.location = vac.location
        And dea.date = vac.date
    Where dea.continent is not null
    --order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    --(RollingPeopleVaccinated/population)*100
    From PortfolioProject..CovidDeaths dea
    Join PortfolioProject..CovidVaccinations vac
        On dea.location = vac.location
        And dea.date = vac.date
    --Where dea.continent is not null
    --order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    --(RollingPeopleVaccinated/population)*100
    From PortfolioProject..CovidDeaths dea
    Join PortfolioProject..CovidVaccinations vac
        On dea.location = vac.location
        And dea.date = vac.date
    Where dea.continent is not null
    --order by 2,3



Select *
from PercentPopulationVaccinated