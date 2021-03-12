/*SELECT * FROM allstarfull;
SELECT * FROM batting;
SELECT * FROM people;
SELECT * FROM collegePlaying
SELECT * from Salaries;
SELECT COUNT(*) From salaries ;
SELECT COUNT (Distinct playerid) FROM Salaries
Group By playerid;
SELECT * FROM fielding */
SELECT * from homegames

-----shortest player in the database---and get only the playerid & height----...
SELECT playerid ,height
FROM People
ORDER BY height 
LIMIT 1;
---------------------
SELECT Count(distinct playerid) , count(*) ,count(playerid)  FROM people;

-----Q1-- The Time Range for the gaming----
SELECT MIN(yearid) AS Starting_Year , MAX(yearid) AS Latest_Year 
FROM fielding;
------Ans 1871---To----2016-------------
------ Q2-- Name and height of the shortest player in the database--------
/*2- Find the name and height of the shortest player in the database. 
	 How many games did he play in? 
	 What is the name of the team for which he played?*/
	 
SELECT DISTINCT (p.playerid), CONCAT(namefirst,' ',namelast) AS FullName, namegiven, height, a.yearid, t.name as teamname,a.g_all
FROM people as p
LEFT JOIN appearances as a
ON p.playerid = a.playerid
LEFT JOIN teams as t
ON t.teamid=a.teamid
ORDER BY p.height;

--WHERE p.Playerid = 'gaedeed01';
--Number of games he had-----
SELECT Count(*) 
FROM appearances 
WHERE playerid = 'gaedeed01';
-----Ans 'Eddie Gaedel'/'Edward Carl',team -St.Louis Browns ,number of games =1

/* 3.Find all players in the database who played at Vanderbilt University. 
     Create a list showing each player’s first and last names as well as the 
	 total salary they earned in the major leagues. Sort this list in descending 
	 order by the total salary earned. Which Vanderbilt player earned the most money
	 in the majors?*/
---------- Players who played for Vanderbilt university'------------------
SELECT c.schoolid,c.playerid,s.schoolname, p.namegiven 
FROM collegeplaying AS c
JOIN schools AS s
ON c.schoolid=s.schoolid
JOIN people as p
ON c.playerid=p.playerid
WHERE schoolname = 'Vanderbilt University';
---------------------------------------------------Ans for Q-3-----CTE ---------
 WITH Vanderbilt_Players AS
			(SELECT DISTINCT c.schoolid, s.schoolname ,c.playerid
			 FROM collegeplaying AS c
			 JOIN schools AS s
		     ON c.schoolid = s.schoolid
			 WHERE schoolname = 'Vanderbilt University'),
     TTL_sal AS 
			(select sum(salary) as Total_salary, playerid
			from salaries
			group by playerid)
select p.namelast, p.namefirst, p.namegiven,ts.Total_salary
from Vanderbilt_Players AS vp
inner join TTL_sal as ts
on vp.playerid = ts.playerid
inner join people as p
on vp.playerid = p.playerid
order by ts.Total_salary desc;

/*4.Using the fielding table, group players into three groups based on their position:
    label players with position OF as "Outfield", those with position "SS", "1B", "2B", 
	and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine 
	the number of putouts made by each of these three groups in 2016. */
	
-------------- CASE...THEN..ELSE.... applied here ........
				
SELECT SUM(PO), CASE WHEN pos = 'OF' THEN 'Outfield'
					 WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
					 WHEN pos IN ('P','C') THEN 'Battery' 
					 ELSE 'NO WHERE' END AS Players_Position
FROM fielding
WHERE yearid = '2016'
GROUP BY Players_Position
ORDER BY SUM(PO);

-------ans outfiled (29560), Battery(41424), Infield(58934)----------------

/*5)Find the average number of strikeouts per game by decade since 1920. Round the numbers
    you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?*/
	
--a) for strike outs	

SELECT teamid,ROUND((SUM(so)+SUM(soa))/(count(cg),2) as avg_strikeout_per_game,floor(Cast(yearid as int) / 10) * 10 AS decade
   FROM teams AS t
   WHERE floor(Cast(yearid as int) / 10) * 10>=1920  
   GROUP BY t.teamid,decade
   ORDER BY decade;
   
-- b)for home runs per game 

