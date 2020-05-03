# Exit on Error
set -e

OUTPUT_FILE=/secrets/keystore/kibana/kibana.keystore
NATIVE_FILE=/usr/share/kibana/data/kibana.keystore

# Password Generate
KIBANA_PASSWORD=$(cat /tmp/passfile.txt | grep "KIBANA" | cut -d '=' -f 2;)

# Create Keystore
printf "========== Creating Kibana Keystore ==========\n"
printf "=====================================================\n"
kibana-keystore create --allow-root >> /dev/null

# Setting Secrets

(echo "kibana" | kibana-keystore add --allow-root -x 'elasticsearch.username' >> /dev/null)
(echo "$KIBANA_PASSWORD" | kibana-keystore add --allow-root -x 'elasticsearch.password' >> /dev/null)

# Replace current Keystore
if [ -f "$OUTPUT_FILE" ]; then
    echo "Remove old kibana.keystore"
    rm $OUTPUT_FILE
fi

echo "Saving new kibana.keystore"
mv $NATIVE_FILE $OUTPUT_FILE
chmod 0644 $OUTPUT_FILE

printf "======= Keystore setup completed successfully =======\n"
printf "=====================================================\n"
