
-- Query #1
-- For each user, playlist, and chart date, find the total number of songs
-- that show up in a region's charts
SELECT user_name, playlist_name, chart_date, region, 
    COUNT(song_uri) AS region_count
FROM user_playlist NATURAL JOIN playlist_songs 
    NATURAL JOIN song_chart_info_streams NATURAL JOIN users 
    NATURAL JOIN playlists
GROUP BY user_name, playlist_name, chart_date, region;

-- Query #2
-- For each playlist and chart date, find the number of songs in the 
-- playlist that were "popping" (had more than 500k streams in a region)
SELECT playlist_name, chart_date, COUNT(DISTINCT song_uri) AS num_popping
FROM playlist_songs NATURAL JOIN song_chart_info_streams NATURAL JOIN playlists
WHERE num_streams >= 500000
GROUP BY playlist_name, chart_date;

-- Query #3
-- For each song and chart date, find the average ranking over all 
-- regions (where it is ranked)
SELECT song_title, artist, chart_date, AVG(song_rank) AS average_ranking
FROM songs NATURAL JOIN song_chart_info_streams 
GROUP BY song_title, artist, chart_date
ORDER BY average_ranking;

-- Query #4
-- For each region, count the number of streams across top 5 songs
SELECT region, SUM(num_streams) AS top_five_streams
FROM song_chart_info_streams
WHERE song_rank <= 5
GROUP BY region
ORDER BY top_five_streams DESC;