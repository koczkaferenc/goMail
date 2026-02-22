#!/bin/bash

# Változók behelyettesítése a sablonból
envsubst '${MAILDOMAIN} ${MAIL_HOST}' < /dovecot.conf.template > /etc/dovecot/dovecot.conf

# Master jelszó létrehozása
echo "adminuser:$(doveadm pw -s SHA512-CRYPT -p ${DOVECOT_MASTERPASSWORD})" > /etc/dovecot/master-users

# Maildir gyökér létrehozása
chown -R 90:90 /var/mail
chmod 750 /var/mail

# Jogosultságok fixálása a logokhoz
chown -R dovecot:dovecot /var/log/dovecot
chmod -R 750 /var/log/dovecot

# Ha a log fájlok nem léteznek, hozzuk létre
touch /var/log/dovecot/dovecot.log /var/log/dovecot/dovecot-info.log
chown dovecot:dovecot /var/log/dovecot/*.log

# Dovecot indítása az előtérben
exec dovecot -F