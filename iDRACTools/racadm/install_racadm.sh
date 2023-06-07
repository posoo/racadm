#!/bin/bash
GBL_OS_TYPE_ERROR=0
GBL_OS_TYPE_UKNOWN=1
GBL_OS_TYPE_RHEL7=2
GBL_OS_TYPE_RHEL8=3
GBL_OS_TYPE_SLES15=4
GBL_OS_TYPE_UBUNTU20=5

GBL_OS_TYPE_STRING=$GBL_OS_TYPE_UKNOWN
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
		if [ "$OS" == "Ubuntu" ] && [ "$VER" == "20" ]; then
			GBL_OS_TYPE=${GBL_OS_TYPE_UBUNTU20}
			GBL_OS_TYPE_STRING="UBUNTU20"
		elif [[ "$ID" == "rhel" || "$ID" == "centos" ]] && [  "$VER" == "7" ]; then
			GBL_OS_TYPE=${GBL_OS_TYPE_RHEL7}
			GBL_OS_TYPE_STRING="RHEL7"
		elif [[ "$ID" == "rhel" || "$ID" == "centos" ]] && [  "$VER" == "8" ]; then
			GBL_OS_TYPE=${GBL_OS_TYPE_RHEL8}
			GBL_OS_TYPE_STRING="RHEL8"
		elif [ "$OS" == "SLES" ] && [ "$VER" == "15" ]; then
			GBL_OS_TYPE=${GBL_OS_TYPE_SLES15}
			GBL_OS_TYPE_STRING="SLES15"
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
		echo "     variable to access the RACADM CLI utilities"
		echo ""
		echo "     **********************************************************"
	fi

	echo "export PATH=\"\$PATH:/opt/dell/srvadmin/sbin\"" > /etc/profile.d/dractools.sh

	chmod +x /etc/profile.d/dractools.sh

}

