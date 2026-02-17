# goMail
Levelező rendszer

## A rendszer összetevői

* Sqlite3 adatbázis
* + LetsEncrypt tanúsítványkezelő
* Dovecot IMAP/Pop3 szerver

beletenni az utolsó protokollt és a bejelentkezések listáját
doveadm pw -s SHA256-CRYPT -p titok

* ImapSync Levél letöltést végző szerver
* goMail adminisztrációs felület
* Exim4 SMTP szerver
* Fail2Ban behatolás-megelőzés
* Kvóta, túlméretes postafiókokra figyelmeztető levél.

## Telepítés

**DMarc, DKim és SPF rekordok elkészítése**

**Tanúsítvány generálása**

Először el kell készíteni a szükséges tanúsítványokat, amelyet a
