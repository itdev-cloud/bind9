FROM ubuntu:jammy-20220428

ARG WEBMIN_VER=1.994
ARG BIND_VER=9.18.3 \
    GUI_USER \
    GUI_PASSWORD \
    GUI_PORT

ENV BIND_USER=bind \
    DATA_DIR=/data \
    BIND_DIR=/bind-data \
    WEBMIN_DIR=/webmin-data \
    GUI_USER=${GUI_USER:-admin} \
    GUI_PASSWORD=${GUI_PASSWORD:-difficult} \
    GUI_PORT=${GUI_PORT:-10000} \
    RUN_WEBMIN=True

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
  && apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository -y ppa:isc/bind \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bind9=1:${BIND_VER}* bind9-host=1:${BIND_VER}* dnsutils perl wget
RUN wget -q http://prdownloads.sourceforge.net/webadmin/webmin-${WEBMIN_VER}.tar.gz -O /opt/webmin.tar.gz && \
    tar xf /opt/webmin.tar.gz -C /opt && \
    rm -rf /var/cache/apk/* && \
    ln -s /opt/webmin-${WEBMIN_VER} /opt/webmin && \
    rm -rf /opt/webmin.tar.gz

RUN rm -rf /opt/webmin/adsl-client /opt/webmin/ajaxterm /opt/webmin/apache /opt/webmin/backup-config /opt/webmin/bacula-backup /opt/webmin/bandwidth /opt/webmin/change-user /opt/webmin/cluster-copy /opt/webmin/cluster-cron /opt/webmin/cluster-passwd /opt/webmin/cluster-shell /opt/webmin/cluster-software /opt/webmin/cluster-useradmin /opt/webmin/cluster-usermin /opt/webmin/cluster-webmin /opt/webmin/cpan /opt/webmin/custom /opt/webmin/dhcpd /opt/webmin/dovecot /opt/webmin/exim /opt/webmin/fail2ban /opt/webmin/fetchmail /opt/webmin/filemin /opt/webmin/firewall /opt/webmin/firewall6 /opt/webmin/firewalld /opt/webmin/fsdump /opt/webmin/grub /opt/webmin/heartbeat /opt/webmin/htaccess-htpasswd /opt/webmin/idmapd /opt/webmin/inetd /opt/webmin/init /opt/webmin/inittab /opt/webmin/ipsec /opt/webmin/iscsi-client /opt/webmin/iscsi-server /opt/webmin/iscsi-target /opt/webmin/iscsi-tgtd /opt/webmin/jabber /opt/webmin/krb5 /opt/webmin/ldap-client /opt/webmin/ldap-server /opt/webmin/ldap-useradmin /opt/webmin/logrotate /opt/webmin/lpadmin /opt/webmin/lvm /opt/webmin/mailboxes /opt/webmin/mailcap /opt/webmin/man /opt/webmin/mon /opt/webmin/mount /opt/webmin/mysql /opt/webmin/net /opt/webmin/openslp /opt/webmin/pam /opt/webmin/pap /opt/webmin/passwd /opt/webmin/phpini /opt/webmin/postfix /opt/webmin/postgresql /opt/webmin/ppp-client /opt/webmin/pptp-client /opt/webmin/pptp-server /opt/webmin/procmail /opt/webmin/proftpd /opt/webmin/qmailadmin /opt/webmin/quota /opt/webmin/raid /opt/webmin/samba /opt/webmin/sarg /opt/webmin/shell /opt/webmin/shorewall /opt/webmin/shorewall6 /opt/webmin/smart-status /opt/webmin/software /opt/webmin/spam /opt/webmin/squid /opt/webmin/sshd /opt/webmin/stunnel /opt/webmin/syslog-ng /opt/webmin/syslog /opt/webmin/tcpwrappers /opt/webmin/telnet /opt/webmin/tunnel /opt/webmin/updown /opt/webmin/useradmin /opt/webmin/usermin /opt/webmin/vgetty /opt/webmin/webalizer /opt/webmin/wuftpd /opt/webmin/xinetd /opt/webmin/filter /opt/webmin/exports /opt/webmin/fdisk && \
    rm -rf /opt/webmin/gray-theme && \
    export config_dir=/etc/webmin && \
    export var_dir=/var/log/webmin && \
    export perl=/usr/bin/perl && \
##    export os_type=gentoo-linux && \
##    export os_version=12.1 && \
    export port=${GUI_PORT} && \
    export login=${GUI_USER} && \
    export password=${GUI_PASSWORD} && \
    export password2=${GUI_PASSWORD} && \
    export ssl=0 && \
    export atboot=0 && \
    export nostart=1 && \
    sh /opt/webmin/setup.sh && \
    echo "${GUI_USER}" > /opt/user.name && \
##    echo '' > /etc/apk/repositories && \
    echo 'gotomodule=bind8' >> /etc/webmin/config && \
    sed -i 's/^rndc_conf=.*$/rndc_conf=\/etc\/bind\/rndc\.key/g' /etc/webmin/bind8/config && \
    sed -i 's/^master_dir=.*$/master_dir=\/etc\/bind/g' /etc/webmin/bind8/config && \
    sed -i 's/^slave_dir=.*$/slave_dir=\/etc\/bind/g' /etc/webmin/bind8/config && \
    sed -i 's/^show_list=.*$/show_list=0/g' /etc/webmin/bind8/config && \
    rm -rf /etc/webmin/status/services/nfs.serv \
  && rm -rf /var/lib/apt/lists/* && rm -rf /etc/bind/* \
  && apt-get --purge -y autoremove policykit-1 software-properties-common

RUN mkdir -p /etc/bind && chown root:${BIND_USER} /etc/bind/ && chmod 755 /etc/bind \
  && mkdir -p /var/cache/bind && chown ${BIND_USER}:${BIND_USER} /var/cache/bind && chmod 755 /var/cache/bind \
  && mkdir -p /var/lib/bind && chown ${BIND_USER}:${BIND_USER} /var/lib/bind && chmod 755 /var/lib/bind \
  && mkdir -p /var/log/bind && chown ${BIND_USER}:${BIND_USER} /var/log/bind && chmod 755 /var/log/bind \
  && mkdir -p /run/named && chown ${BIND_USER}:${BIND_USER} /run/named && chmod 755 /run/named

COPY config ${DATA_DIR}

## COPY entrypoint.sh /sbin/entrypoint.sh
COPY entry.sh /sbin/entry.sh

## COPY create-key.sh /opt/create-key.sh

##RUN chmod 755 /sbin/entrypoint.sh
## /opt/create-key.sh

##RUN if [ ! -f /etc/bind/named.conf ]; then cp -R -p ${DATA_DIR} /etc/bind; fi && rm -rf ${DATA_DIR}

VOLUME [ "/etc/bind", "/var/cache/bind", "/webmin-data"]

EXPOSE 53/udp 53/tcp 953/tcp 10000/tcp

# ENTRYPOINT ["/sbin/entrypoint.sh"]

ENTRYPOINT ["/sbin/entry.sh"]

CMD ["/usr/sbin/named"]

## CMD ["sh", "-c", "/exec usr/sbin/named -g -c /etc/bind/named.conf -u ${BIND_USER}"]