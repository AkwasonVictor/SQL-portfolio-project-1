SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total cases vs Total death (death percentage)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentages
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2


--looking at total cases vs population (percentage of population with covid) 

SELECT Location, date, total_cases, population, (total_cases/population)*100 as percentage_population_with_covid
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at countries with higest infection rate compared to population

SELECT Location, population, MAX(total_cases) as highest_infection_count, (MAX(total_cases)/population)*100 as percentage_population_with_covid
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, population
ORDER BY percentage_population_with_covid desc

--Countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY highest_death_count desc

--Showing continent with highest death count

SELECT continent, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY highest_death_count desc

--Global Numbers

SELECT SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentages
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total population vs vaccination

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, sum(cast(Vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..Covidvaccinations as Vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--creating Temp Table

DROP Table if exists #percentagepopulationvaccinated
Create Table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)

INSERT INTO #percentagepopulationvaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, sum(cast(Vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..Covidvaccinations as Vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (Rolling_people_vaccinated/population)*100
FROM #percentagepopulationvaccinated


--Creating view to store data for later visualization

Create view percentagepopulationvaccinated as
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, sum(cast(Vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..Covidvaccinations as Vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null


Create view continent_with_highest_death_count as
SELECT continent, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent


Create view percentageofpopulationwithcovid as
SELECT Location, date, total_cases, population, (total_cases/population)*100 as percentage_population_with_covid
FROM PortfolioProject.dbo.CovidDeaths