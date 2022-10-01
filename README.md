# Project Description

This project consists of several SQL queries on a relational flights database. <br>
The data in this database is abridged from the Bureau of Transportation Statistics. <br> 
The database consists of four tables regarding a subset of flights that took place in 2015:

```SQL
FLIGHTS (fid int, 
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
         )
         
CARRIERS (cid varchar(7), name varchar(83))
MONTHS (mid int, month varchar(9))
WEEKDAYS (did int, day_of_week varchar(9))
```

Constraints to the tables above:
- The primary key of the `FLIGHTS` table is `fid`.
- The primary keys for the other tables are `cid`, `mid`, and `did` respectively. Other than these, *do not assume any other attribute(s) is a key / unique across tuples.*
- `Flights.carrier_id` references `Carrier.cid`
- `Flights.month_id` references `Months.mid`
- `Flights.day_of_week_id` references `Weekdays.did`

The flights database is provided as a set of plain-text data files in the linked `.tar.gz` archive. <br>
Each file in this archive contains all the rows for the named table, one row per line. <br>
Checkout `Part1` and `Part2` directories to look at queries performed on the flights database.