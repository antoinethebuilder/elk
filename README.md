# ELK Stack
## Description
This repository was made to be able to deploy a quick and secure Elasticsearch Stack.

## PLEASE NOTE 

This project is a under development. Some things must be taken in considerations
to guarantee the environment to be fully secure.

More information about this will be documented soon.

### Features

- Production Single Node Cluster.
- Self-Monitoring Metrics Enabled.
- Security Enabled (under basic license).
- SSL Enabled for Elasticsearch, Kibana and Logstash on both HTTP and transport layer.
- Automatic certificates, keystores and passwords generation.

## Requirements

- [Docker >= 17.05](https://docs.docker.com/install/)
- [Docker-Compose >= 3](https://docs.docker.com/compose/install/)

## Usage:    
```
git clone https://github.com/antoinethebuilder/elk/elk.git && \
cd elk && \
make all
```

## Notes
### Elasticsearch Configuration Files
- `elk/elasticsearch/config/elasticsearch.yml`
- `elk/elasticsearch/config/log4j2.properties`

### Logstash Configuration Files

- Main Configuration
  - `elk/logstash/config/logstash.yml`
  - `elk/logstash/config/pipelines.yml`
- Pipeline Configuration
  - `elk/logstash/pipelines/*`
- Index Templates
  - `elk/logstash/templates/*`
  
### Kibana Configuration File
- `elk/kibana/config/kibana.yml`

## Known Issues
#### You have enabled encryption but DISABLED certificate verification
This is a known false positive, for more information view this [issue](https://github.com/elastic/logstash/issues/10352).

```
** WARNING ** Detected UNSAFE options in elasticsearch output configuration!
** WARNING ** You have enabled encryption but DISABLED certificate verification.
** WARNING ** To make sure your data is secure change :ssl_certificate_verification to true
```
