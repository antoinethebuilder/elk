ARG ELK_VERSION

# https://github.com/elastic/logstash-docker
FROM docker.elastic.co/logstash/logstash:${ELK_VERSION}

HEALTHCHECK --interval=240s --timeout=120s --retries=5 \
  CMD bin/logstash -t

# Add your logstash plugins setup here
# Example: RUN logstash-plugin install logstash-filter-json
RUN logstash-plugin install \
        logstash-input-syslog \
        logstash-input-snmp \
        logstash-input-tcp \
        logstash-input-beats \
        logstash-filter-kv \
        logstash-filter-geoip \
        logstash-filter-grok \
        logstash-codec-cef \
        logstash-codec-csv