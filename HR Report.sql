CREATE DATABASE HR;
USE HR;


SELECT *
FROM hr_data;

SELECT  termdate
FROM hr_data
ORDER BY termdate DESC;

UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-mm-dd')
;

ALTER TABLE hr_data
ADD new_termdate DATE;

UPDATE hr_data
SET new_termdate = CASE
WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1
THEN CAST(termdate AS DATETIME) ELSE NULL END;


ALTER TABLE hr_data
ADD age INT;

UPDATE hr_data
SET age = DATEDIFF(YEAR, birthdate, GETDATE());

SELECT age
FROM hr_data;

-- age distribution
SELECT
MIN(age) AS youngest,
MAX(age) AS oldest
FROM hr_data;

-- age group by gender

SELECT age_group,
COUNT (*) AS count
FROM
(SELECT
CASE
	WHEN age >=21 AND age <=30 THEN '21 to 30'
	WHEN age >=31 AND age <=40 THEN '31 to 40'
	WHEN age >=41 AND age <=50 THEN '41 to 50'
	ELSE '50+'
	END AS age_group
FROM hr_data
WHERE new_termdate IS NULL) AS subquery
GROUP BY age_group
ORDER BY age_group;



SELECT age_group, 
gender,
COUNT (*) AS count
FROM
(SELECT
CASE
	WHEN age >=21 AND age <=30 THEN '21 to 30'
	WHEN age >=31 AND age <=40 THEN '31 to 40'
	WHEN age >=41 AND age <=50 THEN '41 to 50'
	ELSE '50+'
	END AS age_group, gender
FROM hr_data
WHERE new_termdate IS NULL) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender;


--Gender Distribution(GENDER COUNT)

SELECT gender,
count(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC;

--gender distribution based on different departments

SELECT gender, department,
count(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY gender, department
ORDER BY gender ASC, department;

-- race distribution

SELECT race,
count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY race
ORDER BY count DESC;

---average length of employment in the company(tenure)

SELECT
AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE();

-- Tenure distribution for each department
SELECT
department,
AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE()
GROUP BY department
ORDER BY tenure DESC;

--which department has the highest turnover rate
--(the rate at which employees leave a workforce and are replaced)

SELECT
	department,
	total_count,
	termminated_count,
	(CAST(termminated_count AS FLOAT)/total_count) AS turnover_rate
	FROM
		(SELECT
		department,
		count(*) AS total_count,
		SUM(CASE
			WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
			END) AS termminated_count
			FROM hr_data
			GROUP BY department
			)AS subquery
			ORDER BY turnover_rate DESC;

-- how many employees worl remptely for each department

SELECT
location,
count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location;


---distribbution of employees across different state

SELECT 
location_state,
count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

----distribution of job titles

SELECT
jobtitle,
count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;

---How have employee hire counts varied over time?

SELECT hire_year, hires, terminations, hires - terminations
AS net_change, 
ROUND(CAST((hires - terminations) AS FLOAT)/hires, 2)*100 AS percentage_hire_change
FROM
(SELECT 
YEAR(hire_date) AS hire_year,
count(*) AS hires,
SUM( CASE
		WHEN new_termdate IS NOT NULL and new_termdate <= GETDATE() THEN 1 ELSE 0
		END) AS terminations
FROM hr_data
GROUP BY YEAR(hire_date)) AS subquery
ORDER BY percentage_hire_change ASC;