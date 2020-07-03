#!/bin/bash
set -e
echo "Waiting Elasticsearch to be up..."
user=$(who | cut -d ' ' -f 1 | head -n 1)
passfile="secrets/pass/passfile.txt"
ELASTIC_PASSWORD=changeme
CACERT="secrets/certs/ca/ca.crt"
es_url="https://127.0.0.1:9200"

PW=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 ;)
LOGSTASH_WRITER_PASSWORD=$PW
echo "LOGSTASH_WRITER_PASSWORD=${LOGSTASH_WRITER_PASSWORD}" > $passfile

while [[ "$(curl --cacert ${CACERT} -u "elastic:${ELASTIC_PASSWORD}" -s -o /dev/null -w '%{http_code}' $es_url)" != "200" ]]; do
    sleep 5
done

echo "Creating 'logstash_writer' role..."
curl -X POST --cacert ${CACERT} \
	-u "elastic:${ELASTIC_PASSWORD}" -s -o /dev/null \
	-H "Content-Type: application/json" \
	-d @setup/roles/role-logstash_writer.json "${es_url}/_xpack/security/role/logstash_writer"

echo "Creating 'logstash_internal' user..."
curl --cacert ${CACERT} -u \
	"elastic:${ELASTIC_PASSWORD}" -s -o /dev/null \
	-X POST $es_url/_xpack/security/user/logstash_internal \
	-H "Content-Type: application/json" \
	--data-binary '{"password":"'"$LOGSTASH_WRITER_PASSWORD"'","roles":["logstash_writer"],"full_name":"Internal Logstash User"}'

echo "Installing fortigate index template..."
curl -X PUT --cacert ${CACERT} \
        -u "elastic:${ELASTIC_PASSWORD}" -s -o /dev/null \
        -H "Content-Type: application/json" \
        -d @setup/templates/fortigate-6.2.2.json "${es_url}/_template/fortigate?pretty"

echo "Generating Elasticsearch Stack passwords..."
docker exec -it $(docker container ls -qf "name=elastic_elasticsearch") \
	elasticsearch-setup-passwords auto -u "https://127.0.0.1:9200" -b \
	| grep PASSWORD | grep -e kibana -e logstash_system -e elastic \
	| awk '{print toupper($2)"_PASSWORD="$4}' >> $passfile

echo "Setting file permission..."
chown $user:$user $passfile
