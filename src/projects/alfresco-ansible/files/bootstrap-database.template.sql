-- mysql's "CREATE USER IF NOT EXISTS" is much better than this monstrosity...

DO $f$ BEGIN
  EXECUTE (
    SELECT 'CREATE USER ${username} WITH ENCRYPTED PASSWORD ''${password}'';'
    WHERE NOT EXISTS (SELECT FROM pg_user WHERE username = '${username}')
  );

  EXECUTE (
    SELECT 'CREATE DATABASE ${database} OWNER ${username} ENCODING ''utf-8'';'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${database}');
  );
END $f$;
