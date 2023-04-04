-- UDF #1
DELIMITER !

-- Given a region, returns 1 if the region is United States or Canada, 0 if not
CREATE FUNCTION is_US_or_Canada (r VARCHAR(30)) RETURNS TINYINT DETERMINISTIC
BEGIN
IF r = 'United States' OR r = 'Canada'
   THEN RETURN 1;
ELSE RETURN 0;
END IF;
END !
DELIMITER ;

-- UDF #2
-- Given: Set the "end of statement" character to ! so we don't confuse MySQL
DELIMITER !

-- Given a date value, returns 1 if song had more than half million streams
-- in a region, 0 if not
CREATE FUNCTION is_popping (s INT) RETURNS TINYINT DETERMINISTIC
BEGIN
IF s >= 500000
   THEN RETURN 1;
ELSE RETURN 0;
END IF;
END !
DELIMITER ;


DELIMITER !

CREATE PROCEDURE sp_song_stat_add_song(
    new_song_rank INT ,
    new_chart_date DATE,
    new_region VARCHAR(30),
    new_chart_type VARCHAR(20),
    new_song_uri CHAR(22),
    new_num_streams INT
)
BEGIN 
    INSERT INTO song_chart_totals 
        -- branch not already in view; add row
        VALUES (new_song_uri, new_chart_date, 1, new_num_streams)
    ON DUPLICATE KEY UPDATE 
        -- branch already in view; update existing row
        num_charts = num_charts + 1,
        total_streams = total_streams + new_num_streams;
END !

-- Handles new rows added to account table, updates stats accordingly
CREATE TRIGGER trg_account_insert AFTER INSERT
       ON song_chart_info_streams FOR EACH ROW
BEGIN
    CALL sp_song_stat_add_song(NEW.song_rank, NEW.chart_date, NEW.region,
        NEW.chart_type, NEW.song_uri, NEW.num_streams);
END !

DELIMITER ;