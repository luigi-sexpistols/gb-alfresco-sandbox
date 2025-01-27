CREATE USER IF NOT EXISTS '${username}'@'%' IDENTIFIED BY '${password}';
GRANT ALL PRIVILEGES ON `${database}`.* TO '${username}'@'%';
