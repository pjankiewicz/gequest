DROP TABLE IF EXISTS flighthistoryevents_transformed_airtime_temp;
CREATE TEMPORARY TABLE flighthistoryevents_transformed_airtime_temp
as 
SELECT 
	a.dt, 
	a.flight_history_id,
	a.date_time_recorded_utc, 
	MAX(CASE WHEN event_type IN ('ERD','ARD') THEN in_mins(new_dt_utc,a.dt) ELSE NULL END) as departure, 
	MAX(CASE WHEN event_type IN ('ERA') THEN in_mins(new_dt_utc,a.dt) ELSE NULL END) as runway_arrival, 
	MAX(CASE WHEN event_type IN ('EGA') THEN in_mins(new_dt_utc,a.dt) ELSE NULL END) as gate_arrival
FROM 
	flighthistoryevents_transformed as a
	INNER JOIN flighthistory as b
		ON a.dt = b.dt and a.flight_history_id = b.flight_history_id
WHERE
	event_type IN ('ERD','ARD','ERA','EGA')
GROUP BY
	a.dt, a.flight_history_id, a.date_time_recorded_utc
ORDER BY
	a.dt, a.flight_history_id, a.date_time_recorded_utc;

SET @OLD_FLIGHT_HISTORY := 'XXXXXXX';
SET @ID = 0;

DROP TABLE IF EXISTS flighthistoryevents_transformed_airtime;
CREATE TABLE flighthistoryevents_transformed_airtime
as
SELECT 
	@ID := @ID + 1 as id,
	dt, 
	@NEW_FLIGHT := CASE WHEN flight_history_id <> @OLD_FLIGHT_HISTORY THEN 1 ELSE 0 END as NEW_FLIGHT_ID,
	@OLD_FLIGHT_HISTORY := flight_history_id as flight_history_id, 
	in_mins(date_time_recorded_utc,dt) as date_time_recorded_utc, 
	@RUNNING_DEPARTURE := 0 + CASE WHEN @NEW_FLIGHT = 1 THEN departure ELSE COALESCE(departure,@RUNNING_DEPARTURE) END as departure, 
	@RUNNING_RUNWAY_ARRIVAL := 0 + CASE WHEN @NEW_FLIGHT = 1 THEN runway_arrival ELSE COALESCE(runway_arrival,@RUNNING_RUNWAY_ARRIVAL) END as runway_arrival, 
	@RUNNING_GATE_ARRIVAL := 0 + CASE WHEN @NEW_FLIGHT = 1 THEN gate_arrival ELSE COALESCE(gate_arrival,@RUNNING_GATE_ARRIVAL) END as gate_arrival, 
	@AIRTIME := @RUNNING_RUNWAY_ARRIVAL - @RUNNING_DEPARTURE as airtime,
	@TAXITIME := @RUNNING_GATE_ARRIVAL - @RUNNING_RUNWAY_ARRIVAL as taxitime,
	@MA_AIRTIME_75 := CASE WHEN @NEW_FLIGHT = 1 THEN @AIRTIME ELSE (0.75*@AIRTIME + 0.25*COALESCE(@MA_AIRTIME_75,@AIRTIME)) END as MA_AIRTIME_75,
	@MA_AIRTIME_50 := CASE WHEN @NEW_FLIGHT = 1 THEN @AIRTIME ELSE (0.50*@AIRTIME + 0.50*COALESCE(@MA_AIRTIME_50,@AIRTIME)) END as MA_AIRTIME_50,
	@MA_AIRTIME_25 := CASE WHEN @NEW_FLIGHT = 1 THEN @AIRTIME ELSE (0.25*@AIRTIME + 0.75*COALESCE(@MA_AIRTIME_25,@AIRTIME)) END as MA_AIRTIME_25

FROM 
	flighthistoryevents_transformed_airtime_temp
ORDER BY
	dt, flight_history_id, date_time_recorded_utc;

CREATE INDEX J ON flighthistoryevents_transformed_airtime (dt,flight_history_id,date_time_recorded_utc) USING BTREE;

DROP TABLE IF EXISTS flighthistoryevents_transformed_airtime_avg;
CREATE TABLE flighthistoryevents_transformed_airtime_avg
as
SELECT
	a.dt, 
	a.flight_history_id,
	b.cutoff_hour,
	AVG(CASE WHEN airtime < 10 THEN 10 ELSE airtime END) as avg_airtime,
	AVG(CASE WHEN taxitime < 2 THEN 2 ELSE taxitime END) as avg_taxitime,
	MAX(a.date_time_recorded_utc) as max_recorded_time
FROM
	flighthistoryevents_transformed_airtime as a
	INNER JOIN flighthistory_cutoffs as b	
		ON a.dt = b.dt 
		   and a.flight_history_id = b.flight_history_id 
		   and a.date_time_recorded_utc <= b.cutoff_hour
GROUP BY
	a.dt, 
	a.flight_history_id,
	b.cutoff_hour;

CREATE UNIQUE INDEX I ON flighthistoryevents_transformed_airtime_avg (dt,flight_history_id,cutoff_hour);

/*
SELECT round(MA_AIRTIME_75 / MA_AIRTIME_25,1),
	   sqrt(avg(power((ARD + avg_airtime) - T_ARA,2))) as err,
	   sqrt(avg(power((ARD + MA_AIRTIME_75) - T_ARA,2))) as err_75,
	   sqrt(avg(power((ARD + MA_AIRTIME_50) - T_ARA,2))) as err_50,
       sqrt(avg(power((ARD + MA_AIRTIME_25) - T_ARA,2))) as err_25,
	   sqrt(avg(power((ARD + avg_airtime + avg_taxitime) - T_AGA,2))) as err,
	   sqrt(avg(power((LAST_ERA_ASDI) - T_ARA,2))) as ASDI,
	   sqrt(avg(power((LAST_ERA_EVENTS) - T_ARA,2))) as `EVENTS`,
	   sqrt(avg(power((LAST_ERA_CASCADE) - T_ARA,2))) as `CASCADE`,
	   COUNT(*)
FROM avg_airtime_test as a
	 INNER JOIN data_v1 as b
		ON a.dt = b.T_dt and a.flight_historY_id = b.T_flight_history_id and a.cutoff_hour = b.cutoff_hour
	 INNER JOIN flighthistoryevents_transformed_airtime as c
		ON a.dt = c.dt and a.flight_historY_id = c.flight_history_id and a.max_recorded_time = c.date_time_recorded_utc
WHERE
	T_obs_type = 'Testing' and T_ARA IS NOT NULL
GROUP BY
	round(MA_AIRTIME_75 / MA_AIRTIME_25,1);

SELECT a.* FROM flighthistoryevents_transformed_airtime as a
INNER JOIN 
(
	SELECT T_dt, T_flight_history_id 
	FROM data_v1_mini 
	WHERE LAST_ERA_CASCADE_TYPE = 'E11' AND T_LEADERBOARD_PUBLIC = 1
) as b
 ON a.flight_history_id = b.T_flight_history_id and a.dt = b.T_dt

*/