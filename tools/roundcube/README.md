
# Forrás

Ezt a fájlt kell átmásolni a tools/rouncube könyvtárba, eben vannak a kontakotk. 

mysqldump roundcube2 contacts users > /tmp/roundcube_data.sql


## Kihez hány kontakt van a rendszerben?

SELECT 
    u.username, 
    COUNT(c.contact_id) AS cnt
FROM users u
JOIN contacts c ON u.user_id = c.user_id
WHERE c.del = 0
GROUP BY u.user_id
ORDER BY COUNT(c.contact_id) DESC;

drkatonaeva@eastlink.hu kontaktjainak lekérdezése

SELECT 
    c.name, 
    c.firstname, 
    c.surname, 
    c.email 
FROM contacts c
JOIN users u ON c.user_id = u.user_id
WHERE u.username = 'drkatonaeva@eastlink.hu' 
  AND c.del = 0
ORDER BY c.surname, c.firstname;

