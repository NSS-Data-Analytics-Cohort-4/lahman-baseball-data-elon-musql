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
Eddie Gaedel "Edward Carl" played in 1 game for SLA. His height was 43 inches.
*/

SELECT namegiven, height, b.teamid, b.g AS games, namefirst, namelast
FROM people AS p
LEFT JOIN batting AS b
ON p.playerid = b.playerid
WHERE height IN
		(SELECT MIN(height)
		FROM people)
GROUP BY namegiven, height, b.teamid, b.g, namefirst, namelast
	
--test for g / Edward Carl
SELECT *
FROM people AS p
LEFT JOIN batting AS b
ON p.playerid = b.playerid
WHERE namegiven IN
	(SELECT namegiven
	FROM people
	WHERE namegiven = 'Edward Carl')
	
--Using appearances
	SELECT namegiven, height, b.teamid, G.all AS games, namefirst, namelast
FROM people AS p
LEFT JOIN appearances AS b
ON p.playerid = b.playerid
WHERE height IN
		(SELECT MIN(height)
		FROM people)
GROUP BY namegiven, height, b.teamid, G.all, namefirst, namelast
	
--test for g / Edward Carl
SELECT *
FROM people AS p
LEFT JOIN batting AS b
ON p.playerid = b.playerid
WHERE namegiven IN
	(SELECT namegiven
	FROM people
	WHERE namegiven = 'Edward Carl')
	
/* Find all players in the database who played at Vanderbilt University. 
Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

