# Exit on Error
set -e

if [[ $STEP -eq "1" ]]
then
    OUTPUT_FILE=/secrets/keystore/elasticsearch/elasticsearch.keystore
    NATIVE_FILE=/usr/share/elasticsearch/config/elasticsearch.keystore
    ELASTIC_PASSWORD="${ELASTIC_PASSWORD}"
    SERVICE="elasticsearch"

    set +o history
    export ELASTIC_PASSWORD
    set -o history
    # Create Keystore
    printf "===============================================\n"
    printf " Creating Elasticsearch Keystore \n"
    printf "===============================================\n"
    elasticsearch-keystore create 2>&1

    # Setting Secrets
    echo "Setting bootstrap.password..."
    (echo "${ELASTIC_PASSWORD}" | elasticsearch-keystore add -x 'bootstrap.password')
elif [[ $STEP -eq "2" ]]
then

    OUTPUT_FILE=/secrets/keystore/kibana/kibana.keystore
    NATIVE_FILE=/usr/share/kibana/data/kibana.keystore
    SERVICE="kibana"
    # Password Generate
    KIBANA_PASSWORD=$(cat /tmp/passfile.txt | grep "KIBANA" | cut -d '=' -f 2;)

    # Create Keystore
    printf "===============================================\n"
    printf " Creating Kibana Keystore\n"
    printf "===============================================\n"
    kibana-keystore create --allow-root 2>&1

    # Setting Secrets

    (echo "kibana" | kibana-keystore add --allow-root -x 'elasticsearch.username' 2>&1)
    (echo "$KIBANA_PASSWORD" | kibana-keystore add --allow-root -x 'elasticsearch.password' 2>&1)
elif [[ $STEP -eq "3" ]]
then

    OUTPUT_FILE=/secrets/keystore/logstash/logstash.keystore
    NATIVE_FILE=/usr/share/logstash/config/logstash.keystore
    SERVICE="logstash"

    # Password Generate
    PW=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 ;)
    ELASTIC_PASSWORD=$(cat /tmp/passfile.txt | grep "ELASTIC" | cut -d '=' -f 2;)
    LOGSTASH_SYSTEM_PASSWORD=$(cat /tmp/passfile.txt | grep "LOGSTASH_SYSTEM" | cut -d '=' -f 2;)
    LOGSTASH_WRITER_PASSWORD=$(cat /tmp/passfile.txt | grep "LOGSTASH_WRITER" | cut -d '=' -f 2;)

    # Create Keystore
    printf "===============================================\n"
    printf " Creating Logstash Keystore\n"
    printf "===============================================\n"

    ###echo "LOGSTASH_KEYSTORE_PASS=$LOGSTASH_KEYSTORE_PASS" > /secrets/keystore/logstash/logstash.txt
    echo "y" | logstash-keystore create 2>&1
    # Setting Secrets

    echo "$ELASTIC_PASSWORD" | logstash-keystore add ES_PWD -x 2>&1
    echo "$LOGSTASH_SYSTEM_PASSWORD" | logstash-keystore add LOGSTASH_SYSTEM_PWD -x 2>&1
    echo "$LOGSTASH_WRITER_PASSWORD" | logstash-keystore add LOGSTASH_WRITER_PWD -x 2>&1
else
    printf "Something went wrong.\n"
    exit 1
fi

# Replace current Keystore
if [ -f "$OUTPUT_FILE" ]; then
    echo "Remove old $SERVICE.keystore"
    rm $OUTPUT_FILE
fi

echo "Saving new $SERVICE.keystore"
mv $NATIVE_FILE $OUTPUT_FILE
chmod 0644 $OUTPUT_FILE

printf "===============================================\n"
printf " Keystore setup completed successfully.\n"
printf "===============================================\n"