-- Import all the data from Part 1 (i.e. move the data files in Part 2 directory).
-- The data used in this part is the same as that in Part 1, in the flights-small.csv, carriers.csv, months.csv, and weekdays.csv files.

-- Do some SELECT count(*) statements to check whether your imports are successful:
-- Carriers has 1594 rows
-- Months has 12 rows
-- Weekdays has 8 rows
-- Flights has 1148675 rows

-- Those are basically imported in Part 1.
-- If these tables don't exist in your machine, import the flight database again. 

-- Creating tables and importing data:
-- After cloning the CS 174A repo from github, open command prompt in current directory and use the commands to extract and import the data onto the corresponding tables:
 
	tar zxvf flights-small.tar.gz -- Extract content of flights-small.tar.gz in current directory

        create table flights(fid int, 
                             month_id int,        -- 1-12
                             day_of_month int,    -- 1-31 
                             day_of_week_id int,  -- 1-7, 1 = Monday, 2 = Tuesday, etc
                             carrier_id varchar(7), 
                             flight_num int,
                             origin_city varchar(34), 
                             origin_state varchar(47),                               
			     dest_city varchar(34), 
                             dest_state varchar(46), 
                             departure_delay int, -- in mins
                             taxi_out int,        -- in mins
                             arrival_delay int,   -- in mins
                             canceled int,        -- 1 means canceled
                             actual_time int,     -- in mins
                             distance int,        -- in miles
                             capacity int, 
                             price int            -- in $             
                             );

	create table carriers(cid varchar(7), name varchar(83));
        create table months(mid int, month varchar(9));
        create table weekdays(did int, day_of_week varchar(9)); 

	PRAGMA foreign_keys=ON;
          
        .mode csv
        .import flights-small.csv flights
        .import months.csv months
        .import weekdays.csv weekdays

-- Question 1:
-- For each origin city, find the destination city (or cities) with the longest direct flight. 
-- By direct flight, we mean a flight with no intermediate stops. 
-- Judge the longest flight in time, not distance.
-- Name the output columns origin_city, dest_city, and time representing the the flight time between them. 
-- Do not include duplicates of the same origin/destination city pair. 
-- Order the result by origin_city and then dest_city (ascending, i.e. alphabetically).

	select distinct f2.origin_city, f2.dest_city, f2.actual_time as time
        from FLIGHTS as f2, (select f.origin_city, MAX(actual_time) as maximum
        from FLIGHTS as f group by f.origin_city) as f1
        where f2.origin_city = f1.origin_city
        and f1.maximum = f2.actual_time
        order by f2.origin_city, f2.dest_city asc;

	-- Number of rows in the query result: 334

-- Output (first 20 rows):
--         "Aberdeen SD","Minneapolis MN",106
--         "Abilene TX","Dallas/Fort Worth TX",111
--         "Adak Island AK","Anchorage AK",471
--         "Aguadilla PR","New York NY",368
--         "Akron OH","Atlanta GA",408
--         "Albany GA","Atlanta GA",243
--         "Albany NY","Atlanta GA",390
--         "Albuquerque NM","Houston TX",492
--         "Alexandria LA","Atlanta GA",391
--         "Allentown/Bethlehem/Easton PA","Atlanta GA",456
--         "Alpena MI","Detroit MI",80
--         "Amarillo TX","Houston TX",390
--         "Anchorage AK","Barrow AK",490
--         "Appleton WI","Atlanta GA",405
--         "Arcata/Eureka CA","San Francisco CA",476
--         "Asheville NC","Chicago IL",279
--         "Ashland WV","Cincinnati OH",84
--         "Aspen CO","Los Angeles CA",304
--         "Atlanta GA","Honolulu HI",649
--         "Atlantic City NJ","Fort Lauderdale FL",212


-- Question 2:
-- Find all origin cities that only serve flights shorter than 3 hours. 
-- You can assume that flights with NULL actual_time are not 3 hours or more.
-- Name the output column city and sort them. List each city only once in the result.

	select distinct f1.origin_city as city
        from FLIGHTS as f1
        where f1.origin_city not in (select distinct f.origin_city as city
        from FLIGHTS as f
        where f.actual_time >= 180)
        order by f1.origin_city;

	-- Number of rows in the query result: 109

-- Output (first 20 rows):
--         "Aberdeen SD"
--         "Abilene TX"
--         "Alpena MI"
--         "Ashland WV"
--         "Augusta GA"
--         "Barrow AK"
--         "Beaumont/Port Arthur TX"
--         "Bemidji MN"
--         "Bethel AK"
--         "Binghamton NY"
--         "Brainerd MN"
--         "Bristol/Johnson City/Kingsport TN"
--         "Butte MT"
--         "Carlsbad CA"
--         "Casper WY"
--         "Cedar City UT"
--         "Chico CA"
--         "College Station/Bryan TX"
--         "Columbia MO"
--         "Columbus GA"


-- Question 3:
-- For each origin city, find the percentage of departing flights shorter than 3 hours. 
-- For this question, treat flights with NULL actual_time values as no longer than 3 hours.
-- Name the output columns origin_city and percentage Order by percentage value, ascending. 
-- Be careful to handle cities without any flights shorter than 3 hours. Value 0 or NULL are acceptable as the result for those cities. 
-- Report percentages as percentages not decimals (e.g., report 75.25 rather than 0.7525).

	select f.origin_city as origin_city, 
        (CAST(ct AS FLOAT(10, 2)) * 100/ CAST(count(f.fid) 
        AS FLOAT(10, 2))) as percentage
        from Flights f
        LEFT JOIN (select origin_city, count(fid) ct
        from Flights 
        where actual_time < 180.0 OR (actual_time IS NULL)
        group by origin_city) c
        ON f.origin_city = c.origin_city
        group by f.origin_city, ct
        order by percentage ASC;

	-- Number of rows in the query result: 327

-- Output (first 20 rows):
--         "Guam TT",
--         "Pago Pago TT",
--         "Aguadilla PR",29.4339622641509
--         "Anchorage AK",32.1460373998219
--         "San Juan PR",33.890360709191
--         "Charlotte Amalie VI",40.0
--         "Ponce PR",41.9354838709677
--         "Fairbanks AK",50.6912442396313
--         "Kahului HI",53.664998528113
--         "Honolulu HI",54.9088086922778
--         "San Francisco CA",56.3076568265683
--         "Los Angeles CA",56.6041076487252
--         "Seattle WA",57.7554165533497
--         "Long Beach CA",62.4541164132145
--         "Kona HI",63.2821075740944
--         "New York NY",63.481519772551
--         "Las Vegas NV",65.163009288384
--         "Christiansted VI",65.3333333333333
--         "Newark NJ",67.1373555840822
--         "Worcester MA",67.741935483871
