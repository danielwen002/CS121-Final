Welcome to Songz, a SQL based application to get information and statistics about your favorite songs and playlists.


How to start it up:
—————————————————————————————————————————
Open command line and go to the root directory of our project.
Log in to mysql. Make sure to SET GLOBAL local_infile = ‘ON’ and/or start mysql with --local-infile=1
mysql> CREATE DATABASE songzdb;
mysql> USE songzdb;
mysql> source setup.sql;
mysql> source load-data.sql;
mysql> source setup-passwords.sql;
mysql> source setup-routines.sql;
mysql> source grant-permissions.sql;
mysql> source queries.sql;
mysql> quit;
$ python3 app.py

This will start up the Python based User Interface for the project, which has directions for how to log in and starting learning!

PS, you can log in as an admin using: Kyle notmypassword


Background information:
—————————————————————————————————————————
We tried to use this dataset https://www.kaggle.com/dhruvildave/spotify-charts but it was too massive for our computer (froze and crashed upon trying to open), so we generated data by hand.

No files will be written to the user’s system.