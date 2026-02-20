#!/bin/bash

# Konfiguráció
EMAIL="drkatonaeva@eastlink.hu"
DUMP_FILE="roundcube_data.sql"
OUTPUT_FILE="./sqldata/import_clean.sql"
DB_PASS="temp_pass"

# 1. Ideiglenes MySQL konténer indítása
echo "--- 1. MySQL kontener inditasa..."
docker run --name temp-db -e MYSQL_ROOT_PASSWORD=$DB_PASS -d mysql:8.0

# Várjunk, amíg a MySQL tényleg feláll (ez eltarthat 15-20 másodpercig)
echo "Varakozas az adatbazis elindulasara..."
until docker exec temp-db mysqladmin ping -h "localhost" -u root -p$DB_PASS --silent; do
    sleep 2
done

# 2. Adatbázis létrehozása és dump betöltése
echo "--- 2. Adatok betoltese (ez eltarthat egy ideig)..."
docker exec -i temp-db mysql -u root -p$DB_PASS <<< "CREATE DATABASE rc;"
docker exec -i temp-db mysql -u root -p$DB_PASS rc < "$DUMP_FILE"

# 3. Az SQLite-kompatibilis SQL legyártása
echo "--- 3. SQL exportalasa a(z) $EMAIL cimhez..."
mkdir -p ./sqldata

docker exec -i temp-db mysql -u root rc -N -s --default-character-set=utf8mb4 -e "
SELECT CONCAT(
    'INSERT INTO contacts (name, email, firstname, surname, vcard, user_id, changed) VALUES (', 
    QUOTE(IFNULL(name, '')), ',', 
    QUOTE(IFNULL(email, '')), ',', 
    QUOTE(IFNULL(firstname, '')), ',', 
    QUOTE(IFNULL(surname, '')), ',', 
    'REPLACE(', QUOTE(REPLACE(REPLACE(IFNULL(vcard, ''), '\r', ''), '^M', '')), ', \'\\\\n\', CHAR(10))', ',', 
    '(SELECT user_id FROM users WHERE username = \'$EMAIL\'),',
    'DATETIME(\'now\'));'
)
FROM contacts 
WHERE user_id = (SELECT user_id FROM users WHERE username = '$EMAIL') 
  AND del = 0;" > ./sqldata/import_clean.sql

# 4. Takarítás
echo "--- 4. Kontener leallitasa..."
docker rm -f temp-db

echo "--- KESZ! ---"
echo "Az importalhato fajl itt talalhato: $OUTPUT_FILE"