#!/bin/bash
set -e

if [ ! -f /etc/bind/named.conf ]; then
    rm -rf /etc/bind/*
    cp -rf ${DATA_DIR}/* /etc/bind
#    rndc-confgen -r /dev/urandom > /etc/rndc.conf
    # rndc-confgen -a
#    head -n5 /etc/rndc.conf | tail -n4 > /etc/rndc.key
    touch /etc/bind/.init
fi
chmod -R 0775 /etc/bind
chown -R ${BIND_USER}:${BIND_USER} /etc/bind
#rm -rf ${DATA_DIR}

rm -rf /var/cache/bind/*

run_webmin(){
  /usr/bin/perl /opt/webmin/miniserv.pl /etc/webmin/miniserv.conf
  if [ $? != 0 ];then
    pkill perl
    rm /var/run/webmin/miniserv.pid
    /usr/bin/perl /opt/webmin/miniserv.pl /etc/webmin/miniserv.conf
  fi
  prev_username=$(cat /opt/user.name)
  sed -i "s/$prev_username:/${GUI_USER}:/g" /etc/webmin/miniserv.users
  sed -i "s/$prev_username:/${GUI_USER}:/g" /etc/webmin/webmin.acl
  sed -i "s/$prev_username/${GUI_USER}/g" /opt/user.name
  /opt/webmin/changepass.pl /etc/webmin ${GUI_USER} ${GUI_PASSWORD} > /dev/null
}

# allow arguments to be passed to named
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$*"
  set --
elif [[ ${1} == named || ${1} == "$(command -v named)" ]]; then
  EXTRA_ARGS="${*:2}"
  set --
fi

# default behaviour is to launch named
if [[ -z ${1} ]]; then
  run_webmin
  echo "Starting named..."
  exec $(which named) -u ${BIND_USER} -c /etc/bind/named.conf -g ${EXTRA_ARGS}
else
  exec "$@"
fi