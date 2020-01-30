DROP PROCEDURE IF EXISTS dummy;
delimiter //
create procedure dummy() 
begin

IF column_exists('flightquest','flightstats_metarreports_combined','date_time_issued_mins') THEN
	ALTER TABLE flightstats_metarreports_combined DROP COLUMN date_time_issued_mins;
END IF;
ALTER TABLE flightstats_metarreports_combined ADD COLUMN date_time_issued_mins double;

UPDATE flightstats_metarreports_combined 
SET date_time_issued_mins = in_mins(date_time_issued,dt);

DROP TABLE IF EXISTS metarreports_max_record_time;
CREATE TABLE metarreports_max_record_time 
as
SELECT
	m.dt,
	m.weather_station_code,
    a.cutoff_hour,
	MAX(m.date_time_issued) as last_record_time
FROM 
	cutoff_hours as a
	INNER JOIN flightstats_metarreports_combined as m
		on m.date_time_issued_mins <= a.cutoff_hour
GROUP BY
	m.dt,
	m.weather_station_code,
    a.cutoff_hour;
CREATE UNIQUE INDEX I ON metarreports_max_record_time (dt, weather_station_code, cutoff_hour);

IF column_exists('flightquest','flighthistory_cutoffs','last_metar_report_id') THEN
	ALTER TABLE flighthistory_cutoffs DROP COLUMN last_metar_report_id;
END IF;
ALTER TABLE flighthistory_cutoffs ADD COLUMN last_metar_report_id int;

UPDATE flighthistory_cutoffs as a
	INNER JOIN flighthistory as f
		ON a.dt = f.dt and a.flight_history_id = f.flight_history_id
	INNER JOIN metarreports_max_record_time as b
		ON f.arrival_airport_icao_code = b.weather_station_code and 
		   a.dt = b.dt and 
		   b.cutoff_hour = a.cutoff_hour
	INNER JOIN flightstats_metarreports_combined as c
		ON a.dt = c.dt and 
		   b.last_record_time = c.date_time_issued and
		   b.weather_station_code = c.weather_station_code
SET 
	last_metar_report_id = c.metar_reports_id;

DROP TABLE metarreports_max_record_time;

end;
//
delimiter ;
call dummy();
drop procedure dummy;
