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
SELECT namegiven, height, a.teamid, G_all AS games, namefirst, namelast, t.name
FROM appearances AS a
LEFT JOIN people AS p
ON p.playerid = a.playerid
LEFT JOIN teams AS t
ON a.teamid = t.teamid
WHERE height IN
		(SELECT MIN(height)
		FROM people)
GROUP BY namegiven, height, a.teamid, G_all, namefirst, namelast, t.name
	
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
	WHERE s.schoolname ILIKE '%vanderbilt%')
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
--need to check for trends -->excel
SELECT DISTINCT(decade), 
	ROUND(AVG(so/g) OVER(PARTITION BY decade),2) AS so_by_game_by_decade,
	ROUND(AVG(hr/g) OVER(PARTITION BY decade),2) AS hr_by_game_by_decade
FROM (SELECT so, hr, g,
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
	 FROM teams ) AS sub
ORDER BY decade DESC

--check for difference btn so and soa in teams
SELECT  COUNT(soa) as so_pitcher,COUNT(so) AS so_batter,
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
FROM teams
GROUP BY decade
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
	  CONCAT(ROUND(SUM(b.sb) * 100.0 / SUM(b.sb + b.cs),1),'%') AS successful_steals
	  FROM people AS p
	  LEFT JOIN batting AS b
	  ON p.playerid = b.playerid
	  GROUP BY namefirst, namelast, yearid) AS sub
WHERE all_tried > 19 AND yearid = 2016
ORDER BY successful_steals DESC

/*
Q7 From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
What is the smallest number of wins for a team that did win the world series? 
Doing this will probably result in an unusually small number of wins for a world series champion 
– determine why this is the case. Then redo your query, excluding the problem year. 
How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
What percentage of the time?
*/

--largest number of wins without winning the world series
SELECT DISTINCT(yearid), teamid, w
FROM teams
WHERE wswin = 'N' AND yearid BETWEEN 1970 AND 2016
ORDER BY w DESC
LIMIT 10

--smallest number of wins for a team who won the world series
-- There was a strike, teams did not play in as many games compared to a regular season. 
-- MORE INFORMATION https://www.usatoday.com/story/sports/mlb/2020/03/15/1981-mlb-season-coronavirus-delay-baseball/5054780002/
SELECT DISTINCT(yearid), teamid, w
FROM teams
WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016
ORDER BY w 
LIMIT 10

--problem year? remove 1981??
SELECT w, yearid, teamid
FROM
	(SELECT DISTINCT(yearid), teamid, w
	FROM teams
	WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016
	ORDER BY w ASC) sub
WHERE yearid <> 1981


--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
--What percentage of the time?
SELECT COUNT(maxwin) AS mostwins_and_wonws, COUNT(wswin) AS countall_ws,
		CONCAT(ROUND(COUNT(maxwin)*100.0/COUNT(wswin),1),'%') AS percentage_mostwins_wonws
FROM
	(SELECT DISTINCT(yearid), wswin,
		CASE WHEN wswin = 'Y'  THEN MAX(w) OVER(PARTITION BY yearid) END AS maxwin
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid,wswin, w
	ORDER BY yearid DESC) AS sub

--need names -->one NULL --> tie?? 1994
SELECT if_won, COUNT(if_won), wswin
FROM(
		SELECT MAX(w), yearid, wswin,
			CASE WHEN wswin = 'Y' THEN 1
			WHEN wswin = 'N' THEN 0
			ELSE 3 END AS if_won
		FROM teams
		WHERE yearid BETWEEN 1970 AND 2016
		GROUP BY yearid, wswin) AS sub
GROUP BY if_won , wswin
ORDER BY if_won DESC

/*
Q8 Using the attendance figures from the homegames table, 
find the teams and parks which had the top 5 average attendance per game in 2016 
(where average attendance is defined as total attendance divided by number of games).
Only consider parks where there were at least 10 games played. 
Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
*/
-- Why are the numbers the same even when multiple teams at one park?
SELECT sub.park_name, sub.team,
		ROUND(total_attendance_by_team /gnumber_by_team,1) AS avg_att_per_team, 
		ROUND(total_attendance_by_park /gnumber_by_park,1) AS avg_att_per_park
