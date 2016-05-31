FROM java:8

### SETUP ###
ENV ELASTICSEARCH_VERSION 2.x
ENV LOGSTASH_MAJOR 2.3
ENV KIBANA_MAJOR 4.5

# 9200/9300 are elasticsearch API ports
# 5000 is logstash ingress
# 5601 is kibana frontend
EXPOSE 9200 9300 5000 5601

VOLUME /usr/share/elasticsearch/data

# sources
# apt-transport-https is for apt-get update failing after adding deb sources
RUN apt-get update -q \
  && apt-get install -yq apt-transport-https
RUN wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add - \
  && echo "deb https://packages.elastic.co/elasticsearch/${ELASTICSEARCH_VERSION}/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-${ELASTICSEARCH_VERSION}.list \
  && echo "deb https://packages.elastic.co/logstash/${LOGSTASH_MAJOR}/debian stable main" | tee -a /etc/apt/sources.list \
  && echo "deb http://packages.elastic.co/kibana/${KIBANA_MAJOR}/debian stable main" | tee -a /etc/apt/sources.list


### INSTALLATION ###
RUN apt-get update -q \
  && apt-get install -yq elasticsearch logstash kibana supervisor

# path resolution
ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV PATH /opt/logstash/bin:$PATH
ENV PATH /opt/kibana/bin:$PATH


### CONFIG ###
# elasticsearch config
# config is installed at /etc/elasticsearch
# ...but elasticsearch looks for it in /usr/share/elasticsearch/config
RUN ln -s /etc/elasticsearch /usr/share/elasticsearch/config

# # logstash config -- TODO
# # see bin/generate-ssl for the command to generate an ssl certificate and key
# COPY $FILES_DIR/etc/logstash/conf.d /etc/logstash/conf.d
# RUN mkdir -p /etc/pki/tls/certs
# COPY $FILES_DIR/etc/pki/tls/certs/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt
# RUN mkdir /etc/pki/tls/private
# COPY $FILES_DIR/etc/pki/tls/private/logstash-forwarder.key /etc/pki/tls/private/logstash-forwarder.key
# RUN mkdir -p /opt/logstash
# COPY $FILES_DIR/opt/logstash/patterns /opt/logstash/patterns

# etc config
COPY ./container/files/ /


### RUNNING IT OUT ###
CMD ["supervisord", "-n"]
