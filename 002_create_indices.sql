# flight history
CREATE UNIQUE INDEX I ON flighthistory (dt, flight_history_id);

# flight history events
CREATE INDEX I ON flighthistoryevents_transformed (dt, flight_history_id, date_time_recorded, event_type);

# test flight
CREATE UNIQUE INDEX I ON test_flights_public (flight_history_id);

# asdiflightplan
CREATE UNIQUE INDEX I ON asdiflightplan (dt, flighthistoryid, updatetimeutc, asdiflightplanid);

# metar
CREATE UNIQUE INDEX I ON flightstats_metarreports_combined(dt,metar_reports_id);
CREATE INDEX J ON flightstats_metarreports_combined(dt,weather_station_code,date_time_issued);

CREATE INDEX I ON flightstats_metarpresentconditions_combined (dt,metar_reports_id);

# asdiairway
# CREATE UNIQUE INDEX I ON asdiairway (dt, asdiflightplanid, ordinal);

# asdiwaypoint
CREATE UNIQUE INDEX I ON asdifpwaypoint (dt, asdiflightplanid, ordinal);

# asdi position
CREATE INDEX I ON asdiposition (dt, flighthistoryid, received);