FROM
	(SELECT h.games, p.park_name, h.team,
	 		SUM(h.attendance) OVER(PARTITION BY h.team) AS total_attendance_by_team,
	 		SUM(h.attendance) OVER(PARTITION BY h.park) AS total_attendance_by_park,
	 		SUM(h.games) OVER(PARTITION BY h.team) AS gnumber_by_team,
	 		SUM(h.games) OVER(PARTITION BY h.park) AS gnumber_by_park
	FROM homegames AS h
	LEFT JOIN parks AS p
	ON h.park = p.park
	--LEFT JOIN teams as t
	--ON h.team = t.teamid
	WHERE year = 2016 AND games > 9
	GROUP BY p.park_name, h.park, h.games, h.team, h.team, h.attendance) AS sub
GROUP BY sub.park_name, sub.team, total_attendance_by_team , gnumber_by_team, total_attendance_by_park ,gnumber_by_park
ORDER BY avg_att_per_park DESC

--for least
SELECT sub.park_name, sub.team,
		ROUND(total_attendance_by_team /gnumber_by_team,1) AS avg_att_per_team, 
		ROUND(total_attendance_by_park /gnumber_by_park,1) AS avg_att_per_park
FROM
	(SELECT h.games, p.park_name, h.team,
	 		SUM(h.attendance) OVER(PARTITION BY h.team) AS total_attendance_by_team,
	 		SUM(h.attendance) OVER(PARTITION BY h.park) AS total_attendance_by_park,
	 		SUM(h.games) OVER(PARTITION BY h.team) AS gnumber_by_team,
	 		SUM(h.games) OVER(PARTITION BY h.park) AS gnumber_by_park
	FROM homegames AS h
	LEFT JOIN parks AS p
	ON h.park = p.park
	--LEFT JOIN teams as t
	--ON h.team = t.teamid
	WHERE year = 2016 AND games > 9
	GROUP BY p.park_name, h.park, h.games, h.team, h.team, h.attendance) AS sub
GROUP BY sub.park_name, sub.team, total_attendance_by_team , gnumber_by_team, total_attendance_by_park ,gnumber_by_park
ORDER BY avg_att_per_park 

--w duplications from team name -->teams table -- doesn't work
SELECT sub.park_name, sub.name, sub.team,
		ROUND(total_attendance_by_team /gnumber_by_team,1) AS avg_att_per_team, 
		ROUND(total_attendance_by_park /gnumber_by_park,1) AS avg_att_per_game
FROM
	(SELECT h.games, p.park_name, t.name, h.team,
	 		AVG(h.attendance) OVER(PARTITION BY t.name) AS total_attendance_by_team,
	 		AVG(h.attendance) OVER(PARTITION BY h.park) AS total_attendance_by_park,
	 		SUM(h.games) OVER(PARTITION BY t.name) AS gnumber_by_team,
	 		SUM(h.games) OVER(PARTITION BY h.park) AS gnumber_by_park
	FROM homegames AS h
	LEFT JOIN parks AS p
	ON h.park = p.park
	LEFT JOIN teams as t
	ON h.team = t.teamid
	WHERE year = 2016 AND games > 9
	GROUP BY p.park_name, h.park, h.games, h.team, t.name, h.attendance, h.team)sub
GROUP BY sub.park_name, sub.name, total_attendance_by_team , gnumber_by_team, total_attendance_by_park ,gnumber_by_park, sub.team
ORDER BY avg_att_per_game ASC
LIMIT 5

/*
9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
Give their full name and the teams that they were managing when they won the award.
*/
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

