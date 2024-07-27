-- Creating tables and importing data:

-- Open command prompt in current directory and use the commands to extract and import the data onto the corresponding tables:
 
	--tar zxvf flights-small.tar.gz -- This extracts content of flights-small.tar.gz in current directory

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
-- List the distinct flight numbers of all flights from Seattle to Boston by Alaska Airlines Inc. on Mondays. 
-- Also notice that, in the database, the city names include the state. So Seattle appears as Seattle WA. 
-- Please use the flight_num column instead of fid. Name the output column flight_num.

	select distinct flight_num as flight_num
        from flights, carriers, weekdays
        where flights.carrier_id = carriers.cid
        and weekdays.did = flights.day_of_week_id
        and flights.origin_city = 'Seattle WA' 
        and flights.dest_city = 'Boston MA' 
        and carriers.name = 'Alaska Airlines Inc.'
        and weekdays.day_of_week = 'Monday';

	-- Number of rows in the query result: 3

-- Question 2:
-- Find all itineraries from Seattle to Boston on July 15th. 
-- Search only for itineraries that have one stop (i.e., flight 1: Seattle -> [somewhere], flight2: [somewhere] -> Boston). 
-- Both flights must depart on the same day (same day here means the date of flight) and must be with the same carrier. 
-- It's fine if the landing date is different from the departing date (i.e., in the case of an overnight flight). 
-- You don't need to check whether the first flight overlaps with the second one since the departing and arriving time of the flights are not provided.
-- The total flight time (actual_time) of the entire itinerary should be fewer than 7 hours (but notice that actual_time is in minutes). 
-- For each itinerary, the query should return the name of the carrier, the first flight number, the origin and destination of that first flight, 
-- the flight time, the second flight number, the origin and destination of the second flight, the second flight time, and finally the total flight time. 
-- Only count flight times here; do not include any layover time.
-- Name the output columns name as the name of the carrier, f1_flight_num, f1_origin_city, f1_dest_city, f1_actual_time, f2_flight_num, f2_origin_city, 
-- f2_dest_city, f2_actual_time, and actual_time as the total flight time. List the output columns in this order.

	select C.name as name,
	F1.flight_num as f1_flight_num,
        F1.origin_city as f1_origin_city,
        F1.dest_city as f1_dest_city,
        F1.actual_time as f1_actual_time,
        F2.flight_num as f2_flight_num,
        F2.origin_city as f2_origin_city,
        F2.dest_city as f2_dest_city,
        F2.actual_time as f2_actual_time,
        F1.actual_time + F2.actual_time as actual_time
        from flights as F1, flights as F2, months as M, carriers as C
        where F1.dest_city = F2.origin_city
        and F1.origin_city = 'Seattle WA'
        and F2.dest_city = 'Boston MA'
        and F1.month_id = M.mid
        and F2.month_id = M.mid
        and F1.carrier_id = C.cid
        and F2.carrier_id = C.cid
        and F1.carrier_id = F2.carrier_id
        and M.month = 'July'
        and F1.day_of_month = 15
        and F2.day_of_month = 15
        and (F1.actual_time + F2.actual_time) < 420;

	-- Number of rows in the query result: 1472

-- Question 3:
-- Find the day of the week with the longest average arrival delay. Return the name of the day and the average delay.
-- Name the output columns day_of_week and delay, in that order. (Hint: consider using LIMIT. Look up what it does!)

	select W.day_of_week as day_of_week, avg(F.arrival_delay) as delay
        from flights as F, weekdays as W
        where F.day_of_week_id = W.did
        group by W.day_of_week
        limit 1;

	-- Number of rows in the query result: 1

-- Question 4:
-- Find the names of all airlines that ever flew more than 1000 flights in one day (i.e., a specific day/month, but not any 24-hour period). 
-- Return only the names of the airlines. Do not return any duplicates (i.e., airlines with the exact same name).
-- Name the output column name.

	select distinct C.name as name
        from flights as F, carriers as C, months as M
        where F.carrier_id = C.cid
        and F.month_id = M.mid
        group by C.name, M.month, F.day_of_month
        having count(*) > 1000;

	-- Number of rows in the query result: 12

-- Question 5:
-- Find all airlines that had more than 0.5 percent of their flights out of Seattle be canceled. 
-- Return the name of the airline and the percentage of canceled flight out of Seattle. 
-- Order the results by the percentage of canceled flights in ascending order.
-- Name the output columns name and percent, in that order.

	select C.name as name, avg(F.canceled) as percent
        from flights as F, carriers as C
        where F.carrier_id = C.cid
        and F.origin_city = 'Seattle WA'
        group by C.name
        having avg(F.canceled) > 0.005;

	-- Number of rows in the query result: 6

-- Question 6:
-- Find the maximum price of tickets between Seattle and New York, NY (i.e. Seattle to NY or NY to Seattle). 
-- Show the maximum price for each airline separately.
-- Name the output columns carrier and max_price, in that order.

	select C.name as carrier, max(F.price) as max_price
        from flights as F, carriers as C
        where F.carrier_id = C.cid
        and ((F.origin_city = 'Seattle WA' and F.dest_city = 'New York NY') or (F.dest_city = 'Seattle WA' and F.origin_city = 'New York NY'))
        group by C.name;

	-- Number of rows in the query result: 3

-- Question 7:
-- Find the total capacity of all direct flights that fly between Seattle and San Francisco, CA on July 10th (i.e. Seattle to SF or SF to Seattle).
-- Name the output column capacity.

	select sum(F.capacity) as capacity
        from flights as F, months as M
        where F.month_id = M.mid
        and ((F.origin_city = 'Seattle WA' and F.dest_city = 'San Francisco CA') or (F.dest_city = 'Seattle WA' and F.origin_city = 'San Francisco CA'))
        and M.month = 'July'
        and F.day_of_month = 10;

	-- Number of rows in the query result: 1

-- Question 8:
-- Compute the total departure delay of each airline across all flights. 
-- Some departure delays may be negative (indicating an early departure); they should reduce the total, so you don't need to handle them specially.
-- Name the output columns name and delay, in that order.

	select C.name as name, sum(F.departure_delay) as delay
	from flights as F, carriers as C
	where F.carrier_id = C.cid
	group by C.name;

	-- Number of rows in the query result: 22