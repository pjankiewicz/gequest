/*
calculates distance to the airport in asdi position
*/

#CREATE FUNCTION calc_distance_udf RETURNS REAL SONAME "calc_distance_udf.so";
ALTER TABLE asdiposition_clean ADD COLUMN distance_to_airport float;

-- 1h
UPDATE 
	flightquest.asdiposition_clean as a
	INNER JOIN flighthistory as b
		ON a.dt = b.dt and a.flighthistoryid = b.flight_history_id
	INNER JOIN mapping_airports as c
		ON b.arrival_airport_icao_code = c.airport_code
SET	
	a.distance_to_airport = calc_distance_udf(a.latitudedegrees,a.longitudedegrees,c.latitude,c.longitude)
WHERE
	c.latitude IS NOT NULL and c.longitude IS NOT NULL;

SET @FLIGHT := 'xxx';
DROP TABLE IF EXISTS asdiposition_clean_dynamics;
CREATE TABLE asdiposition_clean_dynamics
as
SELECT
	@NEW_FLIGHT := CASE WHEN flighthistoryid <> @FLIGHT THEN 1 ELSE 0 END as new_flight,
	-- normal columns
	id, dt, @FLIGHT:=flighthistoryid as flighthistoryid
	-- flight dynamics
   ,@SPEED_MA_10 := CASE WHEN @NEW_FLIGHT = 1 THEN groundspeed ELSE round(@SPEED_MA_10*0.9 + groundspeed*0.1,4) END as speed_ma_10
   ,@SPEED_MA_25 := CASE WHEN @NEW_FLIGHT = 1 THEN groundspeed ELSE round(@SPEED_MA_25*0.75 + groundspeed*0.25,4) END as speed_ma_25
   ,@SPEED_MA_50 := CASE WHEN @NEW_FLIGHT = 1 THEN groundspeed ELSE round(@SPEED_MA_50*0.5 + groundspeed*0.50,4) END as speed_ma_50
   ,@SPEED_MA_75 := CASE WHEN @NEW_FLIGHT = 1 THEN groundspeed ELSE round(@SPEED_MA_75*0.25 + groundspeed*0.75,4) END as speed_ma_75
   ,@ALTITUDE_MA_10 := CASE WHEN @NEW_FLIGHT = 1 THEN altitude ELSE round(@ALTITUDE_MA_10*0.9 + altitude*0.1,4) END as altitude_ma_10
   ,@ALTITUDE_MA_25 := CASE WHEN @NEW_FLIGHT = 1 THEN altitude ELSE round(@ALTITUDE_MA_25*0.75 + altitude*0.25,4) END as altitude_ma_25
   ,@ALTITUDE_MA_50 := CASE WHEN @NEW_FLIGHT = 1 THEN altitude ELSE round(@ALTITUDE_MA_50*0.5 + altitude*0.50,4) END as altitude_ma_50
   ,@ALTITUDE_MA_75 := CASE WHEN @NEW_FLIGHT = 1 THEN altitude ELSE round(@ALTITUDE_MA_75*0.25 + altitude*0.75,4) END as altitude_ma_75
FROM asdiposition_clean
WHERE groundspeed > 50;

CREATE UNIQUE INDEX I ON asdiposition_clean_dynamics (id);
