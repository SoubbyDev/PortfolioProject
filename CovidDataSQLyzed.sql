USE PortfolioProject
--Data Columns that we will be working with
SELECT 
Location,date,total_cases,new_cases,total_deaths,population
FROM
PortfolioProject.. PortfolioProject.. CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--DATA EXPLORATION BY COUNTRIES 

--Exploration1: Total Cases vs Total Deaths (We will find the Case to Death Ratio by countries)

SELECT 
Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Ratio
FROM
PortfolioProject.. CovidDeaths$
WHERE Location like '%Pakistan%'

--Exploration2: Total Cases vs Population
--It shows what percentage of thePopulation has contracted COVID-19 on Daily Basis.
SELECT
Location,date,total_cases,population,(total_cases/population)*100 AS Population_Ratio
FROM
PortfolioProject.. CovidDeaths$
WHERE Location like '%Pakistan%'

--Exploration3: Countries with Highest Infection Rate compared to their Population

SELECT
Location,MAX(total_cases) AS Cases,population,MAX((total_cases/population)*100) AS Infection_Ratio
FROM
PortfolioProject.. CovidDeaths$
WHERE continent is not null
Group By
Location,population
Order By 
Infection_Ratio DESC

--Exploration4: Countries with Highest Infection Rate 

SELECT
Location,MAX(total_cases) AS Cases,population
FROM
PortfolioProject.. CovidDeaths$
WHERE continent is not null
Group By
Location,population
Order By
Cases DESC

--Exploration5: Countries with the Highest Deaths Number (Not Rate)
SELECT Location, MAX(cast(total_deaths as int)) AS Deaths
FROM
PortfolioProject.. CovidDeaths$
WHERE continent is not null
Group By 
Location
Order By
Deaths Desc

--Exploration6: Highest Deaths Count by the Population
SELECT Location,population, MAX(total_deaths) AS DeathCount, MAX((total_deaths/population)*100) AS DeathRate
FROM
PortfolioProject.. CovidDeaths$
WHERE continent is not null
Group By 
Location, population
Order By 
DeathRate DESC

--Exploration 7: Highest Number of Cases by Country.

SELECT location,MAX(cast(total_cases as int)) AS CasesNumber
FROM PortfolioProject.. CovidDeaths$
WHERE
continent is not null
Group By
location
Order By
CasesNumber DESC

--------------------------------------------------------------------------------------------------------
--DATA EXPLORATION BY CONTINENTS
--------------------------------------------------------------------------------------------------------

--Exploration7: Total Cases vs Total Deaths (We will find the Case to Death Ratio by countries)

SELECT 
continent,date,total_cases,cast(total_deaths as int) AS totalDeaths,(total_deaths/total_cases)*100 AS Ratio
FROM
PortfolioProject.. CovidDeaths$
WHERE continent like '%Europe%'

--Exploration8: Total Cases vs Population
--It shows what percentage of the Population has contracted COVID-19 on Daily Basis.
SELECT
continent,date,total_cases,population,(total_cases/population)*100 AS Population_Ratio
FROM
PortfolioProject.. CovidDeaths$
WHERE continent like '%Asia%'

--Exploration9: Continents with Highest Infection Rate

SELECT
continent,MAX(cast(total_cases as int)) AS Cases
FROM
PortfolioProject.. CovidDeaths$
Where continent is not null
Group By
continent
Order By 
Cases Desc

--Exploration10: Continents with the Highest Deaths Number (Not Rate)
SELECT continent, MAX(cast(total_deaths as int)) AS Deaths
FROM
PortfolioProject.. CovidDeaths$
WHERE continent is not null
Group By 
continent
Order By
Deaths Desc

--Exploration11: Highest Deaths Count by the Population
SELECT continent,MAX(total_deaths) AS DeathCount, MAX((total_deaths/population)*100) AS DeathRate
FROM
PortfolioProject.. CovidDeaths$
WHERE continent is not null
Group By 
continent
Order By 
DeathRate DESC 

