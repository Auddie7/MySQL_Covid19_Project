# MySQL Project: Analysis ov worldwide dataset on CoVid 19 cases using SQL queries to answer relevant questions

## Project Overview

**Project Title**: CoVid 19 Data Analysis  
**Database**: `covid_analysis`

Through this project I will demonstrate my SQL skills and techniques to explore, clean, and analyze a large dataset containing information on worldwide cases.z. I will be setting up a database, performing exploratory data analysis, and answering specific questions and then creating views for visualization through SQL queries.

## Objectives

1. **Set up a database**: Create and populate a a covid database with the provided dataset and populate it with relevant tables.
2. **Data Cleaning**: Identify columns needed for analysis and creating relevant tables with the data.
3. **Exploratory Data Analysis**: Perform exploratory data analysis to understand the dataset.
4. **Visualisation**: Use SQL to create views that will help visualize the specific questions.

## Project Structure

### 1. Database Setup

- **Database Creation**: I start out by by creating a database named `covid_analysis`.
- **Table Creation**: A table named `coviddeaths` and one called `covidvaccinations` are imported with relevant information using the table import wizard.

```sql
CREATE DATABASE coviddeaths;

;
```
- **Columns Selection**: I am now selecting the data I am interested in.

```sql
Select location, date, total_cases, new_cases, total_deaths, population
from covid_analysis.CovidDeaths
order by 1, 2.
;
```

### 2. Exploratory Data Analysis Using One Table

- **Africa**: The following query answers the question: what percentage of cases end up in death over time in Africa?
```sql
Select location, 
		date, 
		total_cases,  
		total_deaths, 
		round(total_deaths*100/total_cases, 2) AS deathPercentage
from covid_analysis.CovidDeaths
where continent like '%africa%'
order by 1, 2

;
```
- **United States**: The following query answers the question: How likely are you to catch covid in the United States in any given day?
```sql
Select location, 
		date, 
		total_cases,  
		population
        -- ,round(total_cases * 100/population, 2) AS PercentPopulationInfected
from covid_analysis.CovidDeaths
where location like '%States%'
order by 1, 2

;
```

- **Highest Rate**: The following query answers the question: what countries in the world have the top 3 highest infection rate per population?
```sql
Select location,   
		population, 
		Max(total_cases) as highestInfectionCount,
		Max(total_cases * 100 / population) AS PercentPopulationInfected
from covid_analysis.CovidDeaths
group by location, population
order by PercentPopulationInfected desc
limit 3
;
```

- **Highest Death Count**: The following query answers the question: Which countries had the highest death count per population? I have to add a 'where' clause to filter out the rows that have a continent as a location.  I only want a country as location.
```sql
Select location,   
		Max(cast (total_deaths as int)) as TotalDeathCount,
		Max(total_deaths * 100 / population) AS PercentPopulationDeaths
from covid_analysis.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc
;
```
- **Percentage Over Time**: The following query answers the question: Globally and over time (per day), what were the death percentages by date?
```sql
Select date,   
		sum(new_cases) as TotalCaseCount, 
		sum(cast (new_deaths as int)) as TotalDeathCount,
		sum(cast (new_deaths as int))*100/sum(new_cases) as DeathPercentage
from covid_analysis.CovidDeaths
where continent is not null
group by date
order by date
;
```
- **Percentage Per date**:  The following query answers the question: Globally, what were the death percentages by date?
```sql
Select    
		sum(new_cases) as TotalCaseCount, 
		sum(cast (new_deaths as int)) as TotalDeathCount,
		sum(cast (new_deaths as int))*100/sum(new_cases) as DeathPercentage
from covid_analysis.CovidDeaths
where continent is not null
;
```
### 3. Exploratory Data Analysis Using More Than One Table


- **Vaccination Roling Counts**:  In the following querey, I will join my 2 tables to gain additional insights into the data in the query below. Specifically, I want the vaccination rates per population.  Because I am interested in breaking the rolling count of vaccinations by country, I am using the partition over command.

