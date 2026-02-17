FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Csomagok telepítése
RUN apt-get update && apt-get install -y \
    dovecot-imapd \
    dovecot-pop3d \
    dovecot-sqlite \
    dovecot-lmtpd \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Vmail felhasználó létrehozása
RUN groupadd -g 90 vmail \
 && useradd -r -u 90 -g 90 -d /var/mail -s /bin/false vmail \
 && mkdir -p /var/mail \
 && chown -R vmail:vmail /var/mail

# KRITIKUS: Teljes takarítás - ne maradjanak gyári konfig töredékek
RUN rm -rf /etc/dovecot/*

# Alap könyvtárak létrehozása
RUN mkdir -p /var/log/dovecot /var/run/dovecot /var/mail && \
    chown dovecot:dovecot /var/log/dovecot /var/run/dovecot && \
    chown vmail:vmail /var/mail

# Csak a sablonokat másoljuk be (így nem kerül be véletlenül a conf.d)
COPY conf/dovecot.conf.template /tmp
COPY conf/dovecot-sql.conf.ext /etc/dovecot
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]