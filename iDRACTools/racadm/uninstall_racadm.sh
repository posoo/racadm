#!/bin/bash
#function to uninstall IR rpm's
function RemovePath()
{
	echo $PATH | tr ":" "\n" | grep "/opt/dell/srvadmin/sbin" >/dev/null
	if [ $? -eq 0 ]; then
		PATH=`echo $PATH | sed -e 's/:\/opt\/dell\/srvadmin\/sbin\/$//'`
        if [[ "$ID" == "rhel" || "$ID" == "centos" ]]; then
            sed -i '/opt\/dell\/srvadmin\/sbin/d' /etc/bashrc
		else
			sed -i '/opt\/dell\/srvadmin\/sbin/d' /etc/bash.bashrc
        fi
	fi
	rm -f /etc/profile.d/dractools.sh
}
function UninstallUbuntuPkgs()
{
    dpkg -s srvadmin-omilcore >/dev/null
	if [ $? -eq 0 ]; then
		echo "OMSA is already installed in the system. Uninstall OMSA and try again to uninstall racadm."
	else
		dpkg --purge srvadmin-hapi srvadmin-idracadm7 srvadmin-idracadm8
	fi
}
function UninstallPkgs()
{
	rpm -q srvadmin-omilcore >/dev/null
	if [ $? -eq 0 ]; then
		echo "OMSA is already installed in the system. Uninstall OMSA and try again to uninstall racadm."
	else
		rpm -e srvadmin-argtable2 srvadmin-hapi srvadmin-idracadm7
	fi
}
OS="None"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
fi
if [ "$OS" == "Ubuntu" ]
then
    UninstallUbuntuPkgs
    RemovePath	
else
    UninstallPkgs
    RemovePath	
fi
