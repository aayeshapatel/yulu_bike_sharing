show databases;
use bike_sharing ;
desc station;
select count(*) from station ;

-- since the trip data has 669959 rows which is considerabl;yu large and hence using below approach 
select count(*) from trip ; 

show GLOBAL VARIABLES like 'local_infile';
SET GLOBAL local_infile = 'ON' ;
show GLOBAL VARIABLES like 'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/jakir/OneDrive/Desktop/ayesha_MSc/project_files/sql_bike_sharing_dataset/trip.csv'
INTO TABLE trip
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from trip limit  20; 

use bike_sharing ;
select count(*) from trip;
 
-- analysis begins :

-- What are the total numbers of:
-- Bike stations?

SELECT COUNT(DISTINCT id) AS total_no_of_stations 
FROM station ;

-- Bikes?
select count(distinct bike_id) as total_bikes from trip;
-- answer : 700
-- Trips?
SELECT COUNT(DISTINCT id ) AS total_trips from trip_data ;



-- T1.(Q3). the relationship between the following columns (one to one, many to one, many to many)?
-- Q3(1).bike_id (Trip table) and start_station_id (Trip table)-  
-- ANSWER: many to many
-- Q3(2).pincode (Weather table) and station location (latitude and longitude in Station table)
-- ANSWER: NONE
-- Q3(3). 8/29/2013 (date column in Weather table) and mean wind speed (Weather table)
-- ANSWER: ONE TO ONE 


-- T1.(Q4).Find the first and the last trip in the data.
desc trip ;
-- since the start date and end date column are of data tyupe text hence have to chanc[ge their data type in appropriate format

UPDATE trip
SET start_date = STR_TO_DATE(start_date, '%m/%d/%Y %H:%i');

ALTER TABLE trip 
MODIFY COLUMN start_date DATETIME ;

update trip 
set end_date =STR_TO_DATE(end_date, '%m/%d/%Y %H:%i') ; 
ALTER TABLE trip 
modify column end_date DATETIME ;  

select * from  trip limit 10 ;

-- Select the information for the first trip
SELECT "First Trip" as Trip_Number,
       id,start_date, end_date,bike_id
FROM trip,
     (SELECT MIN(start_date) as min_start_date
      FROM trip) as min_trip_table
WHERE start_date = min_trip_table.min_start_date
UNION
-- Select the information for the last trip
SELECT "Last Trip" as Trip_Number, id,start_date,
       end_date,
       bike_id
FROM trip,
     (SELECT MAX(start_date) as max_start_date
      FROM trip) as max_trip_table
WHERE start_date = max_trip_table.max_start_date;

-- T1(Q5.1) what is the average duration Of all the trips
 select avg(duration) as avg_duration from trip ;
 
 -- T1( Q5.2) average duration Of trips on which customers are ending their rides at the same station from where they started 
select avg(duration) from trip where start_station_name = end_station_name;



-- T1(Q6).which bike has been used the most in terms of duration?
select bike_id , sum(duration) as total_duration_of_bike  from trip 
group by bike_id 
order by  total_duration_of_bike desc limit  1 ;

-- TASK 2.(Q1).What are the top 10 least popular stations? Hint: Find the least frequently appearing start stations from the Trip table.

select start_station_name ,
count(start_station_name) as freq_of_start_station 
from trip
group by start_station_name 
order by freq_of_start_station asc limit 10 ;


-- Task 2 - Demand Prediction
-- Idle time is the duration for which a station remains inactive. You can consider this as the time for which a station has more than 3 bikes available.
-- Q2(1) - Find the idle time for Station 2 on the date '2013/08/29'
 SELECT 
    station_id,
    MIN(time) as idle_start_time,
    MAX(time) as idle_end_time,
    TIMEDIFF(MAX(time), MIN(time)) as idle_duration
FROM
    status
WHERE
    station_id = 2
    AND bikes_available >= 3
    AND DATE(time) = '2013-08-29'
GROUP BY
    station_id, DATE(time), HOUR(time) ;
 
 
 -- Calculate the average number of bikes and docks available for Station 2. 
 SELECT round(AVG(bikes_available)) as avg_bikes , 
 round(AVG(docks_available)) as avg_docks  
 from status 
 where station_id = 2 
 group by station_id;

