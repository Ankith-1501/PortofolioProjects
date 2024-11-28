SELECT * from dbo.Cleaned_ff_race_50

--How many States where represented in the race

Select Count(Distinct State) as distinct_state
from dbo.Cleaned_ff_race_50

-- How many Male and Female were in the marathon
Select Gender, Count(*) as Runner_count_gender
from dbo.Cleaned_ff_race_50 group by Gender

--what was thje average time of Male vs Female

Select Gender, AVG(Total_Minutes) as AVG_time
from dbo.Cleaned_ff_race_50 group by Gender

--What were the youngest, oldest and average ages in the race

Select Gender,
	MIN(Age) as Youngest,
	Max(Age) as Oldest,
	AVG(Age) as Avrage
from dbo.Cleaned_ff_race_50 group by Gender;

--What was the average time for each age group

with age_buckets as (
Select total_minutes,
	case when age < 30 then 'age_20-29'
		 when age < 40 then 'age_30-39'
		 when age < 50 then 'age_40-49'																																		
		 when age < 60 then 'age_50-59'
	else 'age_60+' end as age_group
from dbo.Cleaned_ff_race_50)

select age_group, avg(total_minutes) as avg_race_time 
from  age_buckets group by age_group;

--Top 3 Males and Females

with gender_rank as (
Select rank() over (partition by Gender order by Total_Minutes asc) as gender_rank,
Fullname,
Gender,
Total_Minutes
from dbo.Cleaned_ff_race_50
)

select * 
from  gender_rank
where gender_rank < 4
order by Total_Minutes

-- Count of runners by state
SELECT State, COUNT(*) as Runners_Count 
FROM dbo.Cleaned_ff_race_50 
GROUP BY State 
ORDER BY Runners_Count DESC 

-- States with the most representation
SELECT State, 
       COUNT(*) as Runners_Count, 
       ROUND(AVG(Total_Minutes), 2) as Avg_Completion_Time
FROM dbo.Cleaned_ff_race_50 
GROUP BY State 
ORDER BY Runners_Count DESC 

-- Top 10 fastest runners
SELECT TOP 10 Fullname, Age, Gender, Time, Total_Minutes
FROM dbo.Cleaned_ff_race_50
ORDER BY Total_Minutes ASC

-- Top 5 Best performing states (lowest average time)
SELECT TOP 5 State, 
ROUND(AVG(Total_Minutes), 2) as Avg_Completion_Time
FROM dbo.Cleaned_ff_race_50
GROUP BY State
HAVING Count(*) > 2
ORDER BY Avg_Completion_Time ASC

-- Performance by gender
SELECT 
    Gender, 
    ROUND(AVG(Total_Minutes), 2) as Avg_Time,
    MIN(Total_Minutes) as Fastest_Time,
    MAX(Total_Minutes) as Slowest_Time,
    COUNT(*) as Runners_Count
FROM dbo.Cleaned_ff_race_50
GROUP BY Gender;
