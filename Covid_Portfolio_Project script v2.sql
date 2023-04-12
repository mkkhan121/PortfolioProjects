/*

Two data sets, one is Covid_deaths and the other one Covid_vaccinations
*/


--Checking our data sets
Select * 
From Portfolioproject..Covid_deaths
order by 3,4

Select * 
from Portfolioproject..Covid_vaccinations
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..Covid_deaths
Order by 1,2

--Let's change datatypes from nvarchar to float before moving on to calculations
ALTER TABLE [dbo].[Covid_deaths]
ALTER COLUMN [total_cases] Float
GO
ALTER TABLE [dbo].[Covid_deaths]
ALTER COLUMN [total_deaths] Float
GO

--Firstly looking at countries with Highest covid cases
Select location, MAX(total_cases) as Highestcasescount
From Portfolioproject..Covid_deaths
Where continent is not null
Group by location
Order by Highestcasescount desc

--Looking at countries with Highest death count
Select location, MAX(total_deaths) as Highestdeathcount
From Portfolioproject..Covid_deaths
Where continent is not null
Group by location
Order by Highestdeathcount desc

--Let's analyse deaths and cases stats in Norway
--Total cases vs Total deaths in %
--Demonstrates the probability of dying in case of contracting COVID-19 in Norway
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
From Portfolioproject..Covid_deaths
Where location = 'Norway'
Order by 1,2

--Total cases vs Population
--Percentage of population that got covid in Norway
Select location, date, total_cases, (total_cases/population)*100 AS Casespercentage
From Portfolioproject..Covid_deaths
Where location = 'Norway'
Order by 1,2

--Moving on to look at countries globally
--Let's see countries with Highest infection rate compared to Population
Select location, population, MAX(total_cases) as Highestinfectioncount, MAX(total_cases/population)*100 AS HighestInfectionrate
From Portfolioproject..Covid_deaths
Where continent is not null
Group by location, population
Order by HighestInfectionrate desc

--Let's also see countries with Highest death rate compared to Population
Select location, Population, MAX(total_deaths) as Highestdeathcount, MAX(total_deaths/population)*100 AS Highestdeathrate
From Portfolioproject..Covid_deaths
Where continent is not null
Group by location, Population
Order by Highestdeathrate desc

--Let's see cases and death rate globally based on date
Select date, Sum(new_cases) as totalcases, Sum(new_deaths) as totaldeaths
, Sum(new_deaths)/NULLIF(Sum(new_cases), 0)* 100 as deathpercent
From Portfolioproject..Covid_deaths
Where continent is not null
Group by date
Order by 1,2

--Let's see overall cases and deaths stats globally
Select Sum(new_cases) as totalcases, Sum(new_deaths) as totaldeaths
, Sum(new_deaths)/NULLIF(Sum(new_cases), 0)* 100 as globaldeathpercentage
From Portfolioproject..Covid_deaths
Where continent is not null
Order by 1,2


--Let's check data based on continents
--Continents with Highest death count compared to population
Select continent, MAX(total_deaths) as Totaldeaths
From Portfolioproject..Covid_deaths
Where continent is not null 
Group by continent
Order by Totaldeaths desc

--Continents with most cases count per population
Select continent, MAX(total_cases) as Totalcases
From Portfolioproject..Covid_deaths
Where continent is not null
Group by continent
Order by Totalcases desc


--Join our both datasets covid deaths and vaccinations 
Select *
From Portfolioproject..Covid_deaths deaths
Join Portfolioproject..Covid_vaccinations vacc
  ON deaths.location = vacc.location
  AND deaths.date = vacc.date

  --Analysing the dataframe in depth
  --Total Population vs Vaccinations
