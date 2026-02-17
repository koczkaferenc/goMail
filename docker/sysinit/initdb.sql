PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    password TEXT,
    admin INTEGER NOT NULL DEFAULT 0,
    realname TEXT NOT NULL,
    info TEXT DEFAULT ""
);
CREATE TABLE tokens (
    token TEXT PRIMARY KEY,
    userid int NOT NULL,
    FOREIGN KEY (userid) REFERENCES users(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS domains (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    domain TEXT UNIQUE,
    mboxlimit integer NOT NULL DEFAULT 100
);
CREATE TABLE ud (
    userid INTEGER NOT NULL,
    domainid INTEGER NOT NULL,
    UNIQUE(userid, domainid),
    FOREIGN KEY (userid) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (domainid) REFERENCES domains(id) ON DELETE CASCADE				
);
CREATE TABLE IF NOT EXISTS mboxes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    localpart TEXT NOT NULL,
    domain TEXT NOT NULL,
    password TEXT NOT NULL,
    name TEXT DEFAULT NULL,
    home TEXT NOT NULL,
    uid INTEGER NOT NULL DEFAULT 90,
    gid INTEGER NOT NULL DEFAULT 90,
    validfrom TEXT DEFAULT CURRENT_TIMESTAMP,
    validuntil TEXT DEFAULT NULL,
    enabled INTEGER NOT NULL DEFAULT 1,
    forwardto TEXT DEFAULT NULL,
    copyto TEXT DEFAULT NULL,
    vacationstart TEXT DEFAULT CURRENT_TIMESTAMP,
    vacationend TEXT DEFAULT NULL,
    vacationsub TEXT DEFAULT NULL,
    vacationmsg TEXT DEFAULT NULL,
    mboxsize INTEGER DEFAULT 0,
    lastlogged TEXT DEFAULT NULL,
    lastprotocol TEXT DEFAULT NULL,
    UNIQUE(localpart, domain),
    FOREIGN KEY (domain) REFERENCES domains(domain) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE IF NOT EXISTS aliases (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    localpart TEXT,
    domain TEXT,
    addresses TEXT,
    UNIQUE(localpart, domain),
    FOREIGN KEY (domain) REFERENCES domains(domain) ON DELETE CASCADE ON UPDATE CASCADE				
);
-- Jelszó: nagyonTitkos
INSERT INTO users (username, password, admin, realname) VALUES ('koczka.ferenc','d66e86e76b313e42bfdd95fb6c2dabd69a049e4cd23de7ddf5315513f9ae68fc',1, 'Koczka Ferenc');
-- INSERT INTO domains (domain) VALUES ('linux-szerver.hu');
-- INSERT INTO domains (domain) VALUES ('agrialanc.hu');
-- INSERT INTO domains (domain) VALUES ('boronafog.hu');
-- INSERT INTO domains (domain) VALUES ('iparigorgoslanc.hu');
-- INSERT INTO domains (domain) VALUES ('sebe.hu');
-- INSERT INTO domains (domain) VALUES ('pppress.hu.hu');
-- INSERT INTO ud (userid, domainid) VALUES (1,1);
-- INSERT INTO ud (userid, domainid) VALUES (2,2);
-- INSERT INTO ud (userid, domainid) VALUES (2,3);
-- INSERT INTO ud (userid, domainid) VALUES (2,4);
-- 
-- INSERT INTO ud (userid, domainid) VALUES (3,2);
-- INSERT INTO ud (userid, domainid) VALUES (3,5);
-- INSERT INTO ud (userid, domainid) VALUES (3,6);
-- 
-- INSERT INTO mboxes (localpart, domain, password, home) VALUES ('info','linux-szerver.hu','d66e86e76b313e42bfdd95fb6c2dabd69a049e4cd23de7ddf5315513f9ae68fc', '/var/mail/linux-szerver.hu/info/Maildir');
-- INSERT INTO mboxes (localpart, domain, password, home) VALUES ('test','linux-szerver.hu','d66e86e76b313e42bfdd95fb6c2dabd69a049e4cd23de7ddf5315513f9ae68fc', '/var/mail/linux-szerver.hu/test/Maildir');
-- INSERT INTO mboxes (localpart, domain, password, home) VALUES ('nagyagnes','agrialanc.hu','d66e86e76b313e42bfdd95fb6c2dabd69a049e4cd23de7ddf5315513f9ae68fc', '/var/mail/agrialanc.hu/nagyagnes/Maildir');
-- INSERT INTO mboxes (localpart, domain, password, home) VALUES ('agria','agrialanc.hu','d66e86e76b313e42bfdd95fb6c2dabd69a049e4cd23de7ddf5315513f9ae68fc', '/var/mail/agrialanc.hu/agria/Maildir');
-- 
-- INSERT INTO aliases (localpart, domain, addresses) VALUES ('allas','linux-szerver.hu','info@linux-szerver.hu');
-- INSERT INTO aliases (localpart, domain, addresses) VALUES ('allas','agrialanc.hu','info@agrialanc.hu');