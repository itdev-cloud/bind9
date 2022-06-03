#!/bin/bash
set -e

#BIND_DATA_DIR=${DATA_DIR}/bind

create_bind_data_dir() {
  # mkdir -p ${BIND_DATA_DIR}

  # populate default bind configuration if it does not exist
  if [ ! -f /etc/bind/named.conf ]; then
    rm -f /etc/bind/*
    cp -R -f -p ${DATA_DIR} /etc/bind/.
  fi
  # rm -rf /etc/bind2
  # rm -rf /etc/bind
  # ln -sf ${BIND_DATA_DIR}/etc /etc/bind
  chmod -R 0775 /etc/bind
  chown -R ${BIND_USER}:${BIND_USER} /etc/bind
}

create_pid_dir() {
  mkdir -p /var/run/named
  chmod 0775 /var/run/named
  chown root:${BIND_USER} /var/run/named
}

create_bind_cache_dir() {
  mkdir -p /var/cache/bind
  chmod 0775 /var/cache/bind
  chown root:${BIND_USER} /var/cache/bind
}

create_alias_create_key(){
  rm -rf /bin/create-key
  ln -s /opt/create-key.sh /bin/create-key
}

run_webmin(){
  /etc/init.d/webmin start
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


create_pid_dir
create_bind_data_dir
create_bind_cache_dir
#create_alias_create_key
#run_webmin

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