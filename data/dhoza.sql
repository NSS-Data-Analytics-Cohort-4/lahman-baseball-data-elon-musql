/*Q1--A: 1871-05-04
select
	MIN(span_first) AS first_date,
	Max(span_first)	AS last_date
from homegames*/

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
)*/
--Q2b  How many games did he play in?
SELECT * from appearances where playerid = 'gaedeed01' 
s