/*
Q10 Analyze all the colleges in the state of Tennessee. 
Which college has had the most success in the major leagues. 
Use whatever metric for success you like - number of players, number of games, salaries, world series wins, etc.
*/
SELECT DISTINCT(sc.schoolid),
	SUM(a.g_all) OVER(PARTITION BY cp.schoolid) AS total_games,
	COUNT(a.playerid) OVER(PARTITION BY cp.schoolid) AS total_players,
	SUM(s.salary) OVER(PARTITION BY cp.schoolid) AS total_salary,
	COUNT(t.wswin) OVER(PARTITION BY cp.schoolid) AS total_wswins
FROM collegeplaying AS cp
JOIN  schools AS sc
ON cp.schoolid = sc.schoolid
JOIN appearances AS a
ON cp.playerid = a.playerid
JOIN salaries AS s
ON cp.playerid = s.playerid
JOIN teams AS t
ON t.teamid = a.teamid
WHERE cp.schoolid IN
	(SELECT schoolid
	FROM schools
	WHERE schoolstate = 'TN')
ORDER BY total_games DESC	--exchange with total_players  total_salary  total_ws_wins
		
/*
Q11 Is there any correlation between number of wins and team salary? 
Use data from 2000 and later to answer this question. As you do this analysis, 
keep in mind that salaries across the whole league tend to increase together, 
so you may want to look on a year-by-year basis.
*/
--salary not partitioned by year?
SELECT DISTINCT(t.teamid) AS team, t.yearid AS year,
	SUM(s.salary) OVER(PARTITION BY t.yearid) AS total_salary,
	SUM(t.w)      OVER(PARTITION BY t.yearid) AS total_wins
FROM teams AS t
JOIN salaries AS s
ON t.teamid = s.teamid
WHERE t.yearid > 1999
GROUP BY t.teamid, t.yearid, t.w, s.salary
ORDER BY team, year DESC

/*
Q12 In this question, you will explore the connection between number of wins and attendance.
Does there appear to be any correlation between attendance at home games and number of wins?
Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? 
Making the playoffs means either being a division winner or a wild card winner.
*/
--same issue with partitioning the attendance
SELECT DISTINCT(teamid), yearid,
		SUM(h.attendance) OVER(PARTITION BY t.teamid) AS total_attendance,
		SUM(w) 			  OVER(PARTITION BY t.teamid) AS total_wins
FROM teams AS t
JOIN homegames AS h
ON t.teamid = h.team
ORDER BY teamid, yearid DESC

--same issue
SELECT DISTINCT(t.teamid), t.yearid, t.wswin,
	SUM(h.attendance) OVER(PARTITION BY t.yearid) AS total_attendance,
	SUM(w) OVER(PARTITION BY t.yearid) AS total_wins
FROM teams AS t
JOIN homegames AS h
ON t.teamid = h.team
WHERE t.wcwin = 'Y' OR t.wcwin = 'N'
ORDER BY t.teamid, t.yearid DESC

/*
Q13 It is thought that since left-handed pitchers are more rare, causing batters to face them less often,
that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. 
First, determine just how rare left-handed pitchers are compared with right-handed pitchers. 
Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?
*/
--rarity
WITH lefties AS (SELECT playerid	 						
			     FROM people
			     WHERE throws = 'L' AND playerid IN
												   (SELECT playerid
							 						FROM pitching)),
    all_pitchers AS (SELECT playerid 
			     FROM people
				 WHERE playerid IN
								 (SELECT playerid
								 FROM pitching))
SELECT COUNT(lefties.*) AS count_lefties, COUNT(all_pitchers.*) AS count_pitchers,
		ROUND(COUNT(lefties.playerid) *100.0/ (COUNT(all_pitchers.playerid)),1) AS percent_lefties
FROM people
LEFT JOIN lefties
ON people.playerid = lefties.playerid
LEFT JOIN all_pitchers
ON people.playerid = all_pitchers.playerid

/*--likelyhood to win award
JOIN awardsplayers 
ON awardsplayers.playerid = people.playerid
WHERE awardid = 'Cy Young Award'
*/

/*--likelyhood to enter HoF
WHERE people.playerid IN
						(SELECT playerid
						FROM halloffame)
*/

