CREATE DATABASE ipl;
USE ipl;

SELECT * FROM deliveries;

SELECT * FROM matches;

-- Q1: What are the top 5 Players with the most PLAYER OF THE MATCH awards?
SELECT player_of_match, COUNT(*) AS awards_count
FROM matches
GROUP BY player_of_match
ORDER BY awards_count DESC
LIMIT 5;

-- Q2: How many matches were won by each team in each season?
SELECT season, winner, COUNT(*) AS Count_winner
FROM matches
GROUP BY season, winner
ORDER BY Count_winner DESC;

-- Q3: What is the average Strike Rate of batsmen in ipl dataset?
SELECT ROUND(AVG(strike_rate),2) AS average_strike_rate
FROM( SELECT batsman,(SUM(total_runs)/COUNT(ball))*100 AS strike_rate
FROM deliveries
GROUP BY batsman) AS batsman_stats;

-- Q4: what is the number of matches won by each team batting first versus batting second?
SELECT 
    winner AS team_name,
    SUM(CASE 
            WHEN (toss_winner = winner AND toss_decision = 'bat') 
                OR (toss_winner != winner AND toss_decision = 'field') 
            THEN 1 ELSE 0 
        END) AS matches_won_batting_first,
    SUM(CASE 
            WHEN (toss_winner = winner AND toss_decision = 'field') 
                OR (toss_winner != winner AND toss_decision = 'bat') 
            THEN 1 ELSE 0 
        END) AS matches_won_batting_second
FROM matches
GROUP BY winner
ORDER BY team_name;

-- Q5: Which batsman has the highest Strike Rate (Minimum 200 runs scored)?
SELECT batsman, (SUM(batsman_runs)*100/COUNT(*)) AS Strike_rate
FROM deliveries
GROUP BY batsman
ORDER BY Strike_rate DESC
LIMIT 1;

-- Q6: How many time has each batsman been dismissed by the bowler 'Malinga'?
SELECT batsman, COUNT(*) AS Total_dismissed
FROM deliveries
WHERE player_dismissed is NOT NULL 
AND bowler = "SL Malinga"
GROUP BY batsman;

-- Q7: What is the average percentage of the boundaries(Fours and Sixes combined) hit by each batsman?
SELECT batsman, AVG( 
CASE WHEN batsman_runs = 4 OR batsman_runs = 6
THEN 1 ELSE 0 END)* 100 AS Avg_boundaries
FROM deliveries
GROUP BY batsman;

-- Q8: What is the average number of boundaries hit by each team in each season?
SELECT season,batting_team, AVG(fours+sixes) AS average_boundaries
FROM(SELECT season,match_id,batting_team,
SUM(CASE 
	WHEN batsman_runs=4 THEN 1 ELSE 0 END) AS fours,
SUM(CASE 
	WHEN batsman_runs=6 THEN 1 ELSE 0 END) AS sixes
FROM deliveries,matches 
WHERE deliveries.match_id=matches.id
GROUP BY season,match_id,batting_team) AS team_bounsaries
GROUP BY season,batting_team;

-- Q9: What is the highest partnership(runs) for each team in each season?
SELECT season,batting_team, MAX(total_runs) AS highest_partnership
FROM (SELECT season,batting_team,partnership,SUM(total_runs) AS total_runs
FROM (SELECT season,match_id, batting_team, `over` AS over_no, 
SUM(batsman_runs) AS partnership, SUM(batsman_runs) + SUM(extra_runs) AS total_runs
FROM deliveries 
JOIN matches 
ON deliveries.match_id = matches.id
GROUP BY season, match_id, batting_team, over_no) AS team_scores
GROUP BY season, batting_team, partnership) AS highest_partnership
GROUP BY season, batting_team
LIMIT 0, 1000;

-- Q10: How many extras(wides and no balls) were bowled by each team in each match?
SELECT m.id AS match_no,d.bowling_team,
SUM(d.extra_runs) AS extras
FROM matches AS m
JOIN deliveries AS d 
ON d.match_id=m.id
WHERE extra_runs>0
GROUP BY m.id,d.bowling_team;

-- Q11: Which bowler has the best bowling figures( Most wickets taken) in a single match?
SELECT m.id AS match_no,d.bowler,COUNT(*) AS wickets_taken
FROM matches AS m
JOIN deliveries AS d 
ON d.match_id=m.id
WHERE d.player_dismissed IS NOT NULL
GROUP BY m.id,d.bowler
ORDER BY wickets_taken DESC
LIMIT 1;

-- Q12: How many matches resulted in a win for each team in each city?
SELECT m.city,
CASE WHEN m.team1 = m.winner THEN m.team1
	 WHEN m.team2 = m.winner THEN m.team2
     ELSE 'draw'
     END AS winning_team,
    COUNT(*) AS wins
FROM matches AS m
WHERE m.result != 'Tie' 
GROUP BY m.city, winning_team;

-- Q13: How many times did each team win the toss in each season?
SELECT season, toss_winner, COUNT(*) AS toss_wins
FROM matches
GROUP BY season, toss_winner;

-- Q14: How many matches did each player win the "Player Of The Match" Award?
SELECT player_of_match, COUNT(*) AS total_wins
FROM matches
WHERE player_of_match IS NOT NULL
GROUP BY player_of_match
ORDER BY total_wins DESC;

-- Q15: What is the average number of runs scored in each over of the innings in each match?
SELECT m.id, d.inning, d.over, 
AVG(d.total_runs) AS Avg_runs_per_over
FROM matches AS m
JOIN deliveries AS d
ON m.id = d.match_id 
GROUP BY m.id, d.inning, d.over;

-- Q16: Which team has the highest total score in a single match?
SELECT  m.season,m.id AS match_no,d.batting_team,
SUM(d.total_runs) AS total_score
FROM matches AS m
JOIN deliveries AS d 
ON d.match_id=m.id
GROUP BY m.season,m.id,d.batting_team
ORDER BY total_score DESC
LIMIT 1;

-- Q17: Which batsman has scored the most runs in a signal match?
SELECT m.season, m.id AS match_id, d.batsman,
SUM(d.batsman_runs) AS Total_Runs
FROM matches AS m
JOIN deliveries AS d
ON m.id = d.match_id
GROUP BY m.season, m.id, d.batsman
ORDER BY Total_Runs DESC
LIMIT 1;














