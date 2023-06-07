#!/bin/bash
GBL_OS_TYPE_ERROR=0
GBL_OS_TYPE_UKNOWN=1
GBL_OS_TYPE_RHEL7=2
GBL_OS_TYPE_RHEL8=3
GBL_OS_TYPE_SLES15=4
GBL_OS_TYPE_UBUNTU20=5

GBL_OS_TYPE_STRING=$GBL_OS_TYPE_UKNOWN
GBL_OS_TYPE=$GBL_OS_TYPE_UKNOWN
ARCH="x86_64"
status=0
TRUE=0
FALSE=1
OS="None"
#function to check supported operating system.
GetOSType()
{
	if [ -f /etc/os-release ]; then			
		. /etc/os-release
		OS=$NAME
		VER=`echo $VERSION_ID | cut -d"." -f1`
		if [[ "$ID" == "rhel" || "$ID" == "centos" ]] && [  "$VER" == "7" ]; then
			GBL_OS_TYPE=${GBL_OS_TYPE_RHEL7}
			GBL_OS_TYPE_STRING="RHEL7"
		fi
	fi
	return 0
}

setPath()
{
	if [ $status -eq 0 ]; then
		echo "     **********************************************************"
		echo "     After the install process completes, you may need "
		echo "     to logout and then login again to reset the PATH"
		echo "     variable to access the SCV CLI utilities"
		echo ""
		echo "     **********************************************************"
	fi

	echo "export PATH=\"\$PATH:/opt/dell/srvadmin/sbin\"" > /etc/profile.d/scv.sh

	chmod +x /etc/profile.d/scv.sh

}
#function to install/upgrade IR rpm's
InstallPkgs()
{
	GetOSType
	if [ "${GBL_OS_TYPE}" = "${GBL_OS_TYPE_UKNOWN}" ] || [ "${GBL_OS_TYPE}" = "${GBL_OS_TYPE_ERROR}" ] || [ $ARCH != "x86_64" ]; 	    then
		echo "Unsupported Operating System or Architecture."    
		exit
	fi
	#check if SCV is installed
	rpm -q scv >/dev/null
	if [ $? -eq 0 ]; then
		SCV_INSTALLED_VER=`rpm -q --queryformat "%{VERSION}" scv`
		SCV_INSTALLED_VER=`echo "${SCV_INSTALLED_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
		SCV_NEW_VER=`rpm -qp --queryformat "%{VERSION}" $GBL_OS_TYPE_STRING/$ARCH/scv*.rpm 2>/dev/null`
		SCV_NEW_VER=`echo "${SCV_NEW_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
		rpm -q srvadmin-idracadm7 >/dev/null
		ret=$?
		if [ ${SCV_INSTALLED_VER} == ${SCV_NEW_VER} ]; then
			echo "SCV is already running on the latest version."
			status=1
		elif [ $ret -eq 0 ]; then
			echo "Upgrading SCV is not supported. Uninstall the older version of iDRAC tools and install the new version."
			status=1
		elif [ ${SCV_INSTALLED_VER} -lt ${SCV_NEW_VER} ]; then
			cd ../racadm
			sh ./install_racadm.sh
			cd -
			pushd $GBL_OS_TYPE_STRING/$ARCH/ >/dev/null
			rpm -Uvh tpm2-tss-*.rpm
			rpm -Uvh tpm2-abrmd-*.rpm
			rpm -Uvh tpm2-tools-*.rpm
			rpm -Uvh scv*.rpm
			popd >/dev/null
		elif [ ${SCV_INSTALLED_VER} == ${SCV_NEW_VER} ]; then
			echo "SCV is already running on the latest version."
			status=1
		elif [ ${SCV_INSTALLED_VER} -gt ${SCV_NEW_VER} ]; then
			echo "SCV is already running on the latest version."
			status=1
		fi
	else
                rpm -q srvadmin-idracadm7 >/dev/null
                if [ $? -eq 0 ]; then
			cd ../racadm
                        IR_INSTALLED_VER=`rpm -q --queryformat "%{VERSION}" srvadmin-idracadm7`
                        IR_INSTALLED_VER=`echo "${IR_INSTALLED_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
                        IR_NEW_VER=`rpm -qp --queryformat "%{VERSION}" $GBL_OS_TYPE_STRING/$ARCH/srvadmin-idracadm7*.rpm 2>/dev/null`
                        IR_NEW_VER=`echo "${IR_NEW_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
                        if [ ${IR_INSTALLED_VER} -lt ${IR_NEW_VER} ]; then
				sh ./install_racadm.sh
                        fi
			cd -
		else
			cd ../racadm
			sh ./install_racadm.sh
			cd -
		fi
		pushd $GBL_OS_TYPE_STRING/$ARCH/ >/dev/null
		rpm -ivh tpm2-tss-*.rpm
		rpm -ivh tpm2-abrmd-*.rpm
		rpm -ivh tpm2-tools-*.rpm
		rpm -ivh scv*.rpm
		status=$?
		popd >/dev/null
	fi
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
InstallPkgs
RemovePath
setPath
