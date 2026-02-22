#!/bin/bash
# sqlite3 ../docker/data/var/roundcube/sqlite.db < ./sqldata/import_clean.sql

# 1. Tisztítás (hogy ne legyen duplikáció)
docker run --rm -v "$(pwd)/../../docker/data/var/roundcube":/db_folder -w /db_folder alpine sh -c "apk add --no-cache sqlite && sqlite3 sqlite.db \"DELETE FROM contacts WHERE user_id = (SELECT user_id FROM users WHERE username = 'feri@koczka.hu');\""

# 2. Betöltés a javított fájlból
docker run --rm \
  -v "$(pwd)/sqldata":/sqldata \
  -v "$(pwd)/../../docker/data/var/roundcube":/db_folder \
  -w /db_folder \
  alpine sh -c "
    apk add --no-cache sqlite && \
    echo '--- Felhasználó ellenőrzése ---' && \
    sqlite3 sqlite.db \"INSERT OR IGNORE INTO users (username, mail_host, created, language) VALUES ('feri@koczka.hu', 'localhost', datetime('now'), 'hu_HU');\" && \
    echo '--- Importálás folyamatban ---' && \
    sqlite3 sqlite.db < /sqldata/import_clean.sql && \
    echo '--- KÉSZ! Beimportált kontaktok: ---' && \
    sqlite3 sqlite.db \"SELECT COUNT(*) FROM contacts WHERE user_id = (SELECT user_id FROM users WHERE username = 'feri@koczka.hu');\"
  "
