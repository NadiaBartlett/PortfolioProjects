Select *
From NadiasPortfolioProject..CovidDeaths
where continent is not null 
Order by 3,4


--Select *
--From NadiasPortfolioProject..CovidVaccinations
--Order by 3,4

--Select the datathat we are going to be using 

Select Location, Date, total_cases , new_cases , total_deaths, population
From NadiasPortfolioProject..CovidDeaths
where continent is not null 
Order by 1,2


--Looking at the total cases vs Total deaths 
-- Shows the likelihood of dying from covid in your country
Select Location, Date, total_cases , total_deaths, (total_deaths/Total_cases)*100 as DeathPercentage
From NadiasPortfolioProject..CovidDeaths
Where Location like '%States%' and continent is not null 
Order by 1,2



-- Looking at The total cases vs the population
--Shows what percentage of population caught covid

Select Location, Date, total_cases , population, (total_cases/population)*100 as PopulationInfectionRate
From NadiasPortfolioProject..CovidDeaths
--Where Location like '%States%'
Order by 1,2


-- Looking at countries with the highest infection rate compared to population

Select Location, population, Max (total_cases) as HighestInfectionRate, Max((total_cases/population))*100 as PopulationInfectionRate
From NadiasPortfolioProject..CovidDeaths
--Where Location like '%States%'
Group by Location, population
Order by PopulationInfectionRate desc

-- Showing countries with Highest Death rate per population 

Select Location, Max (Cast (total_deaths as int)) as TotalDeathCount
From NadiasPortfolioProject..CovidDeaths
--Where Location like '%States%'
where continent is not null 
Group by Location
Order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with highest Death counts
Select continent, Max (Cast (total_deaths as int)) as TotalDeathCount
From NadiasPortfolioProject..CovidDeaths
--Where Location like '%States%'
where continent is not null 
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select Sum(new_cases) as TotalCases, Sum (cast(new_deaths as int)) as TotalDeaths, Sum (cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From NadiasPortfolioProject..CovidDeaths
--Where Location like '%States%'
Where continent is not null 
--group by date
Order by 1,2


--Looking at total population vs vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert (int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
--, (RollingVaccination/population)*100
From NadiasPortfolioProject..CovidDeaths dea
Join NadiasPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
	Where dea.continent is not null 
	Order by 2,3


-- USE CTE

with PopvsVac (continent ,location, date, population,new_vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert (int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
--, (RollingVaccination/population)*100
From NadiasPortfolioProject..CovidDeaths dea
Join NadiasPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
Where dea.continent is not null 
--Order by 2,3
)
Select*, (RollingVaccinations/population)*100
From PopvsVac

--Temp Table 

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert (int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
--, (RollingVaccination/population)*100
From NadiasPortfolioProject..CovidDeaths dea
Join NadiasPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
Where dea.continent is not null 
--Order by 2,3

Select *, ( RollingVaccinations/population)*100
from #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert (int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
--, (RollingVaccination/population)*100
From NadiasPortfolioProject..CovidDeaths dea
Join NadiasPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
Where dea.continent is not null 
--Order by 2,3

Select*
from PercentPopulationVaccinated
