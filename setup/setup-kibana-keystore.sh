# Exit on Error
set -e

OUTPUT_FILE=/secrets/keystore/kibana/kibana.keystore
NATIVE_FILE=/usr/share/kibana/data/kibana.keystore

# Password Generate
ELASTIC_PASSWORD=$(cat /tmp/passfile.txt | grep "ELASTIC" | cut -d '=' -f 2;)

# Create Keystore
printf "========== Creating Kibana Keystore ==========\n"
printf "=====================================================\n"
kibana-keystore create --allow-root >> /dev/null

# Setting Secrets

(echo "elastic" | kibana-keystore add --allow-root -x 'elasticsearch.username')
(echo "$ELASTIC_PASSWORD" | kibana-keystore add --allow-root -x 'elasticsearch.password')

# Replace current Keystore
if [ -f "$OUTPUT_FILE" ]; then
    echo "Remove old elasticsearch.keystore"
    rm $OUTPUT_FILE
fi

echo "Saving new elasticsearch.keystore"
mv $NATIVE_FILE $OUTPUT_FILE
chmod 0644 $OUTPUT_FILE

printf "======= Keystore setup completed successfully =======\n"
printf "=====================================================\n"