--------------------------------------------------------------------------------------------------------
--GLOBAL DATA EXPLORATION
--------------------------------------------------------------------------------------------------------

--Exploration 14: Displaying New Cases Everyday in the World

SELECT date, SUM(new_cases) AS NewCaseEveryday
FROM 
PortfolioProject.. CovidDeaths$
Where continent is not null
Group by 
date
Order by
NewCaseEveryday ASC

--Exploration 15: Displaying New Deaths Everyday in the World

SELECT date, SUM(cast(new_deaths as float)) AS NewDeathsEveryday
FROM 
PortfolioProject.. CovidDeaths$
Where continent is not null
Group by 
date
Order by
NewDeathsEveryday ASC

--Exploration 16: Displaying New Deaths to the New Cases Ratio around the World

SELECT date, SUM(cast(new_deaths as float)) AS NewDeathsEveryday, SUM(new_cases) AS NewCases, (SUM(cast(new_deaths as float))/SUM(new_cases))*100 AS Death_To_Case_Ratio
FROM 
PortfolioProject.. CovidDeaths$
Where continent is not null
Group by 
date
Order by
1,2

--------------------------------------------------------------------------------------------------------
--JOINING COVID DEATHS + COVID VACCINATION DATA
--------------------------------------------------------------------------------------------------------

--Exploration 17: Finding Total Number of Vaccinations VS Number of Population

SELECT Death.continent, Death.date, Death.location, Vaccination.new_vaccinations,SUM(Cast(Vaccination.new_vaccinations as bigint)) OVER (Partition by Death.Location Order by Death.location,Death.date) AS totalVaccinated
FROM 
PortfolioProject.. CovidDeaths$ Death 
Join PortfolioProject..CovidVaccinations$ Vaccination 
ON 
Death.location=Vaccination.location 
AND  
Death.date=Vaccination.date
WHERE
Death.continent is not null 
AND 
Death.location like '%Albania%'
order by Death.date ASC

--Using CTE (Temporary Table)
With PopvsSac (continent, date, location, Population, totalVaccinated,new_vaccinations)
as
(	
	SELECT Death.continent,Death.date, Death.location,Death.population,SUM(CONVERT(bigint,Vaccination.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location,Death.date) AS totalVaccinated,new_vaccinations
	FROM 
		PortfolioProject.. CovidDeaths$ Death 
			Join PortfolioProject..CovidVaccinations$ Vaccination 
				ON 
					Death.location=Vaccination.location 
									AND  
					Death.date=Vaccination.date
	WHERE
		Death.continent is not null 
	
	--order by Death.date ASC
)
Select *,((totalVaccinated/Population)*100) AS PercentageVaccinated
From PopvsSac

---------------------------------
--USING A TEMP TABLE
---------------------------------
Drop Table if exists #PerPeoVaccinated
Create Table #PerPeoVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date date,
	Population numeric,
	new_vaccinations bigint,
	totalVaccinated numeric


)
Insert into #PerPeoVaccinated
SELECT Death.continent,Death.date, Death.location,Death.population,SUM(CONVERT(bigint,Vaccination.new_vaccinations)) OVER (Partition by Death.Location Order by Death.location,Death.date) AS totalVaccinated,new_vaccinations
	FROM 
		PortfolioProject.. CovidDeaths$ Death 
			Join PortfolioProject..CovidVaccinations$ Vaccination 
				ON 
					Death.location=Vaccination.location 
									AND  
					Death.date=Vaccination.date
	WHERE
		Death.continent is not null 
	
	--order by Death.date ASC

Select *,((totalVaccinated/Population)*100) AS PercentageVaccinated
From #PerPeoVaccinated

-----------------------------------------------
--Creating Views for Visualizations
----------------------------------------------
Create View NewTabless as
Select Location,MAX(total_cases) AS Cases,population,MAX((total_cases/population)*100) AS Infection_Ratio
FROM
PortfolioProject.. CovidDeaths$
WHERE continent is not null
Group By
Location,population