Select deaths.Continent, deaths.Location, deaths.Date, deaths.Population, vacc.New_vaccinations
  , Sum(CAST(vacc.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location
  , deaths.date) as Cumulativevaccinated
From Portfolioproject..Covid_deaths deaths
Join Portfolioproject..Covid_vaccinations vacc
  ON deaths.location = vacc.location
  AND deaths.date = vacc.date
Where deaths.continent is not null
Order by 2,3

--Using CTE
--To see the cumulative vaccinated people in percentage terms globally
With PopvsVacc(Continent, Location, Date, Population, New_vaccinations, Cumulativevaccinated)
as
(
Select deaths.Continent, deaths.Location, deaths.Date, deaths.Population, vacc.New_vaccinations
  , Sum(CAST(vacc.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location
  , deaths.date) as Cumulativevaccinated
From Portfolioproject..Covid_deaths deaths
Join Portfolioproject..Covid_vaccinations vacc
  ON deaths.location = vacc.location
  AND deaths.date = vacc.date
Where deaths.continent is not null
)
Select *, (Cumulativevaccinated/Population) *100 as Cumulativevaccpercent
From PopvsVacc


Temp Table
--to only look for vaccinated population in Europe only
Create Table #Percentpeoplevaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cumulativevaccinated numeric
)
Insert into #Percentpeoplevaccinated
Select deaths.Continent, deaths.Location, deaths.Date, deaths.Population, vacc.New_vaccinations
  , Sum(CAST(vacc.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location
  , deaths.date) as Cumulativevaccinated
From Portfolioproject..Covid_deaths deaths
Join Portfolioproject..Covid_vaccinations vacc
  ON deaths.location = vacc.location
  AND deaths.date = vacc.date
Where deaths.continent is not null AND deaths.continent = 'Europe'

Select *, (Cumulativevaccinated/Population) *100 as Cumulativevaccpercent
From #Percentpeoplevaccinated


--Looking at countries with fully vaccinated population
Select deaths.location
  , MAX(CAST(vacc.people_fully_vaccinated as bigint)) as Fullyvaccinatedpopulation
From Portfolioproject..Covid_deaths deaths
Join Portfolioproject..Covid_vaccinations vacc
  ON deaths.location = vacc.location
Where deaths.continent is not null 
Group by deaths.location
Order by Fullyvaccinatedpopulation desc


--Looking at countries with most Booster shots administered per 100 people
Select deaths.location
  , MAX(TRY_CONVERT(bigint, vacc.total_boosters_per_hundred)) as Boostershotperhundred
From Portfolioproject..Covid_deaths deaths
Join Portfolioproject..Covid_vaccinations vacc
  ON deaths.location = vacc.location
Where deaths.continent is not null 
Group by deaths.location
Order by Boostershotperhundred desc

--Creating View in order to store data for visualizing later
Create View Percentpeoplevaccinated AS
Select deaths.Continent, deaths.Location, deaths.Date, deaths.Population, vacc.New_vaccinations
  , Sum(CAST(vacc.new_vaccinations as bigint)) OVER (Partition by deaths.location Order by deaths.location
  , deaths.date) as Cumulativevaccinated
From Portfolioproject..Covid_deaths deaths
Join Portfolioproject..Covid_vaccinations vacc
  ON deaths.location = vacc.location
  AND deaths.date = vacc.date
Where deaths.continent is not null 

Create View Globalstatistics AS
Select Sum(new_cases) as totalcases, Sum(new_deaths) as totaldeaths
, Sum(new_deaths)/NULLIF(Sum(new_cases), 0)* 100 as globaldeathpercentage
From Portfolioproject..Covid_deaths
Where continent is not null
--Order by 1,2

Create View Populationfullyvaccinated AS
Select deaths.location
  , MAX(CAST(vacc.people_fully_vaccinated as bigint)) as Fullyvaccinatedpopulation
From Portfolioproject..Covid_deaths deaths
Join Portfolioproject..Covid_vaccinations vacc
  ON deaths.location = vacc.location
Where deaths.continent is not null 
Group by deaths.location
--Order by Fullyvaccinatedpopulation desc


