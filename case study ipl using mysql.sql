create database case_ipl;
use case_ipl;

-- 1. Create a table named 'matches' with appropriate data types for columns 
-- 3. Import data from csv file 'IPL_matches.csv'attached in resources to 'matches'
-- 6. Select the top 20 rows of the matches table. 

select * from matches limit 20;

select replace(date,"/","-") from matches;

create table deliveries
(id	int,
inning	int,
overs	int,
ball	int,
batsman	varchar(50),
non_striker	varchar(50),
bowler	varchar(50),
batsman_runs	int,
extra_runs	int,
total_runs	int,
is_wicket	int,
dismissal_kind	varchar(50),
player_dismissed	varchar(50),
fielder	varchar(50),
extras_type	varchar(50),
batting_team	varchar(100),
bowling_team	varchar(100),
venue	varchar(100),
match_date char(20)
);

-- 2. Create a table named 'deliveries' with appropriate data types for columns 
-- 4. Import data from csv file 'IPL_Ball.csv' attached in resources to 'deliveries'
-- 5. Select the top 20 rows of the deliveries table.  

select * from deliveries limit 20;

-- 7. Fetch data of all the matches played on 2nd May 2013.

select *,ifnull(str_to_date(date,"%d-%m-%Y"), ifnull(str_to_date(date,"%d/%m/%Y"),"no date"))
from matches
where  ifnull(str_to_date(date,"%d-%m-%Y"), ifnull(str_to_date(date,"%d/%m/%Y"),"no date")) = "2013-05-02";

-- 7. another way
select date, if(date like "%/%", str_to_date(date,"%d/%m/%Y"), str_to_date(date,"%d-%m-%Y"))
from matches;

--  8. Fetch data of all the matches where the margin of victory is more than 100 runs. 

select * 
from matches
where result = "runs" and result_margin > 100;


-- 9. Fetch data of all the matches where the final scores of both teams tied and 
-- order it in descending order of the date. 

select * from matches
where result = "tie"
order by if(date like "%/%", str_to_date(date,"%d/%m/%Y"),str_to_date(date,"%d-%m-%Y")) desc;


-- 10. Get the count of cities that have hosted an IPL match. 

select city, count(*) as citycnt
from matches
group by city
order by citycnt desc;


-- 11. Create table deliveries_v02 with all the columns of deliveries and an additional column 
-- ball_result containing value boundary, dot or other depending on the total_run 
-- (boundary for >= 4, dot for 0 and other for any other number) 

create view deliveries_v02 as 
select *,
case when total_runs >= 4 then "boundary" 
	 when total_runs = 0 then "dot"
     else "other"
     end as ball_result
from deliveries;

select * from deliveries_v02;


-- 12. Write a query to fetch the total number of boundaries and dot balls 

select ball_result, count(*) as total
from deliveries_v02 
group by ball_result
having ball_result <> "other";

select ball_result, count(*) as Total
from deliveries_v02
where ball_result in ("boundary","dot")
group by ball_result;


-- 13. Write a query to fetch the total number of boundaries scored by each team 

select batting_team,count(*) no_of_boundary
from deliveries_v02
where ball_result = "boundary"
group by batting_team
order by no_of_boundary desc;


-- 14. Write a query to fetch the total number of dot balls bowled by each team 

select bowling_team,count(*) dot_ball
from deliveries_v02
where ball_result = "dot"
group by bowling_team
order by dot_ball desc;


-- 15. Write a query to fetch the total number of dismissals by dismissal kinds

select dismissal_kind,count(*)
from deliveries_v02 
group by dismissal_kind
having dismissal_kind <> "na";


-- 16. Write a query to get the top 5 bowlers who conceded maximum extra runs 

select bowler,sum(extra_runs) as extraconceed
from deliveries_v02
where extras_type <> "NA"
group by bowler
order by 2 desc limit 5;


-- 17. Write a query to create a table named deliveries_v03 with all the columns of 
-- deliveries_v02 table and two additional column (named venue and match_date) of venue 
-- and date from table matches 

create view deliveries_v03 as 
select d.*, m.venue as venue_03, m.date as match_date_03 
from deliveries_v02 d inner join matches m using(id);

select * from deliveries_v03;

drop view  deliveries_v03;

-- 18. Write a query to fetch the total runs scored for each venue and order it 
-- in the desc order of total runs scored. 

select venue,sum(total_runs) as venue_runs
from deliveries_v03
group by venue
having venue <> ""
order by 2 desc;


-- 19. Write a query to fetch the year-wise total runs scored at Eden Gardens and order it 
-- in the desc order of total runs scored. 

select venue, year(str_to_date(replace(match_date,"/","-"),"%d-%m-%Y")) as yr, sum(total_runs)
from deliveries_v03
where venue = "eden gardens"
group by year(str_to_date(replace(match_date,"/","-"),"%d-%m-%Y"))
order by sum(total_runs) desc;


-- 20. Get unique team1 names from the matches table, you will notice that there are two entries for 
-- Rising Pune Supergiant one with Rising Pune Supergiant and another one with Rising Pune Supergiants. 
-- Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr 
-- containing team names with replacing Rising Pune Supergiants with Rising Pune Supergiant. 
-- Now analyse these newly created columns. 

select distinct team1 from matches;

create view matches_corrected as 
select team1, team2, 
if(team1 = "Rising Pune Supergiants", "Rising Pune Supergiant", team1) as team1_corr,
if(team2 = "Rising Pune Supergiants", "Rising Pune Supergiant", team2) as team2_corr
from matches;

select distinct team1_corr from matches_corrected;
select distinct team2_corr from matches_corrected;

-- 21. Create a new table deliveries_v04 with the first column as ball_id containing information of 
-- match_id, inning, over and ball separated by'(For ex. 335982-1-0-1 match_idinning-over-ball) and 
-- rest of the columns same as deliveries_v03) 


create view deliveries_v04 as 
select concat_ws("-",id,inning,overs,ball) as ball_id,
batsman, non_striker, bowler,batsman_runs, extra_runs, total_runs, 
is_wicket, dismissal_kind, fielder, extras_type, batting_team, bowling_team, 
venue, match_date, ball_result, venue_03, match_date_03 from deliveries_v03;

select * from deliveries_v04;

drop view deliveries_v04;


-- 22. Compare the total count of rows and total count of distinct ball_id in deliveries_v04; 

select count(ball_id), count(distinct ball_id) from deliveries_v04;


-- 23. Create table deliveries_v05 with all columns of deliveries_v04 and an addi column for row number partition over ball_id.  


create view deliveries_v05 as 
select *, 
row_number() over (partition by ball_id) as r_num
from deliveries_v04;

select * from deliveries_v05;

drop view deliveries_v05;


-- 24. Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating. 


select ball_id from deliveries_v05 where r_num = 2;


-- 25. Use subqueries to fetch data of all the ball_id which are repeating. 


select * from deliveries_v05 
where ball_id in 
(select ball_id from deliveries_v05 where r_num = 2);




