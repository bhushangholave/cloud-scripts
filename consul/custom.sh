#!/bin/bash

service=dnsmasq

# export DNSENTRIES="server=/consul/127.0.0.1#8600"
echo "The DNSENTRIES environment variable is $DNSENTRIES"

#Support other distributions
# todo upstart/systemd/initd

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


if service --status-all 2>&1 | grep $service; then
	echo "$service is installed"
else
	echo "$service is not installed"

	if [ $package = "apt-get" ]; then
	  echo "installing $service  on ubuntu"
	  apt-get update -y
	  echo "Finished update"
	  sleep 15
	  apt-get install $service -y  || echo " $service installation failed"
	  update-rc.d $service enable
	  #runlevel set
	  echo "$service  installed"
	fi

	if [ $package = "yum" ]; then
	  echo "installing $service  on centos"
	  yum install $service -y  || echo " $service installation failed"
	  #why was below line there?
	  #yum install systemd -y
	  systemctl enable $service.service
	  echo "$service  installed"
	fi

fi


echo "setting up configuration for dnsmasq"
echo $DNSENTRIES > /etc/dnsmasq.d/10-consul


if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
then
echo "$service is running!!!"
echo "restarting $service..."
	  service $service restart
else
#/etc/init.d/$service start
echo "$service is stopped"
echo "starting $service..."
	  service $service start
fi


sleep 10

