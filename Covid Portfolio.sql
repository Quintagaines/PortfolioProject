
--Select *
--From PortfolioProject..CovidDeath
--order by 3,4

--Select *
--From PortfolioProject..Covidvaccinations
--order by 3,4
---Select Data that we are going to be using

--Select location, date, total_cases, new_cases,total_deaths, population
--From PortfolioProject..CovidDeath
--order by 1,2

----Looking at Total Cases vs Total Death
---Shows likelihood of dying if you contract Covid in your Country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..CovidDeath
Where location like '%states%'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid
Select location, date, population,total_cases,
(CONVERT(float, population) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS PercentpopulationInfected
from PortfolioProject..CovidDeath
Where location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
--Select location, population,total_cases,
--MAX(CONVERT(float, population) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Percentage
--from PortfolioProject..CovidDeath
--Where location like '%states%'
--order by 1,2


SELECT location, population,
       MAX(total_cases) OVER (PARTITION BY location) AS HighestInfectionCount,
       MAX((total_cases / NULLIF(population, 0))) OVER (PARTITION BY location) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeath
--WHERE location LIKE '%states%'
ORDER BY HighestInfectionCount DESC, PercentPopulationInfected DESC  -- Order by descending infection metrics
;

---LET BREAKDOWN BY CONTINTENT
SELECT continent, MAX(Total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

---Showing Countries with the Highest Death Count per population
SELECT Location, MAX(Total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;


---Global Numbers

--Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_Cases) * 100 as DeathPercentage
--From PortfolioProject..CovidDeath
----Where location like '%states%'
--where continent is not null
--Group by date
--order by 1,2

SELECT
    location,
    SUM(new_cases) AS TotalNewCases,
    SUM(CAST(new_deaths AS int)) AS TotalNewDeaths,
    SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM
    PortfolioProject..CovidDeath
--WHERE location --WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

-- Looking at Total Population vs Vaccinations

-- Looking at Total Population vs Vaccinations

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(COALESCE(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) 
	AS RollingPeopleVaccinated
	(RollingPeopleVaccinated/population)*100
FROM
    PortfolioProject..CovidDeath dea
JOIN
    PortfolioProject..Covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE

    dea.continent IS NOT NULL
ORDER BY
    dea.location,
    dea.date;



-- Common Table Expression (CTE)
WITH PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(COALESCE(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) 
            AS RollingPeopleVaccinated
    FROM
        PortfolioProject..CovidDeath dea
    JOIN
        PortfolioProject..Covidvaccinations vac 
        ON dea.location = vac.location 
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
-- Main query
SELECT
    Continent,
    Location,
    Date,
    Population,
    New_Vaccinations,
    RollingPeopleVaccinated,
    (RollingPeopleVaccinated / NULLIF(Population, 0)) * 100 AS VaccinationPercentage
FROM
    PopsVac
ORDER BY
    Location,
    Date;


---- Drop the existing view if it exists

--IF OBJECT_ID('dbo.PercentPopulationVaccinated', 'V') IS NOT NULL
--BEGIN
--    EXEC('DROP VIEW dbo.PercentPopulationVaccinated');
--END;

-- Create the view
--CREATE VIEW dbo.PercentPopulationVaccinated AS
--SELECT
--    dea.continent,
--    dea.location,
--    dea.date,
--    dea.population,
--    vac.new_vaccinations,
--    SUM(COALESCE(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location ORDER BY dea.date) 
--    AS RollingPeopleVaccinated
--FROM
--    PortfolioProject..CovidDeath dea
--JOIN
--    PortfolioProject..Covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
--WHERE
--    dea.continent IS NOT NULL;


Select *
From PercentPopulationVaccinated

