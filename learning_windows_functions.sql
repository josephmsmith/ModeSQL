-- Advanced SQL and Windows Functions


-- Let's select a few attributes to pull by date
-- We also want a count of the total number of animals

-- In subquery form this looks like: 
SELECT species, name, primary_color, admission_date,
	(SELECT count(*)
	from animals) as number_of_animals
FROM animals
ORDER BY admission_date asc;

-- In window function this looks like:
SELECT *, 
	COUNT(*)
	OVER () AS number_of_animals
FROM animals
ORDER BY admission_date ASC;

-- if you want to select for a certain time period the window function is going to be optimal
-- not only does it cost less, but it also 
SELECT *, 
	COUNT(*)
	OVER () AS number_of_animals
FROM animals
WHERE admission_date >= '2017-01-01'
ORDER BY admission_date ASC;
-- result is 75 animals

/*
what are frame boundaries?
in order to further refine our search we need FRAME BOUNDARIES
these come after our ORDER BY clause and tell SQL how to partition a window
The SYNTAX:

ORDER BY [COL] ASC
ROWS | RANGE | GROUPS
BETWEEN
	UNBOUNDED PRECEDING |
	n PRECEDING | n FOLLOWING 
	| CURRENT ROW
AND
	UNBOUNDED FOLLOWING |
	n PRECEDING | n FOLLOWING 
	| CURRENT ROW
*/

-- Example 1
SELECT species, name, 
	MAX(name)
	OVER (PARTITION BY species ORDER BY name 
		 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS number_of_animals
FROM animals;


-- show the number of animals admitted prior to the current day
SELECT species, name, primary_color, admission_date,
	avg heart_rate OVER (PARTITION BY species 
		  ORDER BY admission_date asc 
		 ROWS BETWEEN UNBOUNDED PRECEDING 
		  AND 
		  CURRENT ROW) AS upto_spc_animl
FROM animals
ORDER BY species asc, admission_date asc;

-- FRAME EXCLUSIONS
-- 4 Optional Clauses
/*
EXLUDE NO OTHERS
EXCLUDE GROUP 
EXCLUDE TIES 
EXCLUDE CURRENT ROW

-- NULL HANDLING
- Aggregate functions ignore nulls
- Rank and distribution respect NULLS
- Frame and boundaries respect NULLS
*/

-- Practice
-- return animal species, name, checkup time, hr, t/f when hr >= avg species hr

select species, name, checkup_time, heart_rate, 
	cast(avg(heart_rate)
		 over(PARTITION BY species)
		 as decimal (5,2)
		) as species_Avg_hr
from routine_checkups
order by species asc, checkup_time asc;

-- Monthly Adoption fee and that percent of the year
-- select year, month, monthly revenue, percent of current year
with monthly_grouped_adoptions as						--define the group query in CTE
	(select date_part('year', adoption_date) as year, 
			date_part('month', adoption_date) as month,
			sum(adoption_fee) as mth_total
	from adoptions
	group by 1,2)
select *,												--window function that defines percentage
	cast	(100* mth_total								--longer but clearer for readability
			/ SUM(mth_total)
			 over(partition by year)
			 as decimal(5,2)
			) as annual_pecent
from monthly_grouped_adoptions
order by 1, 2;


/* 
----------------------------------------------------
-- Warm up challenge - Annual vaccinations report --
----------------------------------------------------

Write a query that returns all years in which animals were vaccinated, and the total number of vaccinations 
given that year.
In addition, the following two columns should be included in the results:
1. The average number of vaccinations given in the previous two years.
2. The percent difference between the current year's number of vaccinations, and the average of the previous two years.
For the first year, return a NULL for both additional columns.

Hint: Cast averages and division expressions to DECIMAL (5, 2)

Expected result sorted by year ASC:
---------------------------------------------------------------------------------------------
|	year	|	number_of_vaccinations	|	previous_2_years_average	|	percent_change	|
|-----------|---------------------------|-------------------------------|-------------------|
|	2,016	|					11		|					[NULL]		|		[NULL]		|
|	2,017	|					23		|					11.00		|		209.09		|
|	2,018	|					32		|					17.00		|		188.24		|
|	2,019	|					29		|					27.50		|		105.45		|
---------------------------------------------------------------------------------------------
*/

-- first figure out annual vaccainations with first CTE, then add 2nd CTE with previous 2yr avg
with 
vac_by_year as (
	select date_part('year', vaccination_time)::INT as vac_year, count(*) as number_of_vaccinations 
	from vaccinations
	group by 1 ),
annual_vac_2yr_avg as
	(select *, cast( avg(number_of_vaccinations)
					over(order by vac_year asc range between 2 preceding and 1 preceding)
					as decimal(5,2)) as prev_2yr_avg
	 from vac_by_year
	) 
select *,
	(100*number_of_vaccinations/prev_2yr_avg)::Decimal(5,2) as pct_chg
from annual_vac_2yr_avg order by vac_year asc;
 
d

