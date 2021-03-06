
-- 1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(year),Max(Year)
from homegames;

-- Answer: 1871 to 2016

--2. 1. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

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
--3
SELECT people.playerid, namefirst, namegiven, namelast, g_all as games, height as height_inches, teams.name
	FROM people INNER JOIN appearances ON people.playerid = appearances.playerid
		INNER JOIN teams ON teams.teamid = appearances.teamid
	WHERE people.playerid = 'gaedeed01'
	LIMIT 1;
	
	--test
	select *
	FROM APPEARANCES
	
	
	