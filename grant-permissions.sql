CREATE USER 'songz_admin'@'localhost' IDENTIFIED BY 'kyleheartdaniel333';
CREATE USER 'songz_client'@'localhost' IDENTIFIED BY 'songz';

-- Can add more users or refine permissions
GRANT ALL PRIVILEGES ON songzdb.* TO 'songz_admin'@'localhost';
GRANT SELECT ON songzdb.* TO 'songz_client'@'localhost';
FLUSH PRIVILEGES;
