# goMail

Levelező és levelezés archiváló rendszer. 

## Felépítés

A rendszer két felépítésben működik, tűzfal mögött vagy közvetlen elérésű publikus IP-n.

## A rendszer összetevői

* Sqlite3 adatbázis
+ LetsEncrypt tanúsítványkezelő
* Dovecot IMAP/Pop3 szerver

    beletenni az utolsó protokollt és a bejelentkezések listáját
    doveadm pw -s SHA256-CRYPT -p titok

* ImapSync Levél letöltést végző szerver
    - profil: imapsync

* goMail adminisztrációs felület
* Exim4 SMTP szerver
* wg a PM Mail Gateway kapcsolathoz
÷ Logrotate
* Fail2Ban behatolás-megelőzés
* Kvóta, túlméretes postafiókokra figyelmeztető levél.

## Konfiguráció

A rendszer konfigurációja a .env fájlban van, elüször ezt kell kitölteni.

## Telepítés

A szükséges DNS bejegyzéseket, tanúsítványokat, dmarc, spf, dkim rekordokat és kulcsokat a prepareSystem program készíti el. A DNS-ben értelemszerűen nem tud rekordokat felvenni, ezt a telepítsé során kell megtenni, a prepareSystem minden ilyet jelez. A sikeres futás esetén az alábbiak jelennek meg a koczka.eu-s példában:

- Rendszer követelmények ellenőrzése és kialakítása -

    DNS rekordok ellenőrzése:
    - mta.koczka.eu: ✅ 5.189.184.116
    - wm.koczka.eu: ✅ 5.189.184.116
    - ma.koczka.eu: ✅ 5.189.184.116
    - autodiscover.koczka.eu: ✅ CNAME -> mta.koczka.eu
    - autoconfig.koczka.eu: ✅ CNAME -> mta.koczka.eu
    - Reverse DNS: ✅ 5.189.184.116
    
    Speciális DNS bejegyzések:
    - SPF rekord ellenőrzése: ✅ (5.189.184.116)
    - DKIM rekord ellenőrzése:  ✅ gomail._domainkey.koczka.eu
    - DMARC rekord ellenőrzése: ✅ "v=DMARC1; p=quarantine;"
    
    Tanúsítványok generálása:
    - Tanúsítvány: mta.koczka.eu ✅ (korábban generálva.)
    - Tanúsítvány: wm.koczka.eu ✅ (korábban generálva.)
    - Tanúsítvány: ma.koczka.eu ✅ (korábban generálva.)
    - Tanúsítvány: autodiscover.koczka.eu ✅ (korábban generálva.)
    - Tanúsítvány: autoconfig.koczka.eu ✅ (korábban generálva.)
    Adatbázis létrehozása:
    - Adatbázis: data/gomail.db ✅ (létrehozva.)

## IMAPSync

212.92.23.213:feri@koczka.hu:<JELSZO1>:dovecot:feri@koczka.hu:<JELSZO2>

# Master jelszó

# Címjegyzék importálása
