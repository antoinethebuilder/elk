#!/bin/bash
set -e
echo "Waiting Elasticsearch to be up..."

USER=$(who | cut -d ' ' -f 1 | head -n 1)

COMPOSE_PROJECT_NAME=$(cat .env | grep COMPOSE_PROJECT_NAME | cut -d '=' -f2)

PASSFILE="secrets/pass/passfile.txt"
CACERT="secrets/certs/ca/ca.crt"

ES_URL="https://127.0.0.1:9200"
ELASTIC_PASSWORD=changeme

PW=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 ;)
LOGSTASH_WRITER_PASSWORD=$PW


# Changing 200 for HTTP 401 since we no longer use a bootstrap password
while [[ "$(curl --cacert ${CACERT} -u "elastic:${ELASTIC_PASSWORD}" -s -o /dev/null -w '%{http_code}' $ES_URL)" != "401" ]]; do
    sleep 5
done

# echo "LOGSTASH_WRITER_PASSWORD=${LOGSTASH_WRITER_PASSWORD}" > $PASSFILE
# echo "Creating 'logstash_writer' role..."
# curl -X POST --cacert ${CACERT} \
# 	-u "elastic:${ELASTIC_PASSWORD}" -s -o /dev/null \
# 	-H "Content-Type: application/json" \
# 	-d @setup/roles/role-logstash_writer.json "${es_url}/_security/role/logstash_writer"

# echo "Creating 'logstash_internal' user..."
# curl --cacert ${CACERT} -u \
# 	"elastic:${ELASTIC_PASSWORD}" -s -o /dev/null \
# 	-X POST $ES_URL/_security/user/logstash_internal \
# 	-H "Content-Type: application/json" \
# 	--data-binary '{"password":"'"$LOGSTASH_WRITER_PASSWORD"'","roles":["logstash_writer"],"full_name":"Internal Logstash User"}'

# echo "Creating the Index Lifecycle policy for Fortigate..."
# curl -X PUT --cacert ${CACERT} \
#         -u "elastic:${ELASTIC_PASSWORD}" -s -o /dev/null \
#         -H "Content-Type: application/json" \
#         -d @setup/templates/policies/ilm-fortigate.json "${es_url}/_ilm/policy/ilm_fortigate"

# echo "Installing Fortigate index template..."
# curl -X PUT --cacert ${CACERT} \
#         -u "elastic:${ELASTIC_PASSWORD}" -s -o /dev/null \
#         -H "Content-Type: application/json" \
#         -d @setup/templates/index/fortigate-6.2.2.json "${es_url}/_template/fortigate?pretty"

echo "Generating Elasticsearch Stack passwords..."
docker exec -it $(docker container ls -qf "name=${COMPOSE_PROJECT_NAME}_elasticsearch") \
	elasticsearch-setup-passwords auto -u "https://127.0.0.1:9200" -b \
	| grep PASSWORD | grep -e kibana -e logstash_system -e elastic \
	| awk '{print toupper($2)"_PASSWORD="$4}' >> $PASSFILE

echo "Setting file permission..."
chown $USER:$USER $PASSFILE
