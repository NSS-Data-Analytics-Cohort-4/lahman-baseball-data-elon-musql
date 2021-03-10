
-- 1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(year),Max(Year)
from homegames;

-- Answer: 1871 to 2016

/*
2.b How many games did shortest player play in? ANSWER: One game
2.c. What team did shortest player play for?  ANSWER: ST. Louis Browns
*/
SELECT height,namefirst,namelast
from people
WHERE height=(select MIN(height)
			  FROM people
			  );
			  
-- Or
SELECT namefirst, namegiven, namelast, height as Height_Measurment
	FROM people 
	ORDER BY height
	LIMIT 1;
SELECT people.playerid, namefirst, namegiven, namelast, g_all as games_played, height as height_inches, teams.name
	FROM people INNER JOIN appearances ON people.playerid = appearances.playerid
		INNER JOIN teams ON teams.teamid = appearances.teamid
	WHERE people.playerid = 'gaedeed01'
	LIMIT 1;
	
	--test
	select *
	FROM APPEARANCES

-- Brenda's Code
SELECT namegiven, height, a.teamid, G_all AS games, namefirst, namelast
FROM people AS p
LEFT JOIN appearances AS a
ON p.playerid = a.playerid
WHERE height IN
		(SELECT MIN(height)
		FROM people)
GROUP BY namegiven, height, a.teamid, G_all, namefirst, namelast

/*
Query 3: 
a. Find all players in the database who played at Vanderbilt University  
ANSWER: List of 15 players.
b. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. 
d. Which Vanderbilt player earned the most money in the majors?  
ANSWER: David Price, earned $245,533,888
*/	

SELECT p.playerid, schoolname, namefirst, namelast, SUM(salary)::numeric::money as total_salary
FROM schools AS s 
		JOIN collegeplaying AS cp USING(schoolid)  --LEFT and INNER JOIN also work for all joins.
		JOIN people AS p ON p.playerid = cp.playerid
		JOIN salaries as sal ON sal.playerid = p.playerid
	WHERE schoolname like '%Vanderbilt%'
--		AND salary IS NOT NULL
GROUP BY p.playerid, schoolname, namefirst, namelast, namegiven
ORDER BY total_salary DESC;
/* 	QUESTION #4: Using the fielding table, group players into three groups based on their position: 
label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.
*/

select sum(f.po) as total_putouts,
	(case when f.pos = 'OF' then 'outfield'
			when f.pos in ('SS', '1B', '2B', '3B') then 'Infield'
	 		when pos = 'P' or pos = 'C' THEN 'Battery'
			 end) as position
from fielding f
where yearid = 2016
group by position;
/*
QUESTION #6
Find the player who had the most success stealing bases in 2016, 
where success is measured as the percentage of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted at least 20 stolen bases.
*/
SELECT sb AS stolen_bases, cs AS got_ya, (sb+cs) as times_attempted,
	CONCAT(ROUND((sb::numeric)/((sb::numeric)+(cs::numeric))*100,0), '%')::varchar AS success_percent,
	CONCAT(namegiven,' ', namelast) AS Name
FROM BATTING as b INNER JOIN people as p ON b.playerid=p.playerid
WHERE yearid=2016
AND sb > 20
GROUP BY sb, cs, p.namegiven, namelast
ORDER BY success_percent DESC
LIMIT 1;

with ws_winners as
					(select yearid, name
					from teams
					where wswin = 'Y'
					and yearid between 1970 and 2016
					order by yearid asc)
	 
	 WITH batting_sum AS ( SELECT yearid,
							 playerid,
					 		 teamid,
							 cs,
							 sb,
					 		 sum(cs+sb) AS attempts
						FROM batting
					 	WHERE yearid = '2016'
					 	GROUP BY yearid, playerid, cs, sb, teamid
						ORDER BY attempts DESC)

SELECT b.playerid, 
	  	p.namefirst, p.namelast, p.namegiven, b.sb, b.cs, b.attempts,
	   cast(b.sb as float)/cast(b.attempts as float) * 100.0,'%') AS success_perc
FROM batting_sum AS b
JOIN people AS p
USING(playerid)
WHERE b.sb >=20
GROUP BY  b.playerid, p.namefirst, p.namelast, p.namegiven,b.sb, b.cs, b.attempts
ORDER BY success_perc DESC