SELECT teamid,ROUND(SUM(hr)/COUNT(cg),2) AS avg_home_run_per_game,floor(Cast(yearid as int) / 10) * 10 as decade
   FROM teams AS t
   WHERE floor(Cast(yearid as int) / 10) * 10>=1920  
   GROUP BY t.teamid,decade
   ORDER BY decade;
   
/*Question 6- Find the player who had the most success stealing bases in 2016, 
				where success is measured as the percentage of stolen base attempts which are successful. 
				(A stolen base attempt results either in a stolen base or being caught stealing.) 
				Consider only players who attempted at least 20 stolen bases.*/
				
/*SELECT playerid, round(cast(sb AS decimal)/((cast(sb as decimal) + cast(cs as decimal)),1)*100 AS stolen
FROM batting
WHERE yearid = '2016' AND (sb + cs) > 19
ORDER BY stolen desc;*/
					   
SELECT playerid, concat((round((cast(sb as decimal)/(cast(sb as decimal) + cast(cs as decimal))),2) *100.0 ),'%') as stolen
FROM batting
WHERE yearid = '2016' AND (sb + cs) > 19
ORDER BY stolen desc;

					   
--------------------Brenda's .. #6 ------------------------------------------------------------	
SELECT *
FROM (SELECT namefirst , namelast , yearid,
	  SUM(b.sb) AS successful,
	  SUM(b.sb + b.cs) AS all_tried,
	  Concat(ROUND(SUM(b.sb) * 100.0 / SUM(b.sb + b.cs),1),'%') AS successful_steals
	  FROM people AS p
	  LEFT JOIN batting AS b
	  ON p.playerid = b.playerid
	  GROUP BY namefirst, namelast, yearid) AS sub
WHERE all_tried > 19 AND yearid = 2016
ORDER BY successful_steals DESC;
---------------------------------------------------------------------------------------------------					   
--Question 7- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?*/
SELECT teamid, yearid, w, WSWin
FROM teams
WHERE yearid > 1969 AND wswin = 'N'
ORDER BY w desc
LIMIT 1;
--What is the smallest number of wins for a team that did win the world series?*/
SELECT teamid, yearid, w, WSWin
FROM teams
WHERE yearid > 1969 AND wswin = 'Y'
ORDER BY w 
LIMIT 1;

SELECT COUNT(maxwin) AS mostwins_and_wonws, COUNT(wswin) AS countall_ws,
		CONCAT(ROUND(COUNT(maxwin)*100.0/COUNT(wswin),1),'%') AS percentage_mostwins_wonws
FROM
	(SELECT DISTINCT(yearid), wswin,
		CASE WHEN wswin = 'Y'  THEN MAX(w) OVER(PARTITION BY yearid) END AS maxwin
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid,wswin, w
	ORDER BY yearid DESC) AS sub

---------------------------------------------------------------------------------------------------------------------------------------------
/*8.Using the attendance figures from the home games table, find the teams and parks which had the top 5 average attendance
    per game in 2016 (where average attendance is defined as total attendance divided by number of games).
    Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. 
	Repeat for the lowest 5 average attendance. */

--- a--The Top-5

SELECT distinct p.Park_name,hg.park, hg.team,t.name, (hg.attendance/hg.games) AS Att_per_game
FROM parks AS P
JOIN homegames AS hg	
ON p.park = hg.park
JOIN teams as t
ON hg.team = t.teamid
WHERE year = '2016' AND games>=10
GROUP BY t.name, hg.team,p.park_name,hg.park,hg.attendance,t.teamid ,hg.games
ORDER BY Att_per_game DESC
LIMIT 5;	

---b------The lowest 5----

SELECT p.Park_name,hg.park,t.name,hg.team, (hg.attendance/hg.games) AS Att_per_game
FROM parks AS P
JOIN homegames AS hg	
ON p.park = hg.park
JOIN teams as t
ON hg.team = t.teamid
WHERE year = '2016' AND games>=10
GROUP BY t.name, hg.team,p.park_name,hg.park,hg.attendance,hg.games
ORDER BY Att_per_game 
LIMIT 5;	
	   
