# Data Analysis
# Portfolio Project - 1 - SQL
# Analyzing the dataset downloaded from https://ourworldindata.org/covid-deaths

show databases;
create database CovidDB;
USE CovidDB;

## --------------------------------------------------------------------------------------------------------------------
## Method that didn't work to import csv file into MySal table
   -- From the Table data import wizard, chose the file and selected the desired columns for table 1
   -- Started importing but taking too much of time. Only 300 records in 30 mins. Theres are more than 300000 rows :(
   -- Doesnt seem to be the right option
   -- Only 550 rows downloaded overnight
   -- Found there is some datatype mismatch
   -- Wrongly assumed that the datatype mismatch is because of the header row. Thought that it is taken as the first row
   -- Found that the first row is the header row which is used to name the columns
   -- Datatype mismatch is because, some columns' type are double, but there is no data in some cells
   -- Set the datatype of all columns as text
   -- Now there is no error, but the table takes a lot a time to import
   -- Found that load data infile will work faster
   -- Tried it -> Error 3948 Loading local data is disabled; this must be enabled on both the client and server sides
   -- From mysql CLI tried "SET GLOBAL local_infile = true"
   
   -- Tried Load Data query again. 
   --	LOAD DATA LOCAL INFILE 
   --		'C:/Users/Rajesh/Desktop/heleena/dataAnalytics/portfolio projects/sql/owid-covid-data.csv'
   --	INTO TABLE
   --		`owid-covid-data`
   --	FIELDS TERMINATED BY ','
   --	LINES TERMINATED BY '\r\n';
   --   Now the error is 
   --		Error Code: 2068. LOAD DATA LOCAL INFILE file request rejected due to restrictions on access.
   
   --	Removed LOCAL Keyword. Now the error is 
   --     	Error Code: 1290. The MySQL server is running with the --secure-file-priv option so it cannot execute this statement
 ## ----------------------------------------------------------------------------------------------------------------------------------  
   --   Finally this worked 
   --   ******************* 
		-- 1. Show hidden files in windows
		-- 2. Find my.ini
		-- 3. In my.ini --secure-file-priv was set to C:/ProgramData/MySQL/MySQL Server 8.0/Uploads
		-- 4. Copy our csv file to folder C:/ProgramData/MySQL/MySQL Server 8.0/Uploads
		-- 5. Now use the following query. Takes less than a minute
		-- LOAD DATA INFILE 
		--	'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/owid-covid-data.csv'
		-- INTO TABLE `owid-covid-data`
		-- FIELDS TERMINATED BY ','
		-- IGNORE 474 LINES;
		-- (***I already uploaded the header line and 473 rows using Import Table Data wizard which took a lot of time)
		
		-- May be, there are better solutions. Should find them out in due course
 ## ------------------------------------------------------------------------------------------------------------------------------------------

-- To check what is there in the dataset
SELECT * 
FROM `owid-covid-data`
LIMIT 0, 10000;

-- How many rows are there?
SELECT COUNT(*) 
FROM `owid-covid-data`;

-- Populate the table with the dataset
LOAD DATA INFILE 
	'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/owid-covid-data.csv'
INTO TABLE
	`owid-covid-data`
FIELDS TERMINATED BY ','
IGNORE 474 LINES;

-- Create a new table from owid-covid-data table with the fields related to CovidDeaths 
CREATE TABLE CovidDeaths( 
	iso_code VarChar(50),
	continent VarChar(100),
    location VarChar(100),
    DateOfObservation date,
    population BigInt,
    total_cases BigInt,
    new_cases BigInt,
    new_cases_smoothed Int,
    total_deaths BigInt,
    new_deaths Int,
    new_deaths_smoothed Int,
    total_cases_per_million Double,
    new_cases_per_million Double,
    new_cases_smoothed_per_million Double,
    total_deaths_per_million Double,
    new_deaths_per_million Double,
    new_deaths_smoothed_per_million Double,
    reproduction_rate Double,
    icu_patients BigInt,
    icu_patients_per_million Double,
    hosp_patients BigInt,
    hosp_patients_per_million Double,
    weekly_icu_admissions BigInt,
    weekly_icu_admissions_per_million Double,
    weekly_hosp_admissions BigInt,
    weekly_hosp_admissions_per_million Double
);

DELETE FROM coviddeaths;


-- Populate the CovidDeaths table with the data from owid-covid-data
INSERT INTO CovidDeaths 
SELECT iso_code,continent,location,date,
	   IF(population='', 0, population),	
	   IF(total_cases='', 0, total_cases),
       IF(new_cases='',0, new_cases),
       IF(new_cases_smoothed='',0, new_cases_smoothed),
       IF(total_deaths='',0, total_deaths),
       IF(new_deaths='',0, new_deaths),
       IF(new_deaths_smoothed='',0, new_deaths_smoothed),
       IF(total_cases_per_million='',0, total_cases_per_million),
       IF(new_cases_per_million='',0, new_cases_per_million),
       IF(new_cases_smoothed_per_million='',0, new_cases_smoothed_per_million),
       IF(total_deaths_per_million='', 0, total_deaths_per_million),
       IF(new_deaths_per_million='',0,new_deaths_per_million),
       IF(new_deaths_smoothed_per_million='',0, new_deaths_smoothed_per_million),
       IF(reproduction_rate='',0, reproduction_rate),
       IF(icu_patients='',0, icu_patients),
       IF(icu_patients_per_million='',0, icu_patients_per_million),
       IF(hosp_patients='',0, hosp_patients),
       IF(hosp_patients_per_million='',0, hosp_patients_per_million),
       IF(weekly_icu_admissions='',0, weekly_icu_admissions),
       IF(weekly_icu_admissions_per_million='',0, weekly_icu_admissions_per_million),
       IF(weekly_hosp_admissions='',0, weekly_hosp_admissions),
       IF(weekly_hosp_admissions_per_million='',0, weekly_hosp_admissions_per_million)
FROM `owid-covid-data`;


-- Create another table from owid-covid-data table with the fields related to CovidVacciations
CREATE TABLE CovidVaccinations( 
	iso_code VarChar(50),
	continent VarChar(100),
    location VarChar(100),
    DateOfObservation date,
    population BigInt,	
	
    total_tests BigInt,
    new_tests BigInt,
    total_tests_per_thousand Double,
    new_tests_per_thousand Double,
    new_tests_smoothed BigInt,
  
    new_tests_smoothed_per_thousand Double,
    positive_rate Double,
    tests_per_case Double, 
    new_cases_smoothed_per_million Double,
    tests_units VarChar(100),
    
    total_vaccinations BigInt,    
    people_vaccinated BigInt,
    people_fully_vaccinated BigInt,
    total_boosters  BigInt,
    
    new_vaccinations BigInt,    
    new_vaccinations_smoothed BigInt,    
    total_vaccinations_per_hundred Double,
    people_vaccinated_per_hundred Double,
    people_fully_vaccinated_per_hundred Double,
    
    total_boosters_per_hundred Double,    
    new_vaccinations_smoothed_per_million Double,    
    new_people_vaccinated_smoothed Double,
    new_people_vaccinated_smoothed_per_hundred Double,
    stringency_index Double,
    
    population_density Double,    
    median_age Double,    
    aged_65_older Double,
    aged_70_older Double,
    gdp_per_capita Double,
    
    extreme_poverty Double,    
    cardiovasc_death_rate Double,    
    diabetes_prevalence Double,
    female_smokers Double,
    male_smokers Double,
    
    handwashing_facilities Double,    
    hospital_beds_per_thousand Double,    
    life_expectancy Double,
    human_development_index Double,
    excess_mortality_cumulative_absolute Double,
    
    excess_mortality_cumulative Double,
    excess_mortality Double,    
    excess_mortality_cumulative_per_million Double
);    
    
    
-- Populate the CovidVaccinations table with the data from owid-covid-data
INSERT INTO CovidVaccinations 
SELECT iso_code,
	   continent,
       location,
       date,
       
	   IF(total_tests='', 0, total_tests),
       IF(new_tests='',0, new_tests),
       IF(total_tests_per_thousand='',0, total_tests_per_thousand),
       IF(new_tests_per_thousand='',0, new_tests_per_thousand),
       IF(new_tests_smoothed='',0, new_tests_smoothed),
       
       IF(new_tests_smoothed_per_thousand='',0, new_tests_smoothed_per_thousand),
       IF(positive_rate='',0, positive_rate),
       IF(tests_per_case='',0, tests_per_case),
       IF(new_cases_smoothed_per_million='',0, new_cases_smoothed_per_million),
       tests_units,
         
       IF(total_vaccinations='',0,total_vaccinations),
       
       IF(people_vaccinated='',0, people_vaccinated),
       IF(people_fully_vaccinated='',0, people_fully_vaccinated),
	   IF(total_boosters='',0, total_boosters),
       
       IF(new_vaccinations='',0, new_vaccinations),
       IF(new_vaccinations_smoothed='',0, new_vaccinations_smoothed),
       IF(total_vaccinations_per_hundred='',0, total_vaccinations_per_hundred),
       IF(people_vaccinated_per_hundred='',0, people_vaccinated_per_hundred),
       IF(people_fully_vaccinated_per_hundred='',0, people_fully_vaccinated_per_hundred),
       
       IF(total_boosters_per_hundred='',0, total_boosters_per_hundred),
       IF(new_vaccinations_smoothed_per_million='',0, new_vaccinations_smoothed_per_million),
       IF(new_people_vaccinated_smoothed='',0, new_people_vaccinated_smoothed),
       IF(new_people_vaccinated_smoothed_per_hundred='',0, new_people_vaccinated_smoothed_per_hundred),
	   IF(stringency_index='',0, stringency_index),
       
       IF(population_density='',0, population_density),
       IF(median_age='',0, median_age),
       IF(aged_65_older='',0, aged_65_older),
	   IF(aged_70_older='',0, aged_70_older),
       IF(gdp_per_capita='',0, gdp_per_capita),
       
       IF(extreme_poverty='',0, extreme_poverty),
       IF(cardiovasc_death_rate='',0, cardiovasc_death_rate),
       IF(diabetes_prevalence='',0, diabetes_prevalence),
       IF(female_smokers='',0, female_smokers),
       IF(male_smokers='',0, male_smokers),
       
       IF(handwashing_facilities='',0, handwashing_facilities),
       IF(hospital_beds_per_thousand='',0, hospital_beds_per_thousand),
       IF(life_expectancy='',0,life_expectancy),
       IF(human_development_index='',0, human_development_index),
       IF(excess_mortality_cumulative_absolute='',0, excess_mortality_cumulative_absolute),
       
       IF(excess_mortality_cumulative='',0, excess_mortality_cumulative),
	   IF(excess_mortality='',0, excess_mortality),
       IF(excess_mortality_cumulative_per_million='',0, excess_mortality_cumulative_per_million)
FROM `owid-covid-data`;

-- Random check
Select * from `owid-covid-data`
Limit 20000;    
    
SELECT * FROM coviddeaths
ORDER BY 3,4 DESC;

Select * from CovidVaccinations
ORDER BY 3,4 DESC;

## -- Select Data that we are going to use
## *****************************************

SELECT Location, DateOfObservation, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2
LIMIT 0, 310000;

## -- Total Cases Vs Total Deaths in Percentage
## Shows the chances of death in affected people on a particular date in India
SELECT Location, DateOfObservation, total_cases, total_deaths, (total_deaths/total_cases) * 100 as 'PercentfDeathInAffectedPeople'
FROM CovidDeaths
WHERE Location = 'India'
ORDER BY PercentfDeathInAffectedPeople DESC
LIMIT 310000;

## -- Total Cases Vs Population 
SELECT Location, DateOfObservation, Population, Total_Cases,  (total_cases/population)*100 as PercentageOfPeopleAffected
FROM CovidDeaths
WHERE Location = 'India'
LIMIT 310000;

## -- Which country is most affected
SELECT Location, Population, max(total_cases) AS Total_Infected, max((total_cases/population))*100 AS 'PercentOfPopulationInfected'
FROM CovidDeaths
WHERE continent <> '' ##To prevent world, continent-wise and HighIncome categories from showing up 
GROUP BY Location, Population 
ORDER BY PercentOfPopulationInfected DESC;

## -- Total Deaths - country-wise 
SELECT location, max(total_deaths) AS TotalDeath
FROM CovidDeaths
WHERE continent <> ''
GROUP BY location
ORDER BY  TotalDeath DESC;

## -- Total Deaths in Continents
SELECT location AS Continent, max(total_deaths) as TotalDeath
FROM CovidDeaths
WHERE continent = '' and location in ('Asia', 'Aftica', 'Europe', 'North America', 'South America', 'Oceania')
GROUP BY location
ORDER BY TotalDeath DESC;

## -- Global numbers data-wise
SELECT dateOfObservation as Date, sum(new_cases) as NewCases, sum(new_deaths) as NewDeaths, sum(new_deaths)/sum(new_cases) * 100 as DeathPercentile
FROM CovidDeaths
WHERE continent <> ''
GROUP BY dateOfObservation
ORDER BY dateOfObservation DESC
LIMIT 310000;

## -- Global numbers
SELECT sum(new_cases) AS TotalCases, sum(new_deaths) AS TotalDeaths, 
 	   sum(new_deaths)/sum(new_cases)*100 as DeathPercentageIfAffected
FROM CovidDeaths
WHERE continent <> ''; 
## -- 763754828 6915095 0.9054

## -- Death - Global population-wise
SELECT Max(Population) as Population, Max(Total_cases) as TotalCases, Max(total_deaths) as TotalDeaths,
		Max(total_deaths)/ Max(Total_cases) * 100 AS DeathPercentageIfAffected,
        Max(total_deaths)/Max(Population) * 100 AS DeathPercentageWorldwide
FROM CovidDeaths 
WHERE location = 'World'; 
## -- 7975105024	763739376	6908541	0.9046	0.0866

-- Date when the cases are maximum 
-- Change new_cases to new_deaths to find when the deaths are maximum
SELECT DateOfObservation, Sum(new_cases) NewCases
FROM CovidDeaths
WHERE continent <> ''
Group By DateOfObservation
ORDER BY NewCases DESC
LIMIT 1; # '2022-12-22', '7460688'
#LIMIT 310000; --To retreive the data for all dates


# -- Alternate query
SELECT DateOfObservation, new_cases as NewCases
FROM CovidDeaths
WHERE location = 'World'
ORDER BY NewCases DESC
LIMIT 1;  # '2022-12-22', '7460688'

## -- No of cases each year
SELECT DISTINCT year(DateOfObservation) AS Year, sum(new_cases) OVER (PARTITION BY year(DateOfObservation)) AS TotalCases
FROM CovidDeaths 
LIMIT 310000;

# -- Year, TotalCases
-- '2020', '347139937'
-- '2021', '856322609'
-- '2022', '1906621328'
-- '2023', '127339157'


## -- Deaths year-wise
SELECT DISTINCT year(DateOfObservation) AS Year, sum(new_deaths) OVER (PARTITION BY year(DateOfObservation)) AS TotalDeaths
FROM CovidDeaths 
LIMIT 310000;
-- #Year, TotalDeaths
-- '2020', '8178845'
-- '2021', '14643981'
-- '2022', '5245911'
-- '2023', '813278'

## -- Deaths - month-wise
SELECT year(DateOfObservation) as Year, monthname(DateOfObservation) as Month, 
		sum(new_deaths) AS TotalDeaths 
FROM CovidDeaths
GROUP BY year(DateOfObservation), monthname(DateOfObservation)
ORDER BY Year DESC;
-- # Year, Month, TotalDeaths
-- '2023', 'April', '43057'
-- '2023', 'February', '165854'
-- '2023', 'January', '495880'
-- '2023', 'March', '108487'
-- '2022', 'April', '364151'
-- '2022', 'August', '300452'
-- '2022', 'December', '321870'
-- '2022', 'February', '1176079'
-- '2022', 'January', '1030093'
-- '2022', 'July', '284867'
-- '2022', 'June', '177646'
-- '2022', 'March', '783061'
-- '2022', 'May', '210887'
-- '2022', 'November', '182890'
-- '2022', 'October', '212149'
-- '2022', 'September', '201766'
-- '2021', 'April', '1562992'
-- '2021', 'August', '1241007'
-- '2021', 'December', '927573'
-- '2021', 'February', '1284902'
-- '2021', 'January', '1831729'
-- '2021', 'July', '1081539'
-- '2021', 'June', '1089485'
-- '2021', 'March', '1198138'
-- '2021', 'May', '1566795'
-- '2021', 'November', '916977'
-- '2021', 'October', '896727'
-- '2021', 'September', '1046117'
-- '2020', 'April', '893788'
-- '2020', 'August', '780546'
-- '2020', 'December', '1570841'
-- '2020', 'February', '10901'
-- '2020', 'January', '852'
-- '2020', 'July', '745907'
-- '2020', 'June', '623341'
-- '2020', 'March', '192016'
-- '2020', 'May', '679191'
-- '2020', 'November', '1238383'
-- '2020', 'October', '757775'
-- '2020', 'September', '685304'


## -- Handy query to check what is in the table 
## -- MySQL, by default, returns 1000 records. To return all records in the table, hard-coded the limit. Not an efficient way though
SELECT * 
FROM CovidDeaths
LIMIT 310000;


## -- Now the CovidVaccinations table
SELECT * 
FROM CovidDeaths CD JOIN CovidVaccinations CV
ON CD.location = CV.location AND
   CD.DateOfObservation = CV.DateOfObservation
LIMIT 310000;

## -- Total population vs vaccination per day 
SELECT CD.continent, CD.location, CD.dateOfObservation, population, new_vaccinations
FROM CovidDeaths CD JOIN CovidVaccinations CV
ON CD.location = CV.location AND
   CD.DateOfObservation = CV.DateOfObservation
WHERE CD.continent <> ''
ORDER BY CD.dateOfObservation DESC
LIMIT 310000;

## -- Country vs total vaccination
## -- Vaccinations may be greater than the population because of the dosages
SELECT CD.continent AS Continent, CD.location AS Country, population AS Population, sum(new_vaccinations) AS Vaccinations
FROM CovidDeaths CD JOIN CovidVaccinations CV
ON CD.location = CV.location AND
   CD.DateOfObservation = CV.DateOfObservation
WHERE CD.continent <> ''
GROUP BY CD.continent, CD.location, population
ORDER BY Continent, Country
LIMIT 310000; 
## -- Result for India
-- 'Asia', 'India', '1417173120', '2111904272'


# -- Cumulative Total on vaccination
SELECT CD.continent AS Continent, CD.location AS Country, CD.DateOfObservation, population AS Population, new_vaccinations,
	   sum(new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.DateOfObservation)AS CumulativeTotal
FROM CovidDeaths CD JOIN CovidVaccinations CV
ON CD.location = CV.location AND
   CD.DateOfObservation = CV.DateOfObservation
WHERE CD.continent <> '' AND new_vaccinations > 0
ORDER BY Continent, Country, CD.DateOfObservation
LIMIT 310000;
## -- One of the rows
-- Asia	India	2023-04-25	1417173120	5332	2111904272


# -- Population Vs Vaccination in running Percentage
WITH PopVsVacPercent(Continent, Country, Date, Population, NewVaccinations, RunningTotal) AS
(
SELECT CD.continent, CD.location, CD.DateOfObservation, population, new_vaccinations,
	   sum(new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.DateOfObservation)AS CumulativeTotal
FROM CovidDeaths CD JOIN CovidVaccinations CV
ON CD.location = CV.location AND
   CD.DateOfObservation = CV.DateOfObservation
WHERE CD.continent <> '' AND new_vaccinations > 0
ORDER BY CD.continent, CD.location , CD.DateOfObservation
LIMIT 310000)
SELECT *, RunningTotal/Population * 100 AS PercentVaccinated
FROM PopVsVacPercent;
## -- One of the rows
-- Asia	India	2023-04-25	1417173120	5332	2111904272	149.0223
-- More than 100% includes double vaccinations, boosters etc

# -- Alternate approach to get the exact percentage of people vaccinated
# -- Make use of the people_vaccinated column
# -- Population Vs Vaccination in running Percentage
SELECT CD.continent AS Continent, CD.location AS Country, CD.DateOfObservation AS Date, population as Population, 
	   people_vaccinated AS PeopleVaccinated, new_vaccinations AS NewVaccinations, 
	   sum(new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.DateOfObservation)AS RunningTotal,  
       people_vaccinated/population * 100 AS PercentOfPeopleVaccinated
FROM CovidDeaths CD JOIN CovidVaccinations CV
ON CD.location = CV.location AND
   CD.DateOfObservation = CV.DateOfObservation
WHERE CD.continent <> '' AND new_vaccinations > 0
ORDER BY CD.continent, CD.location , CD.DateOfObservation
LIMIT 310000;
## -- One of the rows
# -- Continent, Country, Date, Population, PeopleVaccinated, NewVaccinations, RunningTotal, PercentOfPeopleVaccinated
--  'Asia', 'India', '2023-04-25', '1417173120', '1027403794', '5332', '2111904272', '72.4967'


## -- When was the vaccination started
SELECT min(DateOfObservation) Vaccination_Started_On
FROM CovidVaccinations
WHERE new_vaccinations > 0;
# -- Vaccination_Started_On
-- '2020-12-03'

## -- Handy query to check what is in the table 
## -- MySQL, by default, returns 1000 records. To return all records in the table, hard-coded the limit. Not an efficient way though
## Handy query to check what is in the database 
SELECT * 
FROM CovidVaccinations
LIMIT 310000;

## -- Creating view to store data for later visualization
# -- Population Vs Vaccination in running Percentage
CREATE VIEW PercentPeopleVaccinated AS
SELECT CD.continent AS Continent, CD.location AS Country, CD.DateOfObservation AS Date, population as Population, 
	   people_vaccinated AS PeopleVaccinated, new_vaccinations AS NewVaccinations, 
	   sum(new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.DateOfObservation)AS RunningTotal,  
       people_vaccinated/population * 100 AS PercentOfPeopleVaccinated
FROM CovidDeaths CD JOIN CovidVaccinations CV
ON CD.location = CV.location AND
   CD.DateOfObservation = CV.DateOfObservation
WHERE CD.continent <> '' AND new_vaccinations > 0
ORDER BY CD.continent, CD.location , CD.DateOfObservation
LIMIT 310000;
