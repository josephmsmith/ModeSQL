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