-------------------------------Brenda's Approach---------------
SELECT sub.park_name, sub.name,
		ROUND(total_attendance_by_team /gnumber_by_team,1) AS avg_att_per_team,
		ROUND(total_attendance_by_park /gnumber_by_park,1) AS avg_att_per_park
FROM
	(SELECT h.games, p.park_name, t.name,
	 		SUM(h.attendance) OVER(PARTITION BY t.name) AS total_attendance_by_team,
	 		SUM(h.attendance) OVER(PARTITION BY h.park) AS total_attendance_by_park,
	 		SUM(h.games) OVER(PARTITION BY t.name) AS gnumber_by_team,
	 		SUM(h.games) OVER(PARTITION BY h.park) AS gnumber_by_park
	FROM homegames AS h
	LEFT JOIN parks AS p
	ON h.park = p.park
	LEFT JOIN teams as t
	ON h.team = t.teamid
	WHERE year = 2016 AND games > 9
	GROUP BY p.park_name, h.park, h.games, h.team, t.name, h.attendance)sub
GROUP BY sub.park_name, sub.name, total_attendance_by_team , gnumber_by_team, total_attendance_by_park ,gnumber_by_park
ORDER BY avg_att_per_park 
LIMIT 5;

-----------Question 9----------------------------------------------------------
/*9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American 
    League (AL)? Give their full name and the teams that they were managing when they won the award.*/
	
--------------

WITH filter_nl AS(
		SELECT DISTINCT(am.playerid), am.yearid AS year_award_nl, t.name AS team_award_nl
		FROM awardsmanagers AS am
		JOIN managers AS m
		ON am.playerid = m.playerid
		JOIN teams AS t
		ON m.teamid = t.teamid
		WHERE am.awardid = 'TSN Manager of the Year' AND am.lgid = 'NL'),
	 filter_al AS(
		SELECT DISTINCT(am.playerid), am.yearid AS year_award_al, t.name AS team_award_al
		FROM awardsmanagers AS am
		JOIN managers AS m
		ON am.playerid = m.playerid
		JOIN teams AS t
		ON m.teamid = t.teamid
		WHERE am.awardid = 'TSN Manager of the Year' AND am.lgid = 'AL')
SELECT DISTINCT(CONCAT(p.namefirst,' ', p.namelast)) AS full_name, filter_nl.year_award_nl,  filter_nl.team_award_nl, filter_al.year_award_al, filter_al.team_award_al
FROM filter_nl
INNER JOIN  people AS p
ON filter_nl.playerid = p.playerid
INNER JOIN filter_al
ON filter_al.playerid = filter_nl.playerid
FULL JOIN teams AS t
ON filter_nl.team_award_nl = t.teamid
GROUP BY full_name, filter_nl.year_award_nl,  filter_nl.team_award_nl, filter_al.year_award_al, filter_al.team_award_al
ORDER BY full_name

-----------Question 9----------------------------------------------------------
/*9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American 
    League (AL)? Give their full name and the teams that they were managing when they won the award.*/
	
--------------------------------------------------------------------------------------------------------------------------
With NL As (
           SELECT * FROM awardsmanagers 
	       Where awardid ='TSN Manager of the Year'
           AND lgid ='NL'),
     AL AS (
	       SELECT * FROM awardsmanagers
		   Where awardid ='TSN Manager of the Year'
		   AND lgid ='AL') 

SELECT distinct CONCAT(namefirst,' ',namelast) AS fullname ,/*--m.teamid ,m.Playerid,*/ am.yearid,am.lgid --t.name
FROM people AS p
INNER JOIN NL 
ON p.playerid=NL.playerid
INNER JOIN AL
ON p.playerid=AL.playerid
INNER JOIN awardsmanagers AS am
ON p.playerid= am.playerid
/*INNER JOIN managers as m
ON am.playerid =m.playerid
INNER JOIN teams t
ON m.teamid =t.teamid */
GROUP BY fullname,am.lgid,am.yearid;--m.playerid,m.teamid,t.name;


---SELECT * FROM awardsmanagers;					   
					   
					   
					   
					   
					   
					   
					   
					   

					   
  
   
