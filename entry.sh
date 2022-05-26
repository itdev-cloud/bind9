#!/bin/bash
set -e

if [ ! -f /etc/bind/named.conf ]; then
    rm -rf /etc/bind/*
    cp -rf ${DATA_DIR}/* /etc/bind
#    rndc-confgen -r /dev/urandom > /etc/rndc.conf
    rndc-confgen -a
#    head -n5 /etc/rndc.conf | tail -n4 > /etc/rndc.key
    touch /etc/bind/.init
fi
chmod -R 0775 /etc/bind
chown -R ${BIND_USER}:${BIND_USER} /etc/bind
#rm -rf ${DATA_DIR}


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
  echo "Starting named..."
  if [[ ${IPV6} = 'True' ]]; then
    echo "With IPv6"
    exec $(which named) -u ${BIND_USER} -c /etc/bind/named.conf -g -6 ${EXTRA_ARGS}
  else 
    echo "Without IPv6"
    exec $(which named) -u ${BIND_USER} -c /etc/bind/named.conf -g -4 ${EXTRA_ARGS}
  fi
else
  exec "$@"
fi