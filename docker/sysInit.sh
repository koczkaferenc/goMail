#!/bin/bash
. .env
MAILSERVER_FQDN=${MAILHOST}.${MAILDOMAIN}
DATA_DIR=data
[ ! -d ${DATA_DIR} ] && mkdir -p ${DATA_DIR}

# -----------------------------------------------------
# SPF rekord ellenőrzése
# -----------------------------------------------------
echo -n "[?] SPF rekord ellenőrzése: "
CURRENT_IP=$(curl -s https://ifconfig.me)
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
echo "[+] OK: (${CURRENT_IP})"

# -----------------------------------------------------
# DKIM ellenőrzése/előállítása
# -----------------------------------------------------
echo -n "[?] DKIM rekord ellenőrzése: ${DKIM_SELECTOR}._domainkey.${MAILDOMAIN}"
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
    echo " OK."
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

echo -n "[?] DMARC rekord ellenőrzése: "
RECORD=$(dig +short TXT _dmarc."$MAILDOMAIN")
if [ -n "$RECORD" ]; then
    echo "OK: $RECORD"
else
    echo " hiányzik."
    echo "    [-] Vedd fel a következő TXT rekordot a DNS-be:"
    echo "    Kulcs: TXT _dmarc"
    echo "    Érték: v=DMARC1; p=quarantine;"
fi

exit

# Tanúsítványok létrehozása
set -x
docker run --rm -it \
  -v "/data/etc/letsencrypt:/etc/letsencrypt" \
  -v "/data/var/lib/letsencrypt:/var/lib/letsencrypt" \
  -p 80:80 \
  certbot/certbot certonly ${LETSENCRYPT_DRY_RUN} --standalone \
  -d ${MAILDOMAIN} \
  --non-interactive \
  --agree-tos \
  --email ${LETSENCRYPT_EMAIL_ADDRESS}
