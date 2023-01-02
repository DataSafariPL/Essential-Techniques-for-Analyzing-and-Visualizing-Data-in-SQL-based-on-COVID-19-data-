Covid 19 Data Exploration. Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
-------------------------------------------------------------

SELECT *
FROM portfolioproject.covid19deaths
ORDER BY 3 , 4

SELECT *
FROM portfolioproject.covidvaccinations
ORDER BY 3 , 4

-------------------------------------------------------------Select data that we are going to be using

SELECT 
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    portfolioproject.covid19deaths
ORDER BY 1 , 2

-- Looking at Total cases vs Total deaths
-- Shows likehood of dying if you contract covid in Poland (PL)

SELECT 
    Location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    portfolioproject.covid19deaths
WHERE
    Location = 'Poland'
ORDER BY 1 , 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
FROM portfolioproject.covid19deaths
Where Location = "Poland"
ORDER BY 1,2.

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT 
    Location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM
    portfolioproject.covid19deaths
GROUP BY Location , Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT 
    Location,
    MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM
    portfolioproject.covid19deaths
WHERE
    continent IS NOT NULL
        AND continent <> ''
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT 
    continent,
    MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM
    portfolioproject.covid19deaths
WHERE
    continent IS NOT NULL
        AND continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths,
    SUM(CAST(new_deaths AS UNSIGNED)) / SUM(New_Cases) * 100 AS DeathPercentage
FROM
    portfolioproject.covid19deaths
WHERE
    continent IS NOT NULL
        AND continent <> ''
ORDER BY 1 , 2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea1.continent, dea1.location, dea1.date, dea1.population, vac1.new_vaccinations,
SUM(CAST(vac1.new_vaccinations as UNSIGNED)) OVER (Partition by dea1.Location Order by dea1.location, dea1.Date) as RollingPeopleVaccinated
From portfolioproject.covid19deaths dea1
Join portfolioproject.covid22vac vac1
	On dea1.location = vac1.location
	and dea1.date = vac1.date
Where dea1.continent IS NOT NULL
        AND dea1.continent <> ''
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea1.continent, dea1.location, dea1.date, dea1.population, vac1.new_vaccinations,
SUM(CAST(vac1.new_vaccinations as UNSIGNED)) OVER (Partition by dea1.Location Order by dea1.location, dea1.Date) as RollingPeopleVaccinated
From PortfolioProject.covid19deaths dea1
Join PortfolioProject.covid22vac vac1
	On dea1.location = vac1.location
	and dea1.date = vac1.date
Where dea1.continent IS NOT NULL
        AND dea1.continent <> ''
order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated1
Create Table PercentPopulationVaccinated1
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated1
Select dea1.continent, dea1.location, dea1.date, dea1.population, vac1.new_vaccinations, SUM(CAST(vac1.new_vaccinations as UNSIGNED)) OVER (Partition by dea1.Location Order by dea1.location, dea1.Date) as RollingPeopleVaccinated
From PortfolioProject.covid19deaths dea1
Join PortfolioProject.covid22vac vac1
	On dea1.location = vac1.location
	and dea1.date = vac1.date
Where dea1.continent IS NOT NULL
        AND dea1.continent <> ''

Select *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated1

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea1.continent, dea1.location, dea1.date, dea1.population, vac1.new_vaccinations
, SUM(CAST(vac1.new_vaccinations as UNSIGNED)) OVER (Partition by dea1.Location Order by dea1.location, dea1.Date) as RollingPeopleVaccinated
From PortfolioProject.covid19deaths dea1
Join PortfolioProject.covid22vac vac1
	On dea1.location = vac1.location
	and dea1.date = vac1.date
Where dea1.continent IS NOT NULL
        AND dea1.continent <> ''
        
