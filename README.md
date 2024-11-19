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
- **Table Creation**: I am now selecting the data I am interested in.

```sql
Select location, date, total_cases, new_cases, total_deaths, population
from covid_analysis.CovidDeaths
order by 1, 2.
;
```