#Install/upgrade ubuntu packages
InstallUbuntuPkgs()
{
	#check if OMSA is installed
	dpkg -s srvadmin-omilcore 2>/dev/null >/dev/null
	if [ $? -eq 0 ]; then
		OMSA_INSTALLED_VER=`dpkg -s srvadmin-omilcore | grep -i "Version" |tr -s "" " "| cut -d " " -f2`
		OMSA_INSTALLED_VER=`echo "${OMSA_INSTALLED_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
		IR_NEW_VER=`dpkg --info $GBL_OS_TYPE_STRING/$ARCH/srvadmin-idracadm7*.deb  | grep "Version" |tr -s "" " "| cut -d " " -f3 2>/dev/null`
		IR_NEW_VER=`echo "${IR_NEW_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
		if [ ${OMSA_INSTALLED_VER} -lt ${IR_NEW_VER} ]; then
			dpkg --ignore-depends=srvadmin-hapi -i $GBL_OS_TYPE_STRING/$ARCH/srvadmin-idracadm7*.deb
			dpkg --ignore-depends=srvadmin-hapi -i $GBL_OS_TYPE_STRING/$ARCH/srvadmin-idracadm8*.deb
		elif [ ${IR_NEW_VER} -lt ${OMSA_INSTALLED_VER} ]; then
			echo "Cannot install Racadm as it is lower than OMSA version."
			status=1
		elif [ ${OMSA_INSTALLED_VER} == ${IR_NEW_VER} ]; then
			dpkg -s srvadmin-idracadm8 >/dev/null 2>/dev/null
			if [ $? -ne 0 ]; then
				pushd $GBL_OS_TYPE_STRING/$ARCH/ >/dev/null
				dpkg -i --force-all srvadmin-hapi*.deb
				dpkg -i --force-all srvadmin-idracadm7*.deb
				dpkg -i --force-all srvadmin-idracadm8*.deb
				popd >/dev/null
			else
				echo "Racadm is already running on the latest version."
				status=1
			fi
		fi
	else
		dpkg -s srvadmin-idracadm8 2>/dev/null >/dev/null
		if [ $? -eq 0 ]; then
			IR_INSTALLED_VER=`dpkg -s srvadmin-idracadm8 | grep -i "Version" |tr -s "" " "| cut -d " " -f2`
			IR_INSTALLED_VER=`echo "${IR_INSTALLED_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
			IR_NEW_VER=`dpkg --info $GBL_OS_TYPE_STRING/$ARCH/srvadmin-idracadm7*.deb  | grep "Version" |tr -s "" " "| cut -d " " -f3 2>/dev/null`
			IR_NEW_VER=`echo "${IR_NEW_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
			if [ ${IR_INSTALLED_VER} -lt ${IR_NEW_VER} ]; then
				pushd $GBL_OS_TYPE_STRING/$ARCH/ >/dev/null
				dpkg -i --force-all srvadmin-hapi*.deb
				dpkg -i --force-all srvadmin-idracadm7*.deb
				dpkg -i --force-all srvadmin-idracadm8*.deb
				popd >/dev/null
			elif [ ${IR_INSTALLED_VER} == ${IR_NEW_VER} ]; then
				echo "Racadm is already running on the latest version."
				status=1
			elif [ ${IR_INSTALLED_VER} -gt ${IR_NEW_VER} ]; then
				echo "Racadm is already running on the latest version."
				status=1
			fi
		else
			pushd $GBL_OS_TYPE_STRING/$ARCH/ >/dev/null
			dpkg -i srvadmin-hapi*.deb
			dpkg -i srvadmin-idracadm7*.deb
			dpkg -i srvadmin-idracadm8*.deb
			status=$?
			if [ $status -eq "1" ]
			then
				apt-get install -f
			fi
			popd >/dev/null
		fi
	fi
}
#function to install/upgrade IR rpm's
InstallPkgs()
{
	#	IsHigherGeneration
	#	if [ $? -eq $FALSE ]; then
	#		echo "This RACADM installer is not supported on 11G and below generation of servers."    
	#		exit
	#	fi

	GetOSType
	if [ "${GBL_OS_TYPE}" = "${GBL_OS_TYPE_UKNOWN}" ] || [ "${GBL_OS_TYPE}" = "${GBL_OS_TYPE_ERROR}" ] || [ $ARCH != "x86_64" ]; 	    then
		echo "Unsupported Operating System or Architecture."    
		exit
	fi
	if [ "$OS" == "Ubuntu" ]
	then
		InstallUbuntuPkgs
		exit 0
	fi
	#check if OMSA is installed
	rpm -q srvadmin-omilcore >/dev/null
	if [ $? -eq 0 ]; then
		OMSA_INSTALLED_VER=`rpm -q --queryformat "%{VERSION}" srvadmin-omilcore`
		OMSA_INSTALLED_VER=`echo "${OMSA_INSTALLED_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
		IR_NEW_VER=`rpm -qp --queryformat "%{VERSION}" $GBL_OS_TYPE_STRING/$ARCH/srvadmin-idracadm7*.rpm 2>/dev/null`
		IR_NEW_VER=`echo "${IR_NEW_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
		if [ ${OMSA_INSTALLED_VER} -lt ${IR_NEW_VER} ]; then
			rpm -Fvh $GBL_OS_TYPE_STRING/$ARCH/srvadmin-idracadm7*.rpm --nodeps
		elif [ ${IR_NEW_VER} -lt ${OMSA_INSTALLED_VER} ]; then
			echo "Cannot install Racadm as it is lower than OMSA version."
			status=1
		elif [ ${OMSA_INSTALLED_VER} == ${IR_NEW_VER} ]; then
			rpm -q srvadmin-idracadm7 >/dev/null
			if [ $? -ne 0 ]; then
				pushd $GBL_OS_TYPE_STRING/$ARCH/ >/dev/null
				rpm -ivh srvadmin-argtable2*.rpm srvadmin-hapi*.rpm srvadmin-idracadm7*.rpm
				popd >/dev/null
			else
				echo "Racadm is already running on the latest version."
				status=1
			fi
		fi
	else
		rpm -q srvadmin-idracadm7 >/dev/null
		if [ $? -eq 0 ]; then
			IR_INSTALLED_VER=`rpm -q --queryformat "%{VERSION}" srvadmin-idracadm7`
			IR_INSTALLED_VER=`echo "${IR_INSTALLED_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
			IR_NEW_VER=`rpm -qp --queryformat "%{VERSION}" $GBL_OS_TYPE_STRING/$ARCH/srvadmin-idracadm7*.rpm 2>/dev/null`
			IR_NEW_VER=`echo "${IR_NEW_VER}" | sed "s/\.//g" | sed "s/-//g" | sed "s/ //g"`
			rpm -q scv >/dev/null
			ret=$?
			if [ ${IR_INSTALLED_VER} == ${IR_NEW_VER} ]; then
				echo "Racadm is already running on the latest version."
				status=1
			elif [ $ret -eq 0 ]; then
				echo "Upgrading RACADM is not supported. Uninstall the older version of iDRAC tools and install the new version."
				status=1
			elif [ ${IR_INSTALLED_VER} -lt ${IR_NEW_VER} ]; then
				pushd $GBL_OS_TYPE_STRING/$ARCH/ >/dev/null
				rpm -Uvh srvadmin-argtable2*.rpm srvadmin-hapi*.rpm srvadmin-idracadm7*.rpm
				popd >/dev/null
			elif [ ${IR_INSTALLED_VER} -gt ${IR_NEW_VER} ]; then
				echo "Racadm is already running on the latest version."
				status=1
			fi
		else
			pushd $GBL_OS_TYPE_STRING/$ARCH/ >/dev/null
			rpm -ivh srvadmin-argtable2*.rpm srvadmin-hapi*.rpm srvadmin-idracadm7*.rpm
			status=$?
			popd >/dev/null
		fi
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
    rm -f /etc/profile.d/dractools.sh
}
InstallPkgs
RemovePath
setPath
