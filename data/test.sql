SELECT DISTINCT (p.playerid),namegiven, height, a.yearid, t.name as teamname,a.g_all
FROM people as p
LEFT JOIN appearances as a
ON p.playerid = a.playerid
LEFT JOIN teams as t
ON t.teamid=a.teamid
ORDER BY p.height
LIMIT 1;