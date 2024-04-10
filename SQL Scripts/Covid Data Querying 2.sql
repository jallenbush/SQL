
--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population_density 
from PortfolioProject..CovidDeaths
order by 3,4

--looking at total cases vs total deaths
--shows possibility of dying when contracting covid in your country

select location, date, cast(total_cases as int), cast(total_deaths as int), (total_deaths/total_cases)*100 
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--total cases vs population

 
