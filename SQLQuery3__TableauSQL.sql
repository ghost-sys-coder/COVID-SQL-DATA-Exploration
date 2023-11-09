-- SQL QUERIES FOR TABLEAU 


--SELECTING ALL DATA 
SELECT * 
FROM [Portfolio Project]..COVID_DEATHS;

-- FINDING THE GLOBAL DEATH PERCENTAGE  --TABLE ONE
SELECT SUM(new_cases) as Total_New_Cases, SUM(CAST(new_deaths as int)) as Total_New_Deaths, (SUM(CONVERT(int, new_deaths))/SUM(new_cases)) * 100 as DeathPercentage
FROM [Portfolio Project]..COVID_DEATHS
--WHERE location like '%uganda%'
WHERE continent is not NULL
ORDER BY 1,2;

--FINDING THE CONTINENTAL CORONAVIRUS DEATH PERCENTAGE
SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases) * 100) as ContinentalDeathPercentage
FROM [Portfolio Project]..COVID_DEATHS
WHERE continent like '%north america%' --CHANGE CONTINENT TO FIND THE ANY CONTINENTAL DEATH PERCENTAGE 
ORDER BY 1, 2;

--FINDING THE DEATH PERCENTAGE AT COUNTRY LEVEL
SELECT location, SUM(new_cases) as Total_New_Cases, SUM(CAST(new_deaths as int)) as Total_New_Deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases)) * 100 as CountryDeathPercentage
FROM [Portfolio Project]..COVID_DEATHS
WHERE location like '%brazil%' -- SET YOUR OWN LOCATION
AND continent is not NULL
GROUP BY location
ORDER BY 1,2;

--FINDING THE TOTAL DEATH COUNT FOR EACH COUNTRY --TABLE TWO
SELECT location, continent,SUM(CONVERT(int, new_deaths)) as TotalDeathCount
FROM [Portfolio Project]..covid_deaths
WHERE continent IS NOT NULL
AND location NOT IN ('World', 'European', 'International')
GROUP BY location, continent
ORDER BY TotalDeathCount DESC;

--FINDING THE MAXIMUM NUMBER OF CASES IN EACH COUNTRY--TABLE THREE
SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population) * 100) as HighestInfectionRate
FROM [Portfolio Project]..covid_deaths
--WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestInfectionRate DESC;

--FINDING THE NUMBER OF CASES IN EACH COUNTRY -- TABLE FOUR
SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population) * 100) as HighestInfectionRate
FROM [Portfolio Project]..covid_deaths
GROUP BY location, population, date
ORDER BY HighestInfectionRate DESC;



--OTHER QUERIES TO TEST OUT -- JOIN THE COVID DEATHS AND VACCINATIONS
SELECT dea.continent, dea.location, dea.population, dea.date, MAX(total_vaccinations) as TotalVaccinations
FROM [Portfolio Project]..covid_deaths as dea
JOIN [Portfolio Project]..covid_vaccinations as vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent ,dea.location, dea.date, dea.population
ORDER BY 1,2,3;