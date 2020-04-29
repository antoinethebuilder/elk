#!/bin/bash
set -e
echo "Waiting Elasticsearch to be up..."
ELASTIC_PASSWORD=changeme
CACERT="secrets/certs/ca/ca.crt"
es_url="https://127.0.0.1:9200"

while [[ "$(curl --cacert ${CACERT} -u "elastic:${ELASTIC_PASSWORD}" -s -o /dev/null -w '%{http_code}' $es_url)" != "200" ]]; do
    sleep 5
done

passfile="secrets/pass/passfile.txt"

echo "Generating Elasticsearch Stack passwords..."
docker exec -it $(docker container ls -qf "name=elastic_elasticsearch") \
	elasticsearch-setup-passwords auto -u "https://127.0.0.1:9200" -b \
	| grep PASSWORD | grep -e kibana -e logstash_system -e elastic \
	| awk '{print toupper($2)"_PASSWORD="$4}' > $passfile

echo "Setting file permission..."
chown user:user $passfile
