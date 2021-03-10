/*Q1 What range of years for baseball games played does the provided database cover?--A: 1871-05-04
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

SELECT 
	namefirst,
	namelast,
	p.playerid
	g_all
FROM people as p
INNER JOIN appearances as a
ON a.playerid = p.playerid
WHERE height =
(
	SELECT min(height) 
	FROM people
);







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
--A. Chris Owings 91.30 percent success
--GOING TO JUST USE BATTING SINCE BATTING POST TABLE NOT IN ERD AND POST MEANS OUTSIDE OF SEASON GAMES--
/*WITH success_Q AS
(

SELECT p.playerid,namefirst,namelast,b.yearid,sum(cs) as caught,sum(sb) as stolen
FROM people as p
LEFT JOIN batting as b
ON b.playerid = p.playerid
WHERE sb>=20 AND sb IS NOT NULL AND cs IS NOT NULL AND b.yearid >=2016
GROUP BY b.yearid,p.playerid
	)
SELECT playerid,namelast,namefirst,stolen,caught,(CAST(stolen as float)/(CAST(caught as float) + CAST(stolen as float))*100.0) AS percent_success

FROM success_Q 
ORDER BY percent_success DESC;*/

--Q7a From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? A: 116

SELECT teamid,yearid,wswin,w
FROM teams
WHERE wswin = 'N' AND yearid BETWEEN 1970 AND 2016
ORDER BY w DESC
LIMIT 1;
--Q7b--What is the smallest number of wins for a team that did win the world series? A: 63
SELECT teamid,yearid,wswin,w
FROM teams
WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016
ORDER BY w;
--Doing this will probably result in an unusually small number of wins for a world series champion
--– determine why this is the case. Then redo your query, excluding the problem year.
--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--1981 is an outlier at 63 games so remove 1981
SELECT *
FROM
(
	SELECT teamid,yearid,wswin,w
FROM teams
WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016
ORDER BY w) AS Q
WHERE yearid <>1981;

--Q8 Using the attendance figures from the homegames table,
--find the teams and parks which had the top 5 average attendance per game in 2016
--(where average attendance is defined as total attendance divided by number of games).
--Only consider parks where there were at least 10 games played.
--Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
SELECT park_name,h.attendance/h.games as avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
ON p.park = h.park
--JOIN teams as t
--ON h.team = t.teamid
WHERE year = 2016 and games>=10
ORDER BY avg_attendance desc


SELECT park,team,attendance/games as avg_attendance
FROM homegames
WHERE year = 2016
AND games>=10
ORDER BY park




select * from teams























	










