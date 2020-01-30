CREATE INDEX K ON flighthistoryevents_transformed (dt,flight_history_id,date_time_recorded_mins) USING BTREE;

DROP TABLE IF EXISTS flighthistory_cutoffs_all_flights;
CREATE TABLE flighthistory_cutoffs_all_flights
as
SELECT
	a.dt
	,a.flight_history_id
	,a.event_type
	,b.cutoff_hour
	,MAX(date_time_recorded_utc) as last_record_time
FROM
	flighthistoryevents_transformed as a
	-- INNER JOIN flighthistory as c
	-- 	ON a.dt = c.dt and a.flight_history_id = c.flight_history_id
	INNER JOIN cutoff_hours as b
		on a.date_time_recorded_mins < b.cutoff_hour and a.date_time_recorded_mins >= 0 -- today's observations
WHERE
	event_type IN ('ERA','EGA','ERD','EGD')
	-- (b.cutoff_hour < in_mins(c.scheduled_runway_departure,c.dt)+120 and event_type IN ('ERD','EGD'))
	-- or
	-- (b.cutoff_hour < in_mins(c.scheduled_runway_arrival,c.dt)+120 and event_type IN ('ERA','EGA'))
GROUP BY
	 a.dt
	,a.flight_history_id
	,a.event_type
	,b.cutoff_hour;

ALTER TABLE flighthistory_cutoffs_all_flights ADD COLUMN estimation float;

CREATE INDEX i on flighthistory_cutoffs_all_flights (dt, flight_history_id, event_type, last_record_time);

/*
create table flighthistory_cutoffs_all_flights_ like flighthistory_cutoffs_all_flights;
insert into flighthistory_cutoffs_all_flights_ select * from flighthistory_cutoffs_all_flights;
*/

-- this is a loop that processes 1 date at each time - not exceeding the locks
DROP PROCEDURE IF EXISTS loop_dates;
DELIMITER $$

CREATE PROCEDURE loop_dates()
READS SQL DATA
BEGIN
  DECLARE my_dt date;

  -- Declare variables used just for cursor and loop control
  DECLARE no_more_rows BOOLEAN;
  DECLARE loop_cntr INT DEFAULT 0;
  DECLARE num_rows INT DEFAULT 0;

  -- Declare the cursor
  DECLARE dates CURSOR FOR
    SELECT DISTINCT dt FROM flightquest.flighthistory_cutoffs_all_flights;

  -- Declare 'handlers' for exceptions
  DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET no_more_rows = TRUE;

  -- 'open' the cursor and capture the number of rows returned
  -- (the 'select' gets invoked when the cursor is 'opened')
  OPEN dates;
  select FOUND_ROWS() into num_rows;

  the_loop: LOOP

    FETCH  dates
    INTO   my_dt;

    -- break out of the loop if
      -- 1) there were no records, or
      -- 2) we've processed them all
    IF no_more_rows THEN
        CLOSE dates;
        LEAVE the_loop;
    END IF;

    -- the equivalent of a 'print statement' in a stored procedure
    -- it simply displays output for each loop
    UPDATE flighthistory_cutoffs_all_flights as a
	INNER JOIN flighthistoryevents_transformed as b
		ON a.dt = b.dt 
		   and a.flight_history_id = b.flight_history_id 
		   and a.event_type = b.event_type 
		   and b.date_time_recorded_utc = a.last_record_time
	SET
		a.estimation = in_mins(new_dt_utc,a.dt)
	WHERE
		a.dt = my_dt;

    -- count the number of times looped
    SET loop_cntr = loop_cntr + 1;

  END LOOP the_loop;

END$$

DELIMITER ;

call loop_dates();

-- arrivals model
DROP TABLE IF EXISTS estimated_traffic_arrivals;
CREATE TABLE estimated_traffic_arrivals
as
SELECT
	 a.dt
	,b.arrival_airport_icao_code
	,a.cutoff_hour
	,a.event_type
	,round(in_mins(c.new_dt_utc,a.dt)/10.0,0)*10 as time_rounded
	,COUNT(*) as flights_count
FROM
	flighthistory_cutoffs_all_flights as a
	INNER JOIN flighthistoryevents_transformed as c
		ON a.dt = c.dt and a.flight_history_id = c.flight_history_id and c.date_time_recorded_utc = a.last_record_time and c.event_type = a.event_type
	INNER JOIN flighthistory as b
		ON a.dt = b.dt and a.flight_history_id = b.flight_history_id
WHERE
	a.event_type IN ('ERA','EGA')
GROUP BY
	 a.dt
	,b.arrival_airport_icao_code
	,a.cutoff_hour
	,a.event_type
	,round(in_mins(c.new_dt_utc,a.dt)/10.0,0)*10;

CREATE UNIQUE INDEX I ON estimated_traffic_arrivals (dt, arrival_airport_icao_code, cutoff_hour, event_type, time_rounded);

-- departures
DROP TABLE IF EXISTS estimated_traffic_departures;
CREATE TABLE estimated_traffic_departures
as
SELECT
	 a.dt
	,b.departure_airport_icao_code
	,a.cutoff_hour
	,a.event_type
	,round(in_mins(c.new_dt_utc,a.dt)/10.0,0)*10 as time_rounded
	,COUNT(*) as flights_count
FROM
	flighthistory_cutoffs_all_flights as a
	INNER JOIN flighthistoryevents_transformed as c
		ON a.dt = c.dt and a.flight_history_id = c.flight_history_id and c.date_time_recorded_utc = a.last_record_time and c.event_type = a.event_type
	INNER JOIN flighthistory as b
		ON a.dt = b.dt and a.flight_history_id = b.flight_history_id
WHERE
	a.event_type IN ('ERD','EGD')
GROUP BY
	 a.dt
	,b.departure_airport_icao_code
	,a.cutoff_hour
	,a.event_type
	,round(in_mins(c.new_dt_utc,a.dt)/10.0,0)*10;

CREATE UNIQUE INDEX I ON estimated_traffic_departures (dt, departure_airport_icao_code, cutoff_hour, event_type, time_rounded);
