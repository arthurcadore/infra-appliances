USE infradb;

CREATE TABLE IF NOT EXISTS logs (
	    id INT AUTO_INCREMENT PRIMARY KEY,
	    datetime VARCHAR(16),
	    host VARCHAR(32),
	    source_ip VARCHAR(45),  
	    program VARCHAR(200),
	    pid VARCHAR(8),
	    message VARCHAR(200)
);

CREATE USER 'infrauser'@'%' IDENTIFIED BY 'Infra%%pass';
GRANT ALL PRIVILEGES ON infradb.* TO 'infrauser'@'%';
FLUSH PRIVILEGES;

