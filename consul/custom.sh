#!/bin/bash

# export $DNSENTRIES="server=/consul/127.0.0.1#8600"
echo "The DNSENTRIES environment variable is $DNSENTRIES"
#Support other distributions 

YUM_CMD=$(which yum 2>/dev/null ) 
APT_GET_CMD=$(which apt-get 2>/dev/null )

if [[ ! -z $APT_GET_CMD ]]; then
  echo "ubuntu platform determined"
  package="apt-get"
elif [[ ! -z $YUM_CMD ]]; then
  echo "rhel platform determined"	
  package="yum"
else
  echo "unknown platform"
  echo $(uname -a)
fi

if [ $package = "apt-get" ]; then
  echo "installing dnsmasq on ubuntu"
  apt-get install dnsmasq -y 
  echo $DNSENTRIES > /etc/dnsmasq.d/10-consul
  service dnsmasq restart
  #service dnsmasq status
  #runlevel set
  echo "installing dnsmasq on ubuntu completed"
fi

if [ $package = "yum" ]; then
  echo "installing dnsmasq on centos"
  yum install dnsmasq -y
  yum install systemd -y
  echo $DNSENTRIES > /etc/dnsmasq.d/10-consul
  systemctl enable dnsmasq.service
  systemctl restart dnsmasq.service
  #systemctl status dnsmasq.service
  echo "installing dnsmasq on centos completed"
fi

sleep 10
