/*Q1--A: 1871-05-04
SELECT
	MIN(span_first) AS first_date,
	MAX(span_first)	AS last_date
FROM homegames;*/

--Q2a:Find the name and height of the shortest player in the database A: Eddie Gaedel 
/*SELECT 
	namefirst,
	namelast,
	player_id
FROM people
WHERE height =
(
	SELECT min(height) 
	FROM people
);*/

/*Q2b  How many games did he play in? 1
SELECT g_all
FROM appearances 
WHERE playerid = 'gaedeed01';*/ 

--Q2c  What is the name of the team for which he played? SLA
/*SELECT teamID
FROM appearances 
WHERE playerid = 'gaedeed01';*/

--Q3a Find all players in the database who played at Vanderbilt University. A.24
/*SELECT p.namelast.
FROM people AS p
LEFT JOIN collegeplaying AS  c
ON p.playerid = c.playerid
LEFT JOIN schools AS s
ON c.schoolid = s.schoolid
WHERE schoolname ILIKE 'Vanderbilt University'
GROUP BY namelast
ORDER BY namelast*/

--Q3b --Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues.
--Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors
--A: David Price $81,851,296
/*SELECT s.playerid,p.namelast, p.namefirst,SUM(salary) AS total_salary
FROM people AS p
LEFT JOIN salaries AS s
ON p.playerid = s.playerid
WHERE s.playerid IN
(
	SELECT playerid 
	FROM collegeplaying
	WHERE schoolid LIKE 'vandy'
)
GROUP BY s.playerid,p.namelast,p.namefirst
ORDER BY SUM(salary) DESC*/

--Q4a Using the fielding table, group players into three groups based on their position:
--label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield",
--and those with position "P" or "C" as "Battery".
/*SELECT playerid,
 	CASE WHEN pos ='OF' THEN 'Outfield'
		 WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
		 WHEN pos ='P' OR pos = 'C' THEN 'Battery'
		 END AS position
FROM fielding;*/

--Q4b.Determine the number of putouts made by each of these three groups in 2016.
/*SELECT 
 	CASE WHEN pos ='OF' THEN 'Outfield'
		 WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
		 WHEN pos ='P' OR pos = 'C' THEN 'Battery'
		 END AS position,
		 count(CASE WHEN pos ='OF' THEN 'Outfield'
		 WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
		 WHEN pos ='P' OR pos = 'C' THEN 'Battery'
		 END) AS positionCount
FROM fielding
WHERE yearid = 2016
GROUP BY position*/

--Q5 Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places.
--Do the same for home runs per game. Do you see any trends?  Both increased over the decades
 
/*WITH decade_Q AS
(
	SELECT yearid,SO,HR,floor(yearid/10) * 10 as decade FROM teams
),AVG_Q AS (
	SELECT decade,ROUND(AVG(SO),2) as avg_strikeouts,ROUND(AVG(HR),2) as avg_homeruns
	FROM decade_Q
	GROUP BY decade
) 
 SELECT * FROM AVG_Q
ORDER BY decade;*/


--Q6. Find the player who had the most success stealing bases in 2016,
--where success is measured as the percentage of stolen base attempts which are successful. 
--(A stolen base attempt results either in a stolen base or being caught stealing.)
--Consider only players who attempted at least 20 stolen bases.
--GOING TO JUST USE BATTING SINCE BATTING POST TABLE NOT IN ERD AND POST MEANS OUTSIDE OF SEASON GAMES--
WITH success_Q AS
(

SELECT p.playerid,b.yearid,sum(cs) as caught,sum(sb) as stolen
FROM people as p
LEFT JOIN batting as b
ON b.playerid = p.playerid
WHERE sb>=20 AND sb IS NOT NULL AND cs IS NOT NULL AND b.yearid >=2016
GROUP BY b.yearid,p.playerid
	)
SELECT playerid,yearid,stolen,caught,(CAST(stolen as float)/(CAST(caught as float) + CAST(stolen as float))*100.0) AS percent_success FROM success_Q 






















	










