#!/bin/bash
#function to uninstall IR rpm's
function UninstallPkgs()
{
	rpm -e scv tpm2-tss tpm2-abrmd tpm2-tools
}
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
	rm -f /etc/profile.d/scv.sh
}
UninstallPkgs
RemovePath
