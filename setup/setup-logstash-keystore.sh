# Exit on Error
set -e

OUTPUT_FILE=/secrets/keystore/logstash/logstash.keystore
NATIVE_FILE=/usr/share/logstash/config/logstash.keystore

# Password Generate
PW=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 ;)
ELASTIC_PASSWORD=$(cat /tmp/passfile.txt | grep "ELASTIC" | cut -d '=' -f 2;)
LOGSTASH_SYSTEM_PASSWORD=$(cat /tmp/passfile.txt | grep "LOGSTASH_SYSTEM" | cut -d '=' -f 2;)
LOGSTASH_WRITER_PASSWORD=$(cat /tmp/passfile.txt | grep "LOGSTASH_WRITER" | cut -d '=' -f 2;)

# Create Keystore
printf "========== Creating Logstash Keystore ==========\n"
printf "=====================================================\n"

###echo "LOGSTASH_KEYSTORE_PASS=$LOGSTASH_KEYSTORE_PASS" > /secrets/keystore/logstash/logstash.txt
echo "y" | logstash-keystore create
# Setting Secrets

echo "$ELASTIC_PASSWORD" | logstash-keystore add ES_PWD -x
echo "$LOGSTASH_SYSTEM_PASSWORD" | logstash-keystore add LOGSTASH_SYSTEM_PWD -x
echo "$LOGSTASH_WRITER_PASSWORD" | logstash-keystore add LOGSTASH_WRITER_PWD -x

#logstash-keystore add 'ES_PWD'
# Replace current Keystore
if [ -f "$OUTPUT_FILE" ]; then
    echo "Remove old logstash.keystore"
    rm $OUTPUT_FILE
fi

echo "Saving new logstash.keystore"
mv $NATIVE_FILE $OUTPUT_FILE
chmod 0644 $OUTPUT_FILE

printf "======= Keystore setup completed successfully =======\n"
printf "=====================================================\n"
