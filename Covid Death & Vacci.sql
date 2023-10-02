-- Selecting data that we are going to be using

Select *
From [Portfolio Project]..CovidDeaths$
Where continent is not null
Order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
From [Portfolio Project]..CovidDeaths$
order by 1,2

-- We are looking at the Total Cases vs Total Deaths
-- Show likelyhood of dying if you contract Covid in your Country

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
From [Portfolio Project]..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got COVID 

Select location,date,total_cases,population,(total_cases/population)*100 as CovidCases_Percentage
From [Portfolio Project]..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rtae compared to Population
-- The smallest to the biggest

Select location,population,MAX(total_cases) as HighestInfectionCount, MAX(( total_cases/population))
	CovidCases_Percentage
From [Portfolio Project]..CovidDeaths$
Group by location, population
order by CovidCases_Percentage desc 

--Showing Countries with highest death count per population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
Where continent is not null --in order to get countries not continent in table
Group by location
order by TotalDeathCount desc 

--Showing Countries with highest death count per continent

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
Where continent is null
group by location
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers per dates

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Death_Percentage
From [Portfolio Project]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Death_Percentage
From [Portfolio Project]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

--COVID VACCINATIONS CASES

-- Looking at TOTAL population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Portfolio Project]..CovidDeaths$ as dea
Join [Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--> Example of Using a CTE to be able to create a parameter and use it in the same query

WITH POPvsVac (Continent, Location, Date, Population,new_vaccinations 
,RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER by dea.location,dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM [Portfolio Project]..CovidDeaths$ as dea
Join [Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From POPvsVac

-- EXAMPLE of TEMP Table for Total Pop vs Vac

DROP TABLE IF exists #PercentPopVac

CREATE TABLE #PercentPopVac
(
Continent nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopVac

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER by dea.location,dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM [Portfolio Project]..CovidDeaths$ as dea
Join [Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopVac

-- Creating View to Store Data for Visualization 

CREATE View PercentPopVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER by dea.location,dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM [Portfolio Project]..CovidDeaths$ as dea
Join [Portfolio Project]..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
Where continent is not null
group by continent
order by TotalDeathCount desc

SELECT * 
FROM PercentPopVac