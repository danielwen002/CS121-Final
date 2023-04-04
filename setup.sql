-- drop existing tables if they already exist
DROP TABLE IF EXISTS song_chart_totals;
DROP TABLE IF EXISTS song_chart_info_streams;
DROP TABLE IF EXISTS playlist_songs;
DROP TABLE IF EXISTS songs;
DROP TABLE IF EXISTS user_playlist;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS playlists;

-- this table holds information about the users
CREATE TABLE users (
    -- unique identifier of the user
    user_uri CHAR(22) NOT NULL,
    user_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (user_uri)
);

-- this table holds information about the playlists
CREATE TABLE playlists (
    playlist_uri CHAR(22) NOT NULL,
    playlist_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (playlist_uri)
);

-- this table holds information about the playlists that users have
CREATE TABLE user_playlist (
    -- unique identifier of the playlist
    playlist_uri CHAR(22) NOT NULL,
    user_uri CHAR(22) NOT NULL,
    PRIMARY KEY (playlist_uri),
	FOREIGN KEY (user_uri) REFERENCES users(user_uri)
        ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (playlist_uri) REFERENCES playlists(playlist_uri)
        ON UPDATE CASCADE ON DELETE CASCADE        
);

-- this table holds the title of the songs
CREATE TABLE songs (
    -- unique identifier of the song
    song_uri CHAR(22) NOT NULL,
    song_title VARCHAR(50) NOT NULL,
	artist VARCHAR(40) NOT NULL,
    PRIMARY KEY (song_uri)
);

-- this table holds information about the songs in a playlist
CREATE TABLE playlist_songs (
    song_uri CHAR(22) NOT NULL,
    playlist_uri CHAR(22) NOT NULL,
    PRIMARY KEY (song_uri, playlist_uri),
    FOREIGN KEY (song_uri) REFERENCES songs(song_uri)
        ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (playlist_uri) REFERENCES user_playlist(playlist_uri)
        ON UPDATE CASCADE ON DELETE CASCADE
);


-- this table holds information about the songs on the charts
CREATE TABLE song_chart_info_streams (
    -- ranking on the charts
    song_rank INT NOT NULL,
    -- date of the chart
    chart_date DATE NOT NULL,
    -- region of the chart
    region VARCHAR(30) NOT NULL,
    -- type of chart
    chart_type VARCHAR(20) NOT NULL,
    song_uri CHAR(22) NOT NULL,
    -- number of streams in that region
    num_streams INT ,
	PRIMARY KEY (song_rank, chart_date, region, chart_type),
    FOREIGN KEY (song_uri) REFERENCES songs(song_uri) 
	    ON UPDATE CASCADE ON DELETE CASCADE
);


-- this table holds information about the playlists that users have
CREATE TABLE song_chart_totals (
    -- unique identifier of the playlist
    song_uri CHAR(22) NOT NULL,
	chart_date DATE NOT NULL,
    num_charts INT NOT NULL,
    total_streams BIGINT NOT NULL,
    PRIMARY KEY (song_uri),
    FOREIGN KEY (song_uri) REFERENCES songs(song_uri)
        ON UPDATE CASCADE ON DELETE CASCADE
);
