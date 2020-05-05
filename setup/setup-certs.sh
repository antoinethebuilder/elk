# Exit on Error
set -e

OUTPUT_DIR=/secrets/certs
ZIP_FILE=$OUTPUT_DIR/certs.zip

printf "===============================================\n"
printf " Generating Elastic Stack Certificates \n"
printf "===============================================\n"

if ! command -v unzip &>/dev/null; then
    printf "Installing Tools... \n"
    yum install -y -q -e 0 unzip;
fi

printf "Clearing Old Certificates if exits... \n"
find $OUTPUT_DIR -mindepth 1 -type d -exec rm -rf -- {} +
rm -f $ZIP_FILE

printf "Generating Certificates... \n"
bin/elasticsearch-certutil cert --silent --pem --in /setup/instances.yml -out $ZIP_FILE &> /dev/null

printf "Unzipping Certificates... \n"
unzip -qq $ZIP_FILE -d $OUTPUT_DIR;

printf "Applying Permissions... \n"
chown -R 1000:0 $OUTPUT_DIR
find $OUTPUT_DIR -type f -exec chmod 655 -- {} +

printf "=====================================================\n"
printf " SSL Certificates were successfully generated.\n"
printf "=====================================================\n"
