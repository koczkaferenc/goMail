#!/bin/bash
. .env
MAILSERVER_FQDN=${MAIL_HOST}.${MAILDOMAIN}
WEBMAIL_FQDN=${WEBMAIL_HOST}.${MAILDOMAIN}
MAILADMIN_FQDN=${MAILADMIN_HOST}.${MAILDOMAIN}
[ ! -d ${DATA_DIR} ] && mkdir -p ${DATA_DIR}
DATABASE_FILE=${DATA_DIR}/${DATABASE_NAME}
CURRENT_IP=$(curl -s https://ifconfig.me)

echo ""
echo "- Rendszer követelmények ellenőrzése és kialakítása -"
echo ""

# -----------------------------------------------------
# DNS rekordok ellenőrzése
# -----------------------------------------------------
echo "DNS rekordok ellenőrzése: "
for T in $MAILSERVER_FQDN $WEBMAIL_FQDN $MAILADMIN_FQDN ${MAILDOMAIN} ; do
    echo -n "  [?] $T: "
    RESOLVED_IP=$(dig @8.8.8.8 +short "$T")
    if [ -z "$RESOLVED_IP" ]; then
        echo "'A' rekord hiányzik: $T -> $CURRENT_IP"
        exit 4
    elif [ "$RESOLVED_IP" != "$CURRENT_IP" ]; then
        echo "'A' rekord hibás címre mutat: $T -> $RESOLVED_IP"
        exit 4
    else
        echo "✅ ${RESOLVED_IP}"
    fi          
done

# -----------------------------------------------------
# srv rekordok ellenőrzése
# -----------------------------------------------------
for S in _imaps:993 _submission:587 _autodiscover:443 ; do
  SRV=$(echo $S | cut -d: -f1)
  PORT=$(echo $S | cut -d: -f2)
  echo -n "  [?] ${SRV}._tcp.$MAILDOMAIN: "
  T="${SRV}._tcp.$MAILDOMAIN"
  SRV_REC=$(dig @8.8.8.8 +short SRV "$T")
  if [ -z "$SRV_REC" ]; then
    echo " hiányzik."
    echo "      [-] Beállítás: ${SRV}._tcp SRV 10 10 ${PORT} ${MAIL_HOST}.${MAILDOMAIN}"
    exit 9
  elif [[ ! "$SRV_REC" =~ "$MAIL_HOST" ]]; then
    echo " hibás címre mutat."
    echo "      [-] Beállítás: ${SRV}._tcp SRV 10 10 ${PORT} ${MAIL_HOST}.${MAILDOMAIN}"
    exit 9
  else
    echo "✅"
  fi
done


# -----------------------------------------------------
# autodiscover és autoconfig CNAME ellenőrzése
# -----------------------------------------------------
for T in autodiscover.${MAILDOMAIN} autoconfig.${MAILDOMAIN} ; do
    echo -n "  [?] $T: "
    RESOLVED_TARGET=$(dig @8.8.8.8 CNAME +short "$T" | sed 's/\.$//')
    if [ -z "$RESOLVED_TARGET" ]; then
        echo "a rekord nem létezik vagy nem CNAME."
        exit 5
    elif [ "$RESOLVED_TARGET" != "$MAILSERVER_FQDN" ]; then
        echo "a rekord célra mutat: $T -> $MAILSERVER_FQDN (most $RESOLVED_TARGET)"
        exit 4
    else
        echo "✅ CNAME -> $RESOLVED_TARGET"
    fi
done

# -----------------------------------------------------
# Reverse DNS ellenőrzése
# -----------------------------------------------------
echo -n "  [?] Reverse DNS: "
REVERSE_DNS=$(host "$CURRENT_IP" | awk '{print $NF}' | sed 's/\.$//')
if [ -z "$REVERSE_DNS" ] || [[ "$REVERSE_DNS" == *"not-found"* ]]; then
    echo "hiba. Az elvárt válasz: ${MAILSERVER_FQDN}"
    exit 5
elif [ "$REVERSE_DNS" != "$MAILSERVER_FQDN" ]; then
    echo "hiba. Az elvárt válasz: ${MAILSERVER_FQDN}"
    exit 6
else
    echo "✅ ${CURRENT_IP}"
fi

# -----------------------------------------------------
# SPF rekord ellenőrzése
# -----------------------------------------------------
echo "Speciális DNS bejegyzések:"
echo -n "  [?] SPF rekord ellenőrzése: "
SPF_IPS=$(dig +short TXT "$MAILDOMAIN" | grep "v=spf1" | grep -oE 'ip4:[^ ]+' | cut -d':' -f2)
FOUND=0
for IP in $SPF_IPS; do
    if [ "$IP" == "$CURRENT_IP" ]; then
        FOUND=1
        break
    fi
done
if [ $FOUND -eq 0 ]; then
    echo "    [-] Hiba."
    echo "    [-] A szerver IP címe (${CURRENT_IP}) nem szerepel a(z) ${MAILDOMAIN} SPF rekordjában!"
    echo "    [-] Készítsd el az alábbi rekordot: v=spf1 ip4:${CURRENT_IP} -all"
    exit 1
fi
echo "✅ (${CURRENT_IP})"

# -----------------------------------------------------
# DKIM ellenőrzése/előállítása
# -----------------------------------------------------
echo -n "  [?] DKIM rekord ellenőrzése: "
[ ! -d ${DATA_DIR}/etc/exim4 ] && mkdir -p ${DATA_DIR}/etc/exim4
PRIV_KEY="${DATA_DIR}/etc/exim4/dkim_private.txt"
PUB_KEY_FILE="${DATA_DIR}/etc/exim4/dkim_public.txt"

# Már léteznek a megfelelő kulcsok?
if [ ! -f "$PRIV_KEY" ]; then
    echo ""
    echo "      [!] Nincs helyi kulcspár => új kulcspár generálása."
    openssl genrsa -out "$PRIV_KEY" 2048 2>/dev/null
    openssl rsa -in "$PRIV_KEY" -pubout -outform DER 2>/dev/null | openssl base64 -A > "${PUB_KEY_FILE}"
    echo "      [+] Új kulcspár elmentve a $DATA_DIR mappába."
fi

# DNS rekord ellenőrzése
LOCAL_PUB_KEY=$(cat "$PUB_KEY_FILE")
DNS_RECORD=$(dig +short TXT "${DKIM_SELECTOR}._domainkey.${MAILDOMAIN}" | tr -d '" \n\r')
if [[ -n "$DNS_RECORD" && "$DNS_RECORD" == *"p=$LOCAL_PUB_KEY"* ]]; then
    echo " ✅ ${DKIM_SELECTOR}._domainkey.${MAILDOMAIN}"
else
    echo ""
    if [ -z "$DNS_RECORD" ]; then
        echo "      [-] A ${DKIM_SELECTOR}._domainkey.${MAILDOMAIN} rekord nem létezik."
    else
        echo "      [-] A ${DKIM_SELECTOR}._domainkey.${MAILDOMAIN} létezik, de abban nem az aktuális kulcs van."
    fi
    echo "      [-] Vedd fel a következő TXT rekordot a DNS-be:"
    echo "          Kulcs: TXT ${DKIM_SELECTOR}._domainkey"
    echo "          Érték: v=DKIM1; k=rsa; p=${LOCAL_PUB_KEY}"
    exit 2
fi

# -----------------------------------------------------
# DMARC ellenőrzése/előállítása
# -----------------------------------------------------
echo -n "  [?] DMARC rekord ellenőrzése: "
RECORD=$(dig +short TXT _dmarc."$MAILDOMAIN")
if [ -n "$RECORD" ]; then
    echo "✅ $RECORD"
else
    echo "hiányzik."
    echo "      [-] Vedd fel a következő TXT rekordot a DNS-be:"
    echo "      Kulcs: TXT _dmarc"
    echo "      Érték: v=DMARC1; p=quarantine;"
    exit 3
fi


# -----------------------------------------------------
# Tanúsítványok ellenőrzése/előállítása
# -----------------------------------------------------
echo "Tanúsítványok generálása:"
for T in $MAILSERVER_FQDN $WEBMAIL_FQDN $MAILADMIN_FQDN ${AUTODISCOVER_HOST}.${MAILDOMAIN} ${AUTOCONFIG_HOST}.${MAILDOMAIN} ${MAILDOMAIN}; do
    echo -n "  [?] Tanúsítvány: $T "
    CERT_FILE="/etc/letsencrypt/live/${T}/fullchain.pem"
    if [ ! -f "$CERT_FILE" ]; then
        certbot certonly ${LETSENCRYPT_DRY_RUN} --standalone \
        -d ${T} \
        --non-interactive \
        --agree-tos \
        --email ${LETSENCRYPT_EMAIL_ADDRESS} > /dev/null 2>&1

        if [ $? -eq 0 ]; then
                echo "✅ (most generálva.)"
            else
                echo "Hiba a generálás során. Létezik a ${T} domain?"
                exit 7
        fi
    else
        echo "✅ (korábban generálva.)"
    fi
done

# -----------------------------------------------------
# Adatbázis lérehozása
# -----------------------------------------------------
echo "Adatbázis létrehozása:"
echo -n "  [?] Adatbázis: ${DATABASE_FILE} "
if [ ! -f "${DATABASE_FILE}" ]; then
    sqlite3 ${DATABASE_FILE} < initdb.sql
    if [ $? -eq 0 ] ; then
      echo "✅ (létrehozva.)"
    else
      echo "[!] létrehozása sikertelen."
      exit 8
    fi
    /bin/chmod 666 ${DATABASE_FILE}
else
    echo "✅ (már létezik.)"
fi

# -----------------------------------------------------
# Mail könyvtárak létrehozása
# -----------------------------------------------------
DOMAINS=$(sqlite3 "${DATABASE_FILE}" "SELECT domain FROM domains;")
for DOMAIN in $DOMAINS; do
    TARGET_DIR="${DATA_DIR}/var/mail/${DOMAIN}"
    if [ ! -d "$TARGET_DIR" ]; then
        mkdir -p "$TARGET_DIR"
        chown 90:90 "$TARGET_DIR"
    fi
done

# -----------------------------------------------------
# Az imapsync adatfile bemásolása
# -----------------------------------------------------
[ ! -d ${DATA_DIR}/etc/imapsync ] && mkdir -p ${DATA_DIR}/etc/imapsync
cp /imapsync-mboxes.csv ${DATA_DIR}/etc/imapsync