# Kyle McCandless and Daniel Wen
# kmccandl@caltech.edu and dwen@caltech.edu
"""
Runs the command line interactive interface for the Songz application.
Allows users to choose from a menu of questions about a database of
songs and displays the results.
"""

import sys
import mysql.connector
import mysql.connector.errorcode as errorcode

DEBUG = False


def get_conn():
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    """
    try:
        conn = mysql.connector.connect(
          host='localhost',
          user='songz_admin',
          port='3306',
          password='kyleheartdaniel333',
          database='songzdb'
        )
        print('Successfully connected.')
        return conn
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr('Incorrect username or password when connecting to DB.')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr('Database does not exist.')
        elif DEBUG:
            sys.stderr(err)
        else:
            sys.stderr('An error occurred, please contact the administrator.')
        sys.exit(1)



# Functions for Query Execution for clients

def by_region():
    '''
    Displays the number of songs on the top charts by region.
    '''
    cursor = conn.cursor()

    sql = '''
SELECT user_name, playlist_name, chart_date, region, 
    COUNT(song_uri) AS region_count
FROM user_playlist NATURAL JOIN playlist_songs 
    NATURAL JOIN song_chart_info_streams NATURAL JOIN users 
    NATURAL JOIN playlists
GROUP BY user_name, playlist_name, chart_date, region;'''

    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred. Please contact the administrator.')

    if not rows:
        print('No results found.')
    else:
        print(f'Total number of songs on the top charts by region:')
        for row in rows:
            print(row)

def many_streams():
    '''
    For each playlist and chart date, find the number of songs in the 
    playlist that were "popping" (had more than 500k streams in a region)
    '''
    cursor = conn.cursor()

    sql = '''
    SELECT playlist_name, chart_date, COUNT(DISTINCT song_uri) AS num_popping
FROM playlist_songs NATURAL JOIN song_chart_info_streams 
    NATURAL JOIN songs NATURAL JOIN playlists
WHERE num_streams >= 500000
GROUP BY playlist_name, chart_date;'''

    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred. Please contact the administrator.')
        
    if not rows:
        print('No results found.')
    else:
        print(f'Songs that were popping:')
        for row in rows:
            print(row)

def avg_ranking():
    '''
    Displays the average ranking over all regions for each song on the
    top charts.
    '''
    cursor = conn.cursor()

    sql = '''
SELECT song_title, artist, chart_date, AVG(song_rank) AS average_ranking
FROM songs NATURAL JOIN song_chart_info_streams 
GROUP BY song_title, artist, chart_date
ORDER BY average_ranking;'''

    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred. Please contact the administrator.')

    if not rows:
        print('No results found.')
    else:
        print(f'Average ranking over all regions for all songs:')
        for row in rows:
            print(row)

def num_top_5_streams():
    '''
    For each region, count the number of streams across top 5 songs
    '''
    cursor = conn.cursor()

    sql = '''
    WITH top_five AS 
(SELECT region, chart_date, SUM(num_streams) AS top_five_streams
FROM song_chart_info_streams
WHERE song_rank <= 5
GROUP BY region, chart_date)
SELECT region, AVG(top_five_streams) AS avg_top_five_streams
FROM top_five
GROUP BY region
ORDER BY avg_top_five_streams DESC;'''

    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred. Please contact the administrator.')
        
    if not rows:
        print('No results found.')
    else:
        print(f'Total streams across top 5 songs:')
        for row in rows:
            print(row)


# Functions for Query Execution for admins
def admin_add_new_account():
    '''
    Prompts the user for a username and password and adds a new account
    with these values.
    '''
    
    cursor = conn.cursor()

    usr = input('    Enter admin username: ').lower()
    password = input('    Enter admin password: ').lower()
    sql = '''CALL sp_add_user('%s', '%s');''' % (usr, password)

    try:
        cursor.execute(sql)
        print('\n\nNew user added!')
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('Error adding account. Try again with debug = True')

def admin_change_account_password():
    '''
    Prompts the user for a username and password and updates the 
    username's password.
    '''
    
    cursor = conn.cursor()

    usr = input('    Enter admin username: ').lower()
    password = input('    Enter new password: ').lower()
    sql = '''CALL sp_change_password('%s', '%s');''' % (usr, password)

    try:
        cursor.execute(sql)
        print('\n\nPassword change attempted.')
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('Error updating account. Try again with debug = True')

def admin_add_chart_song():
    '''
    Prompts the admin for the song_rank, chart_date, region, chart_type,
    song_uri, and num_streams of a song on a top chart and adds this to
    the database.
    '''
    
    cursor = conn.cursor()

    song_rank = input('    Enter song rank: ').lower()
    chart_date = input('    Enter chart date (YYYY-MM-DD): ').lower()
    region = input('    Enter region: ').lower()
    chart_type = input('    Enter chart type: ').lower()
    song_uri = input('    Enter song Spotify uri: ').lower()
    num_streams = input('    Enter number of streams: ').lower()
    song_title = input('    Enter song title: ').lower()
    artist = input('    Enter artist name: ').lower()

    sql1 = '''
INSERT INTO songs VALUES ('%s', '%s', '%s');''' % (song_uri, song_title, artist)
    sql2 = '''
INSERT INTO song_chart_info_streams VALUES (%s, '%s', '%s', '%s', '%s', %s);
''' % (song_rank, chart_date, region, chart_type, song_uri, num_streams)

    try:
        cursor.execute(sql1)
        cursor.execute(sql2)
        print('\n\nSuccessfully added!')
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('Error adding song. Try again with debug = True')


# Functions for Logging Users In
def login_screen():
    """
    Handles user log in. Allows clients to log in with no username or
    password needed, but requires admin to know a valid username and password.
    """

    cursor = conn.cursor()

    print('\n\nWelcome to Songz!\n-----------------------------')
    print('What would you like to do?')

    while True:
        print('  (1) log in as a client')
        print('  (2) log in as an administrator')
        print('  (q) quit')

        choice = input().lower()
        if choice == '2':
            usr = input('    Enter admin username: ').lower()
            password = input('    Enter admin password: ').lower()
            sql = '''SELECT authenticate('%s', '%s');''' % (usr, password)

            try:
                cursor.execute(sql)
                correct = cursor.fetchone()
                if correct[0] == 1:
                    admin = True
                    break
                else:
                    print('Username or password incorrect, please try again.')
            except mysql.connector.Error as err:
                if DEBUG:
                    sys.stderr(err)
                    sys.exit(1)
                else:
                    sys.stderr('Log in error. Try again with debug = True')    
        elif choice == '1':
            admin = False
            break
        elif choice == 'q':
            quit_ui()
        else:
            print('Invalid input, please try again:')
           
    if admin:
        print('\n\nWelcome, administrator.')
        show_admin_options()
    else:
        print("\n\nWelcome, client.")
        show_options()


# Command-Line Functionality
def show_options():
    """
    Displays options users can choose in the application, such as viewing
    number of streams for a given song or playlist.
    """

    while True:
        print('What would you like to do?')
        print('  (1) - see information about popular songs by region')
        print('  (2) - get a playlist\'s number of songs with >500k streams')
        print('  (3) - get a song\'s average ranking over all regions')
        print('  (4) - get the number of streams for top 5 songs by region')
        print('  (q) - quit')

        ans = input('Enter an option: ').lower()
        if ans == 'q':
            quit_ui()
        elif ans == '1':
            by_region()
        elif ans == '2':
            many_streams()
        elif ans == '3':
            avg_ranking()
        elif ans == '4':
            num_top_5_streams()

def show_admin_options():
    """
    Displays options specific for admins, such as adding or removing a
    playlist or song.
    """

    while True:
        print('What would you like to do? ')
        print('  (1) add new administrator')
        print('  (2) change the password of an existing account')
        print('  (3) add a song from the charts')
        print('  (q) - quit')
        print()
        ans = input('Enter an option: ').lower()
        if ans == 'q':
            quit_ui()
        elif ans == '1':
            admin_add_new_account()
        elif ans == '2':
            admin_change_account_password()
        elif ans == '3':
            admin_add_chart_song()

def quit_ui():
    """
    Quits the program, printing a good bye message to the user.
    """
    print('''\nWe hope you learned a little bit about the world's music!
Peace out ~ Songz''')
    exit()

def main():
    """
    Main function for starting things up.
    """
    login_screen()


if __name__ == '__main__':
    conn = get_conn()
    main()
