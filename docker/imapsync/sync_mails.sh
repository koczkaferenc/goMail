#!/bin/bash

# Ha nincs konfig, vagy üres, kilépünk.
INPUT_FILE="/config/imapsync-mboxes.csv"
[ ! -f $INPUT_FILE ] && exit 1
N=$(cat $INPUT_FILE | grep -v ^# | grep -v ^$ | wc -l)
[ $N -eq 0 ] && exit 1

LOG_FILE="/var/log/imapsync/sync_mails.log"



while [ 1 -eq 1 ] ; do
    # --- Feldolgozás ---
    # Fontos: IFS=: (mert kettőspont választja el az adatokat a sorodban)
    cat "$INPUT_FILE" | grep -v '^#' | tr -d '\r' | while IFS=: read -r S_HOST S_USER S_PASS D_HOST D_USER D_PASS DELETE_MAILS_AFTER_DAYS
    do
        # Ha a sor üres, vagy nincs benne felhasználónév, ugorjuk át
        [[ -z "$S_USER" ]] && continue

        # Ha nincs megadva az 5 adat, akkor leállunk
        if [ -z "$DELETE_MAILS_AFTER_DAYS" ] ; then
          echo "ERR: Paraméterezési hiba: $S_USER" | tee -a $LOG_FILE
          exit 
        fi

        NOW=$(date "+%Y-%m-%d %H:%M:%S")
        echo "[$NOW] Szinkron indul: $S_USER" | tee -a $LOG_FILE

        # Először szinkron
        imapsync \
            --host1 "$S_HOST" --user1 "$S_USER" --password1 "$S_PASS" \
            --host2 "$D_HOST" --user2 "$D_USER" --password2 "$D_PASS" \
            --ssl1 --addheader 
        ERR=$?
        echo "[$NOW] Szinkron kész. | Exit Code: $ERR | Source: $S_USER | Dest: $D_USER" >> "$LOG_FILE"
            
        # A DELETE_MAILS_AFTER_DAYS napnál régebbi leveleket töröljük
        if [ "${DELETE_MAILS_AFTER_DAYS}" -gt 0 ] ; then
            echo "[$NOW] ${DELETE_MAILS_AFTER_DAYS} napnál régebbi levelek törlése." | tee -a $LOG_FILE
            imapsync \
            --host1 "$S_HOST" --user1 "$S_USER" --password1 "$S_PASS" \
            --host2 "$D_HOST" --user2 "$D_USER" --password2 "$D_PASS" \
            --ssl1 --addheader --minage ${DELETE_MAILS_AFTER_DAYS} --delete1 --noexpungeaftereach
            
            ERR=$?
            NOW=$(date "+%Y-%m-%d %H:%M:%S")
            echo "[$NOW] Törölve: ${DELETE_MAILS_AFTER_DAYS} nap. | Exit Code: $ERR | Source: $S_USER | Dest: $D_USER" >> "$LOG_FILE"
        fi
    done
    echo "Várakozás $DELAY_BETWEEN_SYNCS mp."
    sleep $DELAY_BETWEEN_SYNCS
done