```sql
Select codea.continent, 
		codea.location, 
		codea.date, 
		codea.population, 
		coVax.new_vaccinations,
		sum(convert(bigint, coVax.new_vaccinations)) over (partition by coDea.location order by coDea.location, coDea.date) as RollinCountVax
from covid_analysis.CovidDeaths coDea
Join covid_analysis.CovidVaccinations coVax
on coDea.location = coVax.location 
and  coDea.date = coVax.date
Where coDea.continent is not null

;
```
- **Vaccination Rates**:  Continuing this analysis, I wanted to see what percentage of each country's population was getting vaccinated over time.  For that, I am using a CTE that I will name percentVaxedPop
```sql
ith percentVaxedPop (continent, location, date, population,new_vaccinations, RollingCountVax)
as
(
Select codea.continent, 
		codea.location, 
		codea.date, 
		codea.population, 
		coVax.new_vaccinations,
		sum(convert(bigint, coVax.new_vaccinations)) over (partition by coDea.location order by coDea.location, coDea.date) as RollinCountVax
from covid_analysis.CovidDeaths coDea
Join covid_analysis.CovidVaccinations coVax
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

;
```
- **Vaccination Rolling Counts**:  The followingI will join my 2 tables to gain additional insights into the data in the query below. Specifically, I want the vaccination rates per population.  Because I am interested in breaking the rolling count of vaccinations by country, I am using the partition over command.

```sql
Select codea.continent, 
		codea.location, 
		codea.date, 
		codea.population, 
		coVax.new_vaccinations,
		sum(convert(bigint, coVax.new_vaccinations)) over (partition by coDea.location order by coDea.location, coDea.date) as RollinCountVax
from covid_analysis.CovidDeaths coDea
Join covid_analysis.CovidVaccinations coVax
on coDea.location = coVax.location 
and  coDea.date = coVax.date
Where coDea.continent is not null

;
```
- **Vaccination Per Country**:  Continuing this analysis, I wanted to see what percentage of each country's population was getting vaccinated over time. For that, I am using a Temp Table that I will name percentVaxedPop2

```sql
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
from covid_analysis.CovidDeaths coDea
Join covid_analysis.CovidVaccinations coVax
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

;
```
- **Vaccination Correlation**:  Is there a correlation between the vaccination rates and the covid death cases in North America?

```sql
Select  codea.continent, 
		codea.location, 
		codea.date, 
		codea.population,
		codea.new_deaths, 
		codea.total_deaths, 
		coVax.people_fully_vaccinated,
		(cast (codea.new_deaths as float))*100/(cast (codea.total_deaths as float)) as PercentDeathIncrease,
		(convert(bigint, coVax.people_fully_vaccinated))*100/codea.population as PercentVaxedPop
from covid_analysis.CovidDeaths coDea
Join covid_analysis.CovidVaccinations coVax
on coDea.location = coVax.location 
and  coDea.date = coVax.date
where codea.continent = 'North America'


;
```
### 4. Views For Visualization


- **Vaccination View**:  I am now going to create some views for use in visualizations. This first view represents the percentage of the population vaccinated over time.

```sql
Create View percentPopVaxed1 as
Select codea.continent, 
		codea.location, 
		codea.date, 
		codea.population, 
		coVax.new_vaccinations,
		sum(convert(bigint, coVax.new_vaccinations)) over (partition by coDea.location order by coDea.location, coDea.date) as RollinCountVax
from covid_analysis.CovidDeaths coDea
Join covid_analysis.CovidVaccinations coVax
on coDea.location = coVax.location 
and  coDea.date = coVax.date
Where coDea.continent is not null

;
```
- **Deaths View**:  This view represents the percentage of the population that died from covid per country.

```sql
Create View CountryPercentPopDeaths as
Select location,   
		Max(cast (total_deaths as int)) as TotalDeathCount,
		Max(total_deaths * 100 / population) AS PercentPopulationDeaths
from covid_analysis.CovidDeaths
where continent is not null
group by location

;
```

- **Correlation View**:  This view represents correlation between the vaccination rates and the covid death cases in North America
```sql
Create View VaxVsDeaths as
Select  codea.continent, 
		codea.location, 
		codea.date, 
		codea.new_deaths, 
		codea.total_deaths, 
		coVax.new_vaccinations,
		(cast (codea.new_deaths as float))*100/(cast (codea.total_deaths as float)) as PercentDeathIncrease,
		sum(convert(bigint, coVax.new_vaccinations)) over (partition by coDea.location order by coDea.location, coDea.date) as RollinCountVax
from covid_analysis.CovidDeaths coDea
Join covid_analysis.CovidVaccinations coVax
on coDea.location = coVax.location 
and  coDea.date = coVax.date
where codea.continent = 'North America'
;
```
