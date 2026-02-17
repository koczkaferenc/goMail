#!/bin/bash
. .env
MAILSERVER_FQDN=${MAIL_HOST}.${MAILDOMAIN}
WEBMAIL_FQDN=${WEBMAIL_HOST}.${MAILDOMAIN}
MAILADMIN_FQDN=${MAILADMIN_HOST}.${MAILDOMAIN}
DATA_DIR=data
[ ! -d ${DATA_DIR} ] && mkdir -p ${DATA_DIR}
CURRENT_IP=$(curl -s https://ifconfig.me)

# -----------------------------------------------------
# SPF rekord ellenőrzése
# -----------------------------------------------------
echo -n "[?] SPF rekord ellenőrzése: "
SPF_IPS=$(dig +short TXT "$MAILDOMAIN" | grep "v=spf1" | grep -oE 'ip4:[^ ]+' | cut -d':' -f2)
FOUND=0
for IP in $SPF_IPS; do
    if [ "$IP" == "$CURRENT_IP" ]; then
        FOUND=1
        break
    fi
done
if [ $FOUND -eq 0 ]; then
    echo "[-] Hiba."
    echo "[-] A szerver IP címe (${CURRENT_IP}) nem szerepel a(z) ${MAILDOMAIN} SPF rekordjában!"
    echo "[-] Készítsd el az alábbi rekordot: v=spf1 ip4:${CURRENT_IP} -all"
    exit 1
fi
echo "✅ (${CURRENT_IP})"

# -----------------------------------------------------
# DKIM ellenőrzése/előállítása
# -----------------------------------------------------
echo -n "[?] DKIM rekord ellenőrzése: "
PRIV_KEY="${DATA_DIR}/dkim_private.txt"
PUB_KEY_FILE="${DATA_DIR}/dkim_public.txt"

# Már léteznek a megfelelő kulcsok?
if [ ! -f "$PRIV_KEY" ]; then
    echo ""
    echo "    [!] Nincs helyi kulcspár => új kulcspár generálása."
    openssl genrsa -out "$PRIV_KEY" 2048 2>/dev/null
    openssl rsa -in "$PRIV_KEY" -pubout -outform DER 2>/dev/null | openssl base64 -A > "${PUB_KEY_FILE}"
    echo "    [+] Új kulcspár elmentve a $DATA_DIR mappába."
fi

# DNS rekord ellenőrzése
LOCAL_PUB_KEY=$(cat "$PUB_KEY_FILE")
DNS_RECORD=$(dig +short TXT "${DKIM_SELECTOR}._domainkey.${MAILDOMAIN}" | tr -d '" \n\r')
if [[ -n "$DNS_RECORD" && "$DNS_RECORD" == *"p=$LOCAL_PUB_KEY"* ]]; then
    echo " ✅ ${DKIM_SELECTOR}._domainkey.${MAILDOMAIN}"
else
    echo ""
    if [ -z "$DNS_RECORD" ]; then
        echo "    [-] A ${DKIM_SELECTOR}._domainkey.${MAILDOMAIN} rekord nem létezik."
    else
        echo "    [-] A ${DKIM_SELECTOR}._domainkey.${MAILDOMAIN} létezik, de abban nem az aktuális kulcs van."
    fi
    echo "    [-] Vedd fel a következő TXT rekordot a DNS-be:"
    echo "        Kulcs: TXT ${DKIM_SELECTOR}._domainkey"
    echo "        Érték: v=DKIM1; k=rsa; p=${LOCAL_PUB_KEY}"
    exit 2
fi

# -----------------------------------------------------
# DMARC ellenőrzése/előállítása
# -----------------------------------------------------
echo -n "[?] DMARC rekord ellenőrzése: "
RECORD=$(dig +short TXT _dmarc."$MAILDOMAIN")
if [ -n "$RECORD" ]; then
    echo "✅ $RECORD"
else
    echo " hiányzik."
    echo "    [-] Vedd fel a következő TXT rekordot a DNS-be:"
    echo "    Kulcs: TXT _dmarc"
    echo "    Érték: v=DMARC1; p=quarantine;"
    exit 3
fi

# -----------------------------------------------------
# DNS rekordok ellenőrzése
# -----------------------------------------------------
for T in $MAILSERVER_FQDN $WEBMAIL_FQDN $MAILADMIN_FQDN ; do
    echo -n "[?] $T ellenőrzése: "
    RESOLVED_IP=$(dig @8.8.8.8 +short "$T")
    if [ -z "$RESOLVED_IP" ]; then
        echo "'A' rekord hiányzik: $T -> $CURRENT_IP"
        exit 4
    elif [ "$RESOLVED_IP" != "$CURRENT_IP" ]; then
        echo "'A' rekord hibás címre mutat: $T -> $CURRENT_IP"
        exit 4
    else
        echo "✅ ${RESOLVED_IP}"
    fi          
done

# -----------------------------------------------------
# Reverse DNS ellenőrzése
# -----------------------------------------------------
echo -n "[?] Reverse DNS ellenőrzése: "
REVERSE_DNS=$(host "$CURRENT_IP" | awk '{print $NF}' | sed 's/\.$//')
if [ -z "$REVERSE_DNS" ] || [[ "$REVERSE_DNS" == *"not-found"* ]]; then
    echo "hiba. Az elvárt válasz: ${MAILSERVER_FQDN}"
    exit 5
elif [ "$REVERSE_DNS" != "$MAILSERVER_FQDN" ]; then
    echo "hiba. Az elvárt válasz: ${MAILSERVER_FQDN}"
    exit 5
else
    echo "✅ ${CURRENT_IP}"
fi

# -----------------------------------------------------
# Tanúsítványok ellenőrzése/előállítása
# -----------------------------------------------------
for T in $MAILSERVER_FQDN $WEBMAIL_FQDN $MAILADMIN_FQDN ; do
    echo -n "[?] Tanúsítvány: "
    CERT_FILE="${DATA_DIR}/etc/letsencrypt/live/${T}/fullchain.pem"
    if [ ! -f "$CERT_FILE" ]; then
        echo -n " ..."
        docker run --rm -it \
        -v "./${DATA_DIR}/etc/letsencrypt:/etc/letsencrypt" \
        -v "./${DATA_DIR}/var/lib/letsencrypt:/var/lib/letsencrypt" \
        -p 80:80 \
        certbot/certbot certonly ${LETSENCRYPT_DRY_RUN} --standalone \
        -d ${T} \
        --non-interactive \
        --agree-tos \
        --email ${LETSENCRYPT_EMAIL_ADDRESS} > /dev/null 2>&1

        if [ $? -eq 0 ]; then
                echo " ✅ ${T}"
            else
                echo " Hiba a generálás során. Létezik a ${T} domain?"
                exit 6
        fi
    else
        echo "✅ ${T}"
    fi
done