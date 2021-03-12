/*Q1 What range of years for baseball games played does the provided database cover?--A: 1871-05-04 TO 2016-07-03
SELECT
	MIN(span_first) AS first_date,
	MAX(span_first)	AS last_date
FROM homegames;*/
---------------------------------------------------------------------------------------------------------------------------------------------------------
--Q2a:Find the name and height of the shortest player in the database A: Eddie Gaedel 
/*SELECT 
	namefirst,
	namelast,
	playerid
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


--Q2c  What is the name of the team for which he played? SLA
/*SELECT teamID
FROM appearances 
WHERE playerid = 'gaedeed01';*/

--Q2 combined

SELECT 
	DISTINCT namefirst,
 	namelast,
 	p.playerid,
	g_all,
	a.teamid,
	name
FROM people as p
INNER JOIN appearances as a
ON a.playerid = p.playerid
INNER JOIN teams as t
ON t.teamid = a.teamid
WHERE height =
(
	SELECT min(height) 
	FROM people
);

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--Q3a Find all players in the database who played at Vanderbilt University. A.24
/*SELECT p.namelast
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
/*SELECT p.namelast, p.namefirst,SUM(salary) AS total_salary
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
-------------------------------------------------------------------------------------------------------------------------------------------------
--Q4a Using the fielding table, group players into three groups based on their position:
--label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield",
--and those with position "P" or "C" as "Battery".
/*SELECT playerid,
 	CASE WHEN pos ='OF' THEN 'Outfield'
		 WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
		 WHEN pos IN('P','C') THEN 'Battery'
		 END AS position
FROM fielding;*/

--Q4b.Determine the number of putouts made by each of these three groups in 2016.
/*WITH PO_Q AS (
 SELECT playerid,po,pos,yearid,
 	CASE WHEN pos ='OF' THEN 'Outfield'
		 WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
		 WHEN pos IN('P','C') THEN 'Battery'
		 END AS position
		 
FROM fielding)
SELECT PO_Q.position, SUM(f.po)
FROM fielding AS f
INNER JOIN PO_Q
ON f.playerid = PO_Q.playerid
WHERE f.yearid = 2016
GROUP BY position*/

------------------------------------------------------------------------------------------------------------------------------------------------------
--Q5 Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places.
--Do the same for home runs per game. Do you see any trends?  Both increased over the decades
 
/*WITH decade_Q AS
(
	SELECT yearid,SO,HR,g,floor(yearid/10) * 10 AS decade FROM teams
),AVG_Q AS (
	SELECT decade,ROUND(AVG(SO/g),2) as avg_strikeouts_per_game,ROUND(AVG(HR/g),2) as avg_homeruns_per_game
	FROM decade_Q

	GROUP BY decade
) 
 SELECT * FROM AVG_Q
 WHERE decade >=1920
ORDER BY decade;*/
----------------------------------------------------------------------------------------------------------------------------------------------------

--Q6. Find the player who had the most success stealing bases in 2016,
--where success is measured as the percentage of stolen base attempts which are successful. 
--(A stolen base attempt results either in a stolen base or being caught stealing.)
--Consider only players who attempted at least 20 stolen bases.
--A. Chris Owings 91.30 percent success
--GOING TO JUST USE BATTING SINCE BATTING POST TABLE NOT IN ERD AND POST MEANS OUTSIDE OF SEASON GAMES--
/*WITH success_Q AS
	(	
SELECT p.playerid,namefirst,namelast,b.yearid,sum(cs) as caught,sum(sb) AS stolen
FROM people AS p
LEFT JOIN batting AS b
ON b.playerid = p.playerid
WHERE sb>=20 AND sb IS NOT NULL AND cs IS NOT NULL AND b.yearid >=2016
GROUP BY b.yearid,p.playerid
	)
SELECT playerid,namelast,namefirst,stolen,caught,(CAST(stolen as float)/(CAST(caught as float) + CAST(stolen as float))*100.0) AS percent_success
FROM success_Q 
ORDER BY percent_success DESC;*/
------------------------------------------------------------------------------------------------------------------------------------------------------
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

--1981 was a players' strike, split into two halves so remove 1981
--https://www.usatoday.com/story/sports/mlb/2020/03/15/1981-mlb-season-coronavirus-delay-baseball/5054780002/
SELECT *
FROM
(
	SELECT teamid,yearid,wswin,w
FROM teams
WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016
ORDER BY w) AS Q
WHERE yearid <>1981;


Q7C --How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT teamid,yearid,max(count) as most_wins
FROM
	(SELECT teamid,sum(w) from teams where wswin='Y' and yearid between 1970 and 2016 group by teamid) as sum_wins
	where yearid between 1970 and 2016
	group by teamid
select teamid,w from teams where yearid between 1970 and 2016 order by teamid


--Brenda
SELECT COUNT(maxwin) AS mostwins_and_wonws, COUNT(wswin) AS countall_ws,
		CONCAT(ROUND(COUNT(maxwin)*100.0/COUNT(wswin),1),'%') AS percentage_mostwins_wonws
