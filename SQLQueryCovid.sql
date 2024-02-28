SELECT *
FROM ProjectPortifolio..Deaths
WHERE continent IS NOT NULL

SELECT
	Location,
	population,
	date,
	total_cases,
	new_cases,
	total_deaths
FROM ProjectPortifolio..Deaths
WHERE continent IS NOT NULL
ORDER BY 1, 3

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in Brazil
SELECT
	Location,
	date,
	total_cases,
	total_deaths,
	ROUND(TRY_CAST(total_deaths AS float)/TRY_CAST(total_cases AS float)*100,2) AS DeathPercentage
FROM ProjectPortifolio..Deaths
WHERE Location = 'Brazil' AND continent IS NOT NULL
ORDER BY 1, 3

-- Looking at Total Cases vs Population
-- Shows what percentage of populationg got Covid
SELECT
	date,
	Location,
	population,
	total_cases,
	ROUND((total_cases/population)*100,3) AS PercentageCases
FROM ProjectPortifolio..Deaths
WHERE continent IS NOT NULL
ORDER BY 2,3

SELECT
	Location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS MaxPercentageCases
FROM ProjectPortifolio..Deaths
WHERE continent IS NOT NULL
GROUP BY
	Location,
	population
ORDER BY
	MaxPercentageCases DESC

-- Showing Countries with Highest Death Count per Population
SELECT
	Location,
	MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM ProjectPortifolio..Deaths
WHERE continent IS NOT NULL
GROUP BY
	Location
ORDER BY
	TotalDeathsCount DESC

-- Breaking down in continents
SELECT
	continent,
	MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM ProjectPortifolio..Deaths
WHERE continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	TotalDeathsCount DESC

-- Global numbers
SELECT
	SUM(new_cases) AS TotalCases,
	SUM(CAST(new_deaths AS int)) AS TotalDeaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM
	ProjectPortifolio..Deaths
WHERE
	continent IS NOT NULL

-- Looking at Total Population vs Vaccinations
WITH PopVac (continent, Location, date, population, new_vaccinations, SumVaccinations)
AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS SumVaccinations
FROM
	ProjectPortifolio..Deaths AS dea
	JOIN ProjectPortifolio..Vaccinations AS vac
	ON dea.Location = vac.Location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
)
SELECT
	*,
	(SumVaccinations/population)*100 
FROM
	PopVac

-- Creating View to store data for later visualizations
CREATE VIEW PercentagePopulationVaccinated AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS SumVaccinations
FROM
	ProjectPortifolio..Deaths AS dea
	JOIN ProjectPortifolio..Vaccinations AS vac
	ON dea.Location = vac.Location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL