-- Generates a specified number of characters for using as a salt in passwords
DELIMITER !
CREATE FUNCTION make_salt(num_chars INT) 
RETURNS VARCHAR(20) NOT DETERMINISTIC
BEGIN
    DECLARE salt VARCHAR(20) DEFAULT '';

    -- Don't want to generate more than 20 characters of salt.
    SET num_chars = LEAST(20, num_chars);

    -- Generate the salt!  Characters used are ASCII code 32 (space)
    -- through 126 ('z').
    WHILE num_chars > 0 DO
        SET salt = CONCAT(salt, CHAR(32 + FLOOR(RAND() * 95)));
        SET num_chars = num_chars - 1;
    END WHILE;

    RETURN salt;
END !
DELIMITER ;

-- This table holds information for authenticating users based on
-- a password.  Passwords are not stored plaintext so that they
-- cannot be used by people that shouldn't have them.
CREATE TABLE user_info (
    username VARCHAR(20) PRIMARY KEY,
    salt CHAR(8) NOT NULL,
    -- We use SHA-2 with 256-bit hashes
    password_hash BINARY(64) NOT NULL
);

-- [Problem 1a]
-- Adds a new user to the user_info table, using the specified password (max
-- of 20 characters)
DELIMITER !
CREATE PROCEDURE sp_add_user(new_username VARCHAR(20), password VARCHAR(20))
BEGIN
  DECLARE salt CHAR(8);
  DECLARE temp VARCHAR(28);
  DECLARE pass_hash BINARY(64);
  
  SET salt = make_salt(8);
  SET temp = CONCAT(salt, password);
  SET pass_hash = SHA2(temp, 256);
  INSERT INTO user_info VALUES (new_username, salt, pass_hash);
END !
DELIMITER ;

-- [Problem 1b]
-- Authenticates the specified username and password against the data
-- in the user_info table.  Returns 1 if the user appears in the table, and the
-- specified password hashes to the value for the user. Otherwise returns 0.
DELIMITER !
CREATE FUNCTION authenticate(usr VARCHAR(20), password VARCHAR(20))
RETURNS TINYINT DETERMINISTIC
BEGIN
  DECLARE s CHAR(8);
  DECLARE p_hash BINARY(64);
  DECLARE temp VARCHAR(28);
  
  IF NOT EXISTS(SELECT * FROM user_info WHERE username = usr) THEN
    RETURN 0;
  END IF;
  
  SELECT salt, password_hash INTO s, p_hash
  FROM user_info WHERE username = usr LIMIT 1;
  SET temp = CONCAT(s, password);
  
  IF SHA2(temp, 256) = p_hash THEN
    RETURN 1;
  END IF;
  
  RETURN 0;
END !
DELIMITER ;

-- [Problem 1c]
-- Add two users to the db
CALL sp_add_user('Kyle', 'notmypassword');
CALL sp_add_user('Daniel', 'dangerousDan123');

-- [Problem 1d]
-- Changes a users password in the user_info table to the new password (max
-- of 20 characters)
DELIMITER !
CREATE PROCEDURE sp_change_password(usr VARCHAR(20), pass VARCHAR(20))
BEGIN
  DECLARE salt CHAR(8);
  DECLARE temp VARCHAR(28);
  DECLARE pass_hash BINARY(64);
  
  SET salt = make_salt(8);
  SET temp = CONCAT(salt, pass);
  SET pass_hash = SHA2(temp, 256);
  
  UPDATE user_info SET salt = salt, password_hash = pass_hash
  WHERE username = usr;
END !
DELIMITER ;
