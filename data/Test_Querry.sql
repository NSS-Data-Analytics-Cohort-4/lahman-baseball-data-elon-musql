SELECT * from allstarfull
SELECT * from batting

-----Q1-- The Time Range for the gaming----
SELECT MIN(yearid) AS Starting_Year , MAX(yearid) AS Latest_Year 
FROM batting
------Ans 1871---To----2016-------------
------ Q2---------- name and height of the shortest player in the database--------
select distinct p.playerid, namegiven, namefirst, namelast, height, t.name as teamname
from people as p
left join batting as b
on p.playerid = b.playerid
left join teams as t
on t.teamid=b.teamid
where p.playerid='gaedeed01'
order by height 

----------Ans Edward Carl and the team he played in is St.Louis Browns 