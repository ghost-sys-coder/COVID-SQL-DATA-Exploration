SELECT * FROM
PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

SELECT * FROM
PortfolioProject..CovidVaccinations
WHERE continent is not null
ORDER BY 3, 4


--Select the data we going to be using
SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


-- CHECK THIS AND RUN IT
--Total Deaths vs Total Deaths
--Likelihood of dying if one contracts covid in Uganda

SELECT continent, location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float)) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Uganda'
and continent is not null
ORDER BY 1, 2

-- Total Cases vs Population
-- Shows the population percentage infected with COVID
SELECT continent, location, date, total_cases, population, (total_cases/population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like 'Uganda'
and continent is not null
ORDER BY 1, 2

-- Countries with the Highest COVID Infection Rate
-- TYPE CAST total_cases as an integer data type to avoid errored results
SELECT continent, location, population, MAX(CAST(total_cases as float)) as HighestInfectionCount, MAX(total_cases/population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent, location, population
ORDER BY PercentPopulationInfected desc


-- Countries with the Highest Death Rate per population
-- TYPE CAST total_deaths as integer data type to avoid errored results
SELECT continent, location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent, location
ORDER BY TotalDeathCount desc


-- BREAK THE DATA DOWN BY CONTINENT
SELECT continent, MAX(CAST(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

SELECT location, MAX(CAST(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing continents with the highest death count
SELECT 
continent, MAX(CAST(total_deaths as int)) as ContinentalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY ContinentalDeathCount desc

SELECT date, SUM(CAST(total_cases as float)) as total_cases, SUM(CAST(total_deaths as float)) as total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

SELECT 
MAX(CAST(total_cases as float)) as total_cases, 
MAX(CAST(total_deaths as float)) as total_deaths, 
SUM(CAST(total_deaths as float))/SUM(CAST(total_cases as float)) * 100 as GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--and location like 'Uganda'
--GROUP BY location
ORDER BY 1, 2



-- JOIN THE TWO TABLES
SELECT *
FROM PortfolioProject..CovidDeaths as Deaths 
JOIN PortfolioProject..CovidVaccinations as Vaccinations
ON Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
ORDER BY 2, 3

-- Total population Vs Vaccinations
-- Rolling Count for the vaccinations
SELECT 
Deaths.continent, Deaths.location, 
Deaths.date, Deaths.population, 
Vaccinations.new_vaccinations,
SUM(CONVERT(float, Vaccinations.new_vaccinations)) OVER (Partition BY Deaths.location ORDER BY Deaths.location, Deaths.date) as VaccinationRollingCount
FROM PortfolioProject..CovidDeaths as Deaths
JOIN PortfolioProject..CovidVaccinations as Vaccinations
	ON Deaths.location = Vaccinations.location
	and Deaths.date = Vaccinations.date
WHERE Deaths.continent is not null
--and Deaths.location like 'Uganda'
ORDER BY 2, 3

-- USING CTE
-- Getting the number vaccinated people by location
With PopulationVsVaccination (Continent, Location, Date, Population, New_Vaccination, VaccinationRollingCount)
as 
(
SELECT 
Deaths.continent, Deaths.location, 
Deaths.date, Deaths.population, 
Vaccinations.new_vaccinations,
SUM(CONVERT(float, Vaccinations.new_vaccinations)) OVER (Partition BY Deaths.location ORDER BY Deaths.location, Deaths.date) as VaccinationRollingCount
FROM PortfolioProject..CovidDeaths as Deaths
JOIN PortfolioProject..CovidVaccinations as Vaccinations
	ON Deaths.location = Vaccinations.location
	and Deaths.date = Vaccinations.date
WHERE Deaths.continent is not null
--ORDER BY 2, 3
)
SELECT *, (VaccinationRollingCount/Population) * 100
FROM PopulationVsVaccination



-- USING TEMP TABLE
--Percent Population Vaccinated -- This will create the same effect as the above expression
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
VaccinationRollingCount numeric
)

INSERT INTO #PercentPopulationVaccinated 
SELECT 
Deaths.continent, Deaths.location, 
Deaths.date, Deaths.population, 
Vaccinations.new_vaccinations,
SUM(CONVERT(float, Vaccinations.new_vaccinations)) OVER (Partition BY Deaths.location ORDER BY Deaths.location, Deaths.date) as VaccinationRollingCount
FROM PortfolioProject..CovidDeaths as Deaths
JOIN PortfolioProject..CovidVaccinations as Vaccinations
	ON Deaths.location = Vaccinations.location
	and Deaths.date = Vaccinations.date
WHERE Deaths.continent is not null
--ORDER BY 2, 3

SELECT *, (VaccinationRollingCount/Population) * 100 
FROM #PercentPopulationVaccinated



-- CREATING VIEWS FOR LATER DATA VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated as 
SELECT 
Deaths.continent, Deaths.location, 
Deaths.date, Deaths.population, 
Vaccinations.new_vaccinations,
SUM(CONVERT(float, Vaccinations.new_vaccinations)) OVER (Partition BY Deaths.location ORDER BY Deaths.location, Deaths.date) as VaccinationRollingCount
FROM PortfolioProject..CovidDeaths as Deaths
JOIN PortfolioProject..CovidVaccinations as Vaccinations
	ON Deaths.location = Vaccinations.location
	and Deaths.date = Vaccinations.date
WHERE Deaths.continent is not null
--ORDER BY 2, 3