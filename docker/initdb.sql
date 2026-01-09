
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logged_at TIMESTAMP DEFAULT NULL
);

-- 2. Domainek táblája
CREATE TABLE domains (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT, -- A tulajdonos felhasználó ID-ja
    name VARCHAR(255) NOT NULL UNIQUE,
    mailbox_limit INT DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 3. Mailboxok (Postafiókok) táblája
CREATE TABLE mailboxes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    domain_id INT NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    local_part VARCHAR(100) NOT NULL,
    domain VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,        -- A postafiók jelszava ( Dovecot/Postfix számára)
    home VARCHAR(255) NOT NULL,            -- Pl: /var/vmail/domain/user
    uid INT DEFAULT 5000,
    gid INT DEFAULT 5000,
    forward VARCHAR(255),                  -- Automatikus továbbítás
    copy_to VARCHAR(255),                  -- BCC másolat
    vacation_start DATETIME,
    vacation_end DATETIME,
    vacation_message TEXT,
    mbox_size INT DEFAULT 0,               -- Aktuális méret (Quota ellenőrzéshez)
    last_logged DATETIME,
    last_protocol VARCHAR(10),             -- IMAP/POP3
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,
    FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE,
    UNIQUE KEY idx_email (local_part, domain)
);

-- 4. Aliasok (Átirányítások) táblája
CREATE TABLE aliases (
    id INT PRIMARY KEY AUTO_INCREMENT,
    domain_id INT NOT NULL,
    local_part VARCHAR(100) NOT NULL,
    domain VARCHAR(255) NOT NULL,
    addresses TEXT NOT NULL,               -- Célcímek vesszővel elválasztva
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE
);

INSERT INTO users (name, email, password, enabled, admin)
    VALUES ('Rendszergazda', 'info@linux-szerver.hu', 'bRsT64%xT', 1, 1);
