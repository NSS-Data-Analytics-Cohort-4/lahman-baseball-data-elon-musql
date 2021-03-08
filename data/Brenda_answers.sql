/*
Q1 What range of years for baseball games played does the provided database cover?
A1 1871-2016 
*/

-- A 1871-2016
SELECT MIN(yearid),MAX(yearid)
FROM batting;

-- A 1985-2016
SELECT MIN(yearid),MAX(yearid)
FROM salaries;

-- A 1871-2016
SELECT MIN(yearid),MAX(yearid)
FROM teams;

/* 
Q2 Find the name and height of the shortest player in the database. How many games did he play in? 
What is the name of the team for which he played?
A2 Eddie Gaedel "Edward Carl" played in 1 game for SLA. His height was 43 inches.
*/
--should join teams to add team name
SELECT namegiven, height, b.teamid, b.g AS games, namefirst, namelast
FROM people AS p
LEFT JOIN batting AS b
ON p.playerid = b.playerid
WHERE height IN
		(SELECT MIN(height)
		FROM people)
GROUP BY namegiven, height, b.teamid, b.g, namefirst, namelast
	
--test for g / Edward Carl -->Two Edward Carls'
SELECT *
FROM people AS p
LEFT JOIN batting AS b
ON p.playerid = b.playerid
WHERE namegiven IN
	(SELECT namegiven
	FROM people
	WHERE namegiven = 'Edward Carl')
	
--Using appearances - same results
	SELECT namegiven, height, a.teamid, G_all AS games, namefirst, namelast
FROM people AS p
LEFT JOIN appearances AS a
ON p.playerid = a.playerid
WHERE height IN
		(SELECT MIN(height)
		FROM people)
GROUP BY namegiven, height, a.teamid, G_all, namefirst, namelast
	

	
/* 
Q3 Find all players in the database who played at Vanderbilt University. 
Create a list showing each player’s first and last names as well as the total salary
they earned in the major leagues. Sort this list in descending order by the total salary earned. 
Which Vanderbilt player earned the most money in the majors?
A3 David Price  */

-- Nulls were removed/put to bottom of the list
-- It would be nice to find a way to CAST the salary as money
SELECT p.playerid, namefirst, namelast, CASE WHEN SUM(salary) IS NOT NULL THEN SUM(salary)
			 							     ELSE '000' END AS t_salary
FROM people AS p
LEFT JOIN salaries AS sal
ON p.playerid = sal.playerid
WHERE p.playerid IN
	(SELECT DISTINCT(p.playerid)
	FROM people AS p
	LEFT JOIN collegeplaying AS cp
	ON p.playerid = cp.playerid
	LEFT JOIN schools AS s
	ON cp.schoolid = s.schoolid
	WHERE s.schoolname LIKE '%anderbilt%')
GROUP BY p.playerid, namefirst, namelast
ORDER BY t_salary DESC

/*
Q4 Using the fielding table, group players into three groups based on their position: 
label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.
*/

--Players into position groups
SELECT namefirst, namelast, 
CASE WHEN pos = 'OF' THEN 'Outfield'
	 WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
	 WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	 ELSE 'pos' END AS position
FROM people AS p
LEFT JOIN fielding AS f
ON p.playerid = f.playerid
ORDER BY position

-- Putouts of each group in 2016
SELECT DISTINCT(position), 
	SUM(po) OVER(PARTITION BY position) AS po_by_position
FROM (SELECT yearid, po, pos, 
	  CASE WHEN pos = 'OF' THEN 'Outfield'
		   WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
		   WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
		   ELSE 'pos' END AS position
	 FROM people AS p
	 LEFT JOIN fielding AS f
	 ON p.playerid = f.playerid
	 WHERE yearid = 2016
	 ORDER BY position ) AS sub

--visual of position --> in case of outliers --> there are none
SELECT pos, 
	   CASE WHEN pos = 'OF' THEN 'Outfield'
	   WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
	   WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	   ELSE '000' END AS position
FROM people AS p
LEFT JOIN fielding AS f
ON p.playerid = f.playerid
WHERE pos NOT IN ('P', 'C','OF', 'SS', '1B','2B','3B')
ORDER BY position 

/* 
Q5 Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. Do the same for home runs per game. 
Do you see any trends?

*/

--might check to see if data is same from other tables
--need to check for trends -->excel
SELECT DISTINCT(decade), 
	ROUND(SUM(so) OVER(PARTITION BY decade),2) AS so_by_decade,
	ROUND(SUM(hr) OVER(PARTITION BY decade),2) AS hr_by_decade
FROM (SELECT so, hr,
	  CASE WHEN yearid BETWEEN 1920 AND 1929 THEN 1920
		   WHEN yearid BETWEEN 1930 AND 1939 THEN 1930
	  	   WHEN yearid BETWEEN 1940 AND 1949 THEN 1940
	       WHEN yearid BETWEEN 1950 AND 1959 THEN 1950
	       WHEN yearid BETWEEN 1960 AND 1969 THEN 1960
	       WHEN yearid BETWEEN 1970 AND 1979 THEN 1970
	       WHEN yearid BETWEEN 1980 AND 1989 THEN 1980
	       WHEN yearid BETWEEN 1990 AND 1999 THEN 1990
	       WHEN yearid BETWEEN 2000 AND 2009 THEN 2000
	       WHEN yearid BETWEEN 2010 AND 2019 THEN 2010
	       ELSE 000 END AS decade
	 FROM pitching AS p) AS sub
ORDER BY decade DESC

/*
Q6 Find the player who had the most success stealing bases in 2016, 
where success is measured as the percentage of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted at least 20 stolen bases.
A6 Chris Owings with 91.3 percent success.
*/

SELECT *
FROM (SELECT namefirst , namelast , yearid,
	  SUM(b.sb) AS successful,
	  SUM(b.sb + b.cs) AS all_tried,
	  ROUND(SUM(b.sb) * 100.0 / SUM(b.sb + b.cs),1) AS successful_steals
	  FROM people AS p
	  LEFT JOIN batting AS b
	  ON p.playerid = b.playerid
	  GROUP BY namefirst, namelast, yearid) AS sub
WHERE all_tried > 19 AND yearid = 2016
ORDER BY successful_steals DESC

