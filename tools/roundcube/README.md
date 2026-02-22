## Kihez hány kontakt van a rendszerben?
```
  SELECT 
      u.username, 
      COUNT(c.contact_id) AS cnt
  FROM users u
  JOIN contacts c ON u.user_id = c.user_id
  WHERE c.del = 0
  GROUP BY u.user_id
  ORDER BY COUNT(c.contact_id) DESC;
  ```

  ```
  +------------------------------------------+-----+
  | username                                 | cnt |
  +------------------------------------------+-----+
  | fanczal.mariann@burda.hu                 | 178 |
  | kovacs.eniko@reanimatio.com              | 126 |
  | molnar@emsico.hu                         | 120 |
  | info@szepesmariaalapitvany.hu            | 110 |
  | office@reanimatio.com                    | 103 |
  | rdm@hotelpresident.hu                    | 100 |
  | hackl.laura@mom.e-vital.hu               |  93 |
  | laszlo.meszaros@techbridge.hu            |  79 |
  | csonka.janos@karrierista.hu              |  62 |
  | danyi.dia@jobanrosszban.hu               |  45 |
  | info@karrierista.hu                      |  43 |
  | hackl.laura@hegyv.e-vital.hu             |  42 |
  | muszak@hotelpresident.hu                 |  42 |
  | beszerzes@hotelpresident.hu              |  40 |
  | marketing@hotelpresident.hu              |  39 |
  | burai@kiskapitalis.hu                    |  27 |
  | hackl.laura@corvin.e-vital.hu            |  26 |
  | tech@hotelpresident.hu                   |  26 |
  ```

drkatonaeva@eastlink.hu kontaktjainak lekérdezése

  ```
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
  ```

## Migráció

1. forrás gépen elkészítjük az e-mail címeket és a hozzájuk tartozó dumpokat.
   
  ```
  NEWSERVER=corega.halation.hu
  mysqldump roundcube2 contacts users > roundcube_data.sql
  scp -P 65061 roundcube_data.sql root@${NEWSERVER}:/tmp
  ```

2. Cél gépen importáljuk az adatbázisba

  ```
  cd /var/docker/webmail.halation.hu/rc-import    
  cp /tmp/roundcube_data.sql .
  ```

  Az import porgramban állítsd be a rouncdube sqlite adatbázisának helyét, és a mail domaint, különben a userek duplikálódni fognak. Nézd meg az export fájlban, hogy ott mi van:
  ```
  RCDB="../sqlite/sqlite.db"
  HOST="mail.halation.hu"
  ```  