FROM
	(SELECT DISTINCT(yearid), wswin,
		CASE WHEN wswin = 'Y'  THEN MAX(w) OVER(PARTITION BY yearid) END AS maxwin
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid,wswin, w
	ORDER BY yearid DESC) AS sub
--------------------------------------------------------------------------------------------------------------------------------------------
--Q8 Using the attendance figures from the homegames table,
--find the teams and parks which had the top 5 average attendance per game in 2016
--(where average attendance is defined as total attendance divided by number of games).
--Only consider parks where there were at least 10 games played.
--Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
-------------------------
--**HIGHEST AVG ATTENDANCE
WITH Qteam AS(
SELECT  name,teamid 
FROM teams
WHERE yearid = 2016
GROUP BY teamid,name)
SELECT distinct park_name,Qteam.name,h.attendance/games AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
ON p.park = h.park
INNER JOIN Qteam
ON Qteam.teamid = h.team
WHERE year = 2016 AND games>=10
ORDER BY avg_attendance DESC
LIMIT 5;

---------------------------
--**LOWEST AVERAGE ATTENDANCE
WITH Qteam AS(
select  name,teamid from teams
WHERE yearid = 2016
group by teamid,name)
SELECT distinct park_name,Qteam.name,h.attendance/games AS avg_attendance
FROM homegames AS h
INNER JOIN parks AS p
ON p.park = h.park
INNER JOIN Qteam
ON Qteam.teamid = h.team
WHERE year = 2016 AND games>=10
ORDER BY avg_attendance 
LIMIT 5;
----------------------------------------------------------------------------------------------------------------------------------------------------------
--Q9 Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)?
--Give their full name and the teams that they were managing when they won the award.
---testing data
SELECT namelast,namefirst,m.teamid,awarded_TSN.lgid,awarded_TSN.yearid,awardid AS award_NL_AND_AL
FROM
(
	SELECT playerid,awardid,lgid,yearid FROM awardsmanagers
	WHERE awardid LIKE 'TSN%'
) AS awarded_TSN
INNER JOIN people AS p
ON p.playerid = awarded_TSN.playerid
INNER JOIN managers as m
ON m.playerid = awarded_TSN.playerid
Where awarded_TSN.lgid like 'NL' or awarded_TSN.lgid like 'AL'
group by awarded_TSN.playerid,awardid,namelast,namefirst,m.teamid,awarded_TSN.lgid,awarded_TSN.yearid
Order by awarded_tsn.playerid
 




WITH Q_NL as
(
SELECT  playerid,awardid,lgid,yearid FROM awardsmanagers
	WHERE awardid LIKE 'TSN%' AND lgid LIKE 'NL'),

 Q_AL AS
(
	SELECT  playerid,awardid,lgid,yearid FROM awardsmanagers
	WHERE awardid LIKE 'TSN%' AND lgid LIKE 'AL'
)
-- Q_teams AS
--( select name,lgid,yearid from teams where yearid=2016
--GROUP BY name,lgid)

SELECT namelast,namefirst,Q_NL.yearid,Q_AL.yearid,teamid
FROM Q_NL
INNER JOIN Q_AL 
ON Q_NL.playerid = Q_AL.playerid
INNER JOIN people
ON people.playerid = Q_NL.playerid
INNER JOIN teams
ON teams.lgid = Q_NL.lgid
WHERE Q_NL.lgid <> Q_AL.lgid;

--brenda
WITH filter_nl AS(
		SELECT DISTINCT(am.playerid), am.yearid AS year_award_nl, m.teamid --,t.name AS team_award_nl
		FROM awardsmanagers AS am
		JOIN managers AS m
		ON am.playerid = m.playerid
		JOIN teams AS t
		ON m.teamid = t.teamid
		WHERE am.awardid = 'TSN Manager of the Year' AND am.lgid = 'NL' AND m.yearid = am.yearid),
	 filter_al AS(
		SELECT DISTINCT(am.playerid), am.yearid AS year_award_al, m.teamid --,t.name AS team_award_al
		FROM awardsmanagers AS am
		JOIN managers AS m
		ON am.playerid = m.playerid
		JOIN teams AS t
		ON m.teamid = t.teamid
		WHERE am.awardid = 'TSN Manager of the Year' AND am.lgid = 'AL' AND m.yearid = am.yearid)
SELECT DISTINCT(CONCAT(p.namefirst,' ', p.namelast)) AS full_name, filter_nl.year_award_nl, filter_nl.teamid, /*filter_nl.team_award_nl,*/filter_al.year_award_al, filter_al.teamid/*,filter_al.team_award_al*/
FROM filter_nl
INNER JOIN  people AS p
ON filter_nl.playerid = p.playerid
INNER JOIN filter_al
ON filter_al.playerid = filter_nl.playerid
ORDER BY full_name




















	










