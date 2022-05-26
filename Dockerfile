FROM ubuntu:jammy-20220428

ENV BIND_USER=bind \
    BIND_VERSION=9.18.3 \
    DATA_DIR=/data \
    IPV6="False"

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
  && apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository -y ppa:isc/bind \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bind9=1:${BIND_VERSION}* bind9-host=1:${BIND_VERSION}* dnsutils \
  && rm -rf /var/lib/apt/lists/* && rm -rf /etc/bind/* \
  && apt-get --purge -y autoremove policykit-1

RUN mkdir -p /etc/bind && chown root:${BIND_USER} /etc/bind/ && chmod 755 /etc/bind \
  && mkdir -p /var/cache/bind && chown ${BIND_USER}:${BIND_USER} /var/cache/bind && chmod 755 /var/cache/bind \
  && mkdir -p /var/lib/bind && chown ${BIND_USER}:${BIND_USER} /var/lib/bind && chmod 755 /var/lib/bind \
  && mkdir -p /var/log/bind && chown ${BIND_USER}:${BIND_USER} /var/log/bind && chmod 755 /var/log/bind \
  && mkdir -p /run/named && chown ${BIND_USER}:${BIND_USER} /run/named && chmod 755 /run/named

WORKDIR /

COPY config ${DATA_DIR}

## COPY entrypoint.sh /sbin/entrypoint.sh
COPY entry.sh /sbin/entry.sh

## COPY create-key.sh /opt/create-key.sh

##RUN chmod 755 /sbin/entrypoint.sh
## /opt/create-key.sh

##RUN if [ ! -f /etc/bind/named.conf ]; then cp -R -p ${DATA_DIR} /etc/bind; fi && rm -rf ${DATA_DIR}

VOLUME [ "/etc/bind", "/var/cache/bind"]

EXPOSE 53/udp 53/tcp 953/tcp

# ENTRYPOINT ["/sbin/entrypoint.sh"]

## CMD ["/usr/sbin/named"]

ENTRYPOINT ["/sbin/entry.sh"]

## CMD ["sh", "-c", "/exec usr/sbin/named -g -c /etc/bind/named.conf -u ${BIND_USER}"]