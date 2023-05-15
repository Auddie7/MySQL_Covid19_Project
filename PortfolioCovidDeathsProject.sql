--This query uses the public Covid Data to aanswere specific questions.  
--There 2 tables used, one containing new cases and deaths information, and the second one contains vaccination information.

-- I am now selecting the data I am interested in.
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioCovidProject1..CovidDeaths
order by 1, 2

-- The following query answers the question: what percentage of cases end up in death over time in Africa?
Select location, 
		date, 
		total_cases,  
		total_deaths, 
		total_deaths*100/total_cases AS deathPercentage
from PortfolioCovidProject1..CovidDeaths
where continent like '%africa%'
order by 1, 2

-- The following query answers the question: How likely were you to catch covid in the United States in any given day?
Select location, 
		date, 
		total_cases,  
		population, 
		total_cases * 100 / population AS PercentPopulationInfected
from PortfolioCovidProject1..CovidDeaths
where location like '%states%'
order by 1, 2

-- The following query answers the question: what country in the world has the highest infection rate per population?
Select location,   
		population, 
		Max(total_cases) as highestInfectionCount,
		Max(total_cases * 100 / population) AS PercentPopulationInfected
from PortfolioCovidProject1..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- The following query answers the question: Which countries had the highest death count per population?
-- I have to add a 'where' clause to filter out the rows that have a continent as a location.  I only want a country as location...
Select location,   
		Max(cast (total_deaths as int)) as TotalDeathCount,
		Max(total_deaths * 100 / population) AS PercentPopulationDeaths
from PortfolioCovidProject1..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--The following query answers the question: Which continent has lost the most people to Covid?
Select location,   
		Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioCovidProject1..CovidDeaths
where continent is null and location not like '%income%'
group by location
order by TotalDeathCount desc

--The following query answers the question: Globally and over time (per day), what were the death percentages by date?
Select date,   
		sum(new_cases) as TotalCaseCount, 
		sum(cast (new_deaths as int)) as TotalDeathCount,
		sum(cast (new_deaths as int))*100/sum(new_cases) as DeathPercentage
from PortfolioCovidProject1..CovidDeaths
where continent is not null
group by date
order by date

--The following query answers the question: Globally, what were the death percentages by date?
Select    
		sum(new_cases) as TotalCaseCount, 
		sum(cast (new_deaths as int)) as TotalDeathCount,
		sum(cast (new_deaths as int))*100/sum(new_cases) as DeathPercentage
from PortfolioCovidProject1..CovidDeaths
where continent is not null

--I will join my 2 tables to gain additional insights into the data in the query below
-- Specifically, I want the vaccination rates per population.  Because I am interested in 
-- breasking the rolling count of vaccinations by country, I am using the partition over command...
Select codea.continent, 
		codea.location, 
		codea.date, 
		codea.population, 
		coVax.new_vaccinations,
		sum(convert(bigint, coVax.new_vaccinations)) over (partition by coDea.location order by coDea.location, coDea.date) as RollinCountVax
from PortfolioCovidProject1..CovidDeaths coDea
Join PortfolioCovidProject1..CovidVaccinations coVax
on coDea.location = coVax.location 
and  coDea.date = coVax.date
Where coDea.continent is not null
 

 --  Continuing this analysis, I wanted to see what percentage of each country's population was getting vaccinated over time
-- For that, I am using a CTE that I will name percentVaxedPop

With percentVaxedPop (continent, location, date, population,new_vaccinations, RollingCountVax)
as
(
Select codea.continent, 
		codea.location, 
		codea.date, 
		codea.population, 
		coVax.new_vaccinations,
		sum(convert(bigint, coVax.new_vaccinations)) over (partition by coDea.location order by coDea.location, coDea.date) as RollinCountVax
from PortfolioCovidProject1..CovidDeaths coDea
Join PortfolioCovidProject1..CovidVaccinations coVax
on coDea.location = coVax.location 
and  coDea.date = coVax.date
Where coDea.continent is not null
)
Select continent, 
		location, 
		date, 
		population,
		new_vaccinations, 
		RollingCountVax, 
		RollingCountVax*100/population as PercentVaxed
From percentVaxedPop



 --  Continuing this analysis, I wanted to see what percentage of each country's population was getting vaccinated over time
-- For that, I am using a Temp Table that I will name percentVaxedPop2

Drop table if exists #percentVaxedPop2
Create table #percentVaxedPop2
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
People_fully_vaccinated numeric,
RollingCountVax numeric
)

Insert into #percentVaxedPop2
Select codea.continent, 
		codea.location, 
		codea.date, 
		codea.population, 
		covax.New_vaccinations,
		coVax.People_fully_vaccinated,
		sum(convert(bigint, coVax.new_vaccinations)) over (partition by coDea.location order by coDea.location, coDea.date) as RollinCountVax
from PortfolioCovidProject1..CovidDeaths coDea
Join PortfolioCovidProject1..CovidVaccinations coVax
on coDea.location = coVax.location 
and  coDea.date = coVax.date
Where coDea.continent is not null

Select continent, 
		location, 
		date, 
		population,
		people_fully_vaccinated, 
		RollingCountVax, 
		people_fully_vaccinated*100/population as PercentVaxed
From #percentVaxedPop2


-- Is there a correlation between the vaccination rates and the covid death cases in North America?

Select  codea.continent, 
		codea.location, 
		codea.date, 
		codea.population,
		codea.new_deaths, 
		codea.total_deaths, 
		coVax.people_fully_vaccinated,
		(cast (codea.new_deaths as float))*100/(cast (codea.total_deaths as float)) as PercentDeathIncrease,
		(convert(bigint, coVax.people_fully_vaccinated))*100/codea.population as PercentVaxedPop
from PortfolioCovidProject1..CovidDeaths coDea
Join PortfolioCovidProject1..CovidVaccinations coVax
on coDea.location = coVax.location 
and  coDea.date = coVax.date
where codea.continent = 'North America'



-- I am now going to create some views for use in visualizations


-- This first view represents the percentage of the population vaccinated over time
Create View percentPopVaxed1 as
Select codea.continent, 
		codea.location, 
		codea.date, 
		codea.population, 
		coVax.new_vaccinations,
		sum(convert(bigint, coVax.new_vaccinations)) over (partition by coDea.location order by coDea.location, coDea.date) as RollinCountVax
from PortfolioCovidProject1..CovidDeaths coDea
Join PortfolioCovidProject1..CovidVaccinations coVax
on coDea.location = coVax.location 
and  coDea.date = coVax.date
Where coDea.continent is not null


-- This view represents the percentage of the population that died from covid per country
Create View CountryPercentPopDeaths as
Select location,   
		Max(cast (total_deaths as int)) as TotalDeathCount,
		Max(total_deaths * 100 / population) AS PercentPopulationDeaths
from PortfolioCovidProject1..CovidDeaths
where continent is not null
group by location

-- This view represents correlation between the vaccination rates and the covid death cases in North America?

Create View VaxVsDeaths as
Select  codea.continent, 
		codea.location, 
		codea.date, 
		codea.new_deaths, 
		codea.total_deaths, 
		coVax.new_vaccinations,
		(cast (codea.new_deaths as float))*100/(cast (codea.total_deaths as float)) as PercentDeathIncrease,
		sum(convert(bigint, coVax.new_vaccinations)) over (partition by coDea.location order by coDea.location, coDea.date) as RollinCountVax
from PortfolioCovidProject1..CovidDeaths coDea
Join PortfolioCovidProject1..CovidVaccinations coVax
on coDea.location = coVax.location 
and  coDea.date = coVax.date
where codea.continent = 'North America'


