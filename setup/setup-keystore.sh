# Exit on Error
set -e

OUTPUT_FILE=/secrets/keystore/elasticsearch/elasticsearch.keystore
NATIVE_FILE=/usr/share/elasticsearch/config/elasticsearch.keystore

ELASTIC_PASSWORD="${ELASTIC_PASSWORD}"
set +o history
export ELASTIC_PASSWORD
set -o history

# Create Keystore
printf "========== Creating Elasticsearch Keystore ==========\n"
printf "=====================================================\n"
elasticsearch-keystore create >> /dev/null

# Setting Secrets
sh /setup/keystore.sh

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
