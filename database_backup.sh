#! /bin/sh
set -e
# database config
DB_HOST=127.0.0.1
DB_NAME=--database-name--
DB_USERNAME=--database-username--
DB_PASSWORD=--database-password--

# backup config
BACKUP_DIR=~/backup/
DATETIME=$(date +"%s_%Y-%m-%d")
FILE_NAME="$DATETIME.gz"

# Bale config
BALE_TOKEN=--bale-bot-token--
BALE_CHAT_ID=--bale-chat-id--
bale_send_message () {
    curl -F chat_id="$1" -F text="$2" https://tapi.bale.ai/bot$BALE_TOKEN/sendMessage &> /dev/null
}

bale_send_document () {
         curl -X POST   https://tapi.bale.ai/bot$BALE_TOKEN/Senddocument \
                   -H 'content-type: multipart/form-data' \
                   -F chat_id=$BALE_CHAT_ID \
                   -F document=@$BACKUP_DIR$FILE_NAME\
                   -F caption=YOUR_CAPTION
}


echo "start"
if [ ! -d "$BACKUP_DIR" ]; then
        mkdir $BACKUP_DIR
        echo "$BACKUP_DIR did not exists. I make it."
fi
/usr/bin/mysqldump --single-transaction --quick --lock-tables=false -u $DB_USERNAME -p$DB_PASSWORD $DB_NAME | gzip > "$BACKUP_DIR$FILE_NAME"
echo "done"
bale_send_document BALE_CHAT_ID
rm $BACKUP_DIR$FILE_NAME
