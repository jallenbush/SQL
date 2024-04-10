SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--select data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--total cases vs total deaths
--data type conversion

SELECT location, date, total_cases, total_deaths,
	CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--total cases vs population
--percentage of infected

SELECT location, date, population, total_cases, 
	CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0) * 100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--countries infection rate vs population

SELECT location, population, MAX(total_cases) AS HighestInfected, 
	MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population 
ORDER BY InfectedPercentage DESC

--break data down by continent
SELECT continent, MAX(CONVERT(int, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC

--correct numbers from the above
SELECT location, MAX(CONVERT(int, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC

--countries death count per population
SELECT location, MAX(CONVERT(int, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC

--global numbers

SELECT date, SUM(CONVERT(int, new_cases)) AS TotalCases, SUM(CONVERT(int, new_deaths)) AS TotalDeaths,
	SUM(CONVERT(float, new_cases))/SUM(CONVERT(float, new_deaths)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2


--simple join

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


--total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent LIKE '%north%'
ORDER BY 1,2,3

--

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location,
	dea.date) AS PeopleVaccinated,
	(PeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

--Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location,
	dea.date) AS PeopleVaccinated
--, (PeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (PeopleVaccinated/population)*100 AS VaccinatedByPopulation
FROM PopvsVac


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vacciantions bigint,
PeopleVaccinated bigint
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location,
	dea.date) AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

SELECT *, (PeopleVaccinated/population)*100 AS VaccinatedByPopulation
FROM #PercentPopulationVaccinated

--create view to store data for later visualzations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location,
	dea.date) AS PeopleVaccinated
--, (PeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

--more views
CREATE VIEW TotalDeathCount AS
SELECT location, MAX(CONVERT(int, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
--ORDER BY TotalDeathCount DESC

--more views
CREATE VIEW InfectedPercentage AS
SELECT location, date, population, total_cases, 
	CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0) * 100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
--ORDER BY 1,2




