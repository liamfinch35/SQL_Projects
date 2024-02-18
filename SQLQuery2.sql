Select *
From first_for_portfolio..CovidDeaths$
order by 3, 4

Select *
From first_for_portfolio..CovidVaccinations$
order by 3, 4

-- Data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From first_for_portfolio..CovidDeaths$
order by 1, 2

-- countries with highest infection rate per population

Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percentage_population_infected
From first_for_portfolio..CovidDeaths$
Group by location, population
order by 4 desc

-- countries with highest death count per population

Select location, population, MAX(cast(total_deaths as int)) as total_death_count
From first_for_portfolio..CovidDeaths$
Where continent is not null
Group by location, population
order by 3 desc

-- Broken down by continent with highest death count

Select location,  MAX(cast(total_deaths as int)) as total_death_count
From first_for_portfolio..CovidDeaths$
Where continent is null
Group by location
order by 2 desc

-- Global numbers per day

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from first_for_portfolio..CovidDeaths$
where continent is not null
Group by date
order by 1, 2

--global numbers total

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from first_for_portfolio..CovidDeaths$
where continent is not null
order by 1, 2


--Joining data sets
select *
from first_for_portfolio..CovidVaccinations$ as deaths
join first_for_portfolio..CovidDeaths$ as vaccs
    On deaths.location = vaccs.location
	and deaths.date = vaccs.date

-- total population vs vaccinations

select deaths.continent, deaths.location, deaths.date, vaccs.population, vaccs.new_vaccinations, SUM(Cast(vaccs.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as Rolling_People_Vaccinated
from first_for_portfolio..CovidVaccinations$ as deaths
join first_for_portfolio..CovidDeaths$ as vaccs
    On deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null 
order by 2, 3

-- using CTE 

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated) 
As 
(
select deaths.continent, deaths.location, deaths.date, vaccs.population, vaccs.new_vaccinations, SUM(Cast(vaccs.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as Rolling_People_Vaccinated
from first_for_portfolio..CovidVaccinations$ as deaths
join first_for_portfolio..CovidDeaths$ as vaccs
    On deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null 
--order by 2, 3
)
Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVac

-- Using Temp table 
DROP Table if exists #Percent_Population_Vaccinated
Create Table  #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
select deaths.continent, deaths.location, deaths.date, vaccs.population, vaccs.new_vaccinations, SUM(Cast(vaccs.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as Rolling_People_Vaccinated
from first_for_portfolio..CovidVaccinations$ as deaths
join first_for_portfolio..CovidDeaths$ as vaccs
    On deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null 
--order by 2, 3

Select *, (Rolling_People_Vaccinated/Population)*100
From #Percent_Population_Vaccinated

-- Creating view for tableau 

Create View PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, vaccs.population, vaccs.new_vaccinations, SUM(Cast(vaccs.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as Rolling_People_Vaccinated
from first_for_portfolio..CovidVaccinations$ as deaths
join first_for_portfolio..CovidDeaths$ as vaccs
    On deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null 
--order by 2, 3