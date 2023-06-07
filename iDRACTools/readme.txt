
The package that you downloaded contains the following tools:
• RACADM
• IPMI Tool
• SCV

==========================================================================================
Release summary
==========================================================================================
The Integrated Dell Remote Access Controller (iDRAC) is designed to make server administrators
more productive and improve the overall availability of Dell servers.

iDRAC alerts administrators to server issues, helps them perform remote server management, and
reduces the need for physical access to the server. Additionally, iDRAC enables administrators
to deploy, monitor, manage, configure, update, and troubleshoot Dell EMC servers from any location
without using any agents. It accomplishes this regardless of the operating system or hypervisor
presence or state.

iDRAC provides out-of-band mechanisms for configuring the server, applying firmware updates,
saving or restoring a system backup, or deploying an operating system, by using the iDRAC GUI, the
iDRAC RESTful API or the RACADM command line interface.

This release of the RACADM command line interface includes updated packaging supporting
the installation of both local and remote RACADM and fixes to issues documented below.
This release includes support for SCV (Secured Component Verification) feature Compactible 
with Firmware Version 4.32.10.00 and above.

------------------------------------------------------------------------------------------
Version
------------------------------------------------------------------------------------------
Dell EMC iDRAC Tool for Linux  v10.1.0.0

------------------------------------------------------------------------------------------
Release date
------------------------------------------------------------------------------------------
July 2021

==========================================================================================
Compatibility
==========================================================================================
For SLES 15 systems, the HAPI RPM has a dependency on the 'insserv-compact' OS package.
To ensure backward compatibility, HAPI still uses System V init scripts and has this
dependency. Install this package before installing RACADM.
You can download this package from this link:
http://linuxlib.us.dell.com/pub/Distros/SLES/sles/15/GM/packages/
Module-Basesystem/noarch/insserv-compat-0.1-2.10.noarch.rpm

==========================================================================================
New and enhanced features
==========================================================================================
RACADM:
• Support added for UBUNTU 20.04.2
• Support added for SLES 15 SP2

IPMI Tool:
• CSSD update to 7.27 	
• 
SCV:
• 
• 
==========================================================================================
Fixes
==========================================================================================
RACADM:
• After uninstalling dractools the path is showing in /etc/bashrc Tracking Number:188451
• Unable to update FX2 CMC through fwupdate. Tracking Number: 196030
• Exit code for multi sessions of local racadm needs fix. Tracking Number: 200597
   
IPMI Tool:
• Fixes for  SOL termination in BIOS page. Tracking Number: 188893
• Fixes for FRU read time format as per the open source. Tracking Number: 193433
• Fixes for FRU write command. Tracking Number: 193515
 

==========================================================================================
Known issues
==========================================================================================
RACADM:
 N/A
	

IPMI Tool:
 N/A


==========================================================================================
Installation
==========================================================================================
RACADM:
1. Navigate to the directory where the tar.gz  of iDRACTools is downloaded.
2. Run tar -zxvf on the tar.gz to unzip the contents into the current directory.
3. Inside the folder where you extracted the files, navigate to /linux/rac folder.
4. To install the RACADM binary, execute the script install_racadm.sh.
   
   Note: Open a new console window to run the RACADM commands. You cannot execute RACADM
   commands from the console window using which you executed the install_racadm.sh script. 
   
   If you get an SSL error message for remote RACADM, use the following steps to
   resolve the error:
   a. Run the command 'openssl version' to find the openssl version installed in the Host OS.
   b. Locate the openSSL libraries that are present in the HOST OS.
      Example: ls -l /usr/lib64/libssl*
   c. Soft-link the library libssl.so using ln -s command to the appropriate OpenSSL 
      version present in the Host OS.
      Example: ln -s /usr/lib64/libssl.so.<version> /usr/lib64/libssl.so

To uninstall RACADM, use the 'uninstall_racadm.sh' script.

Note:
• RACADM and its specific RPMS/Debians can be installed without requiring the installation of OMSA components.
• The installed RACADM binary can be used to execute both Local RACADM and Remote RACADM commands.
• The install_racadm.sh installs only the RPMS/Debians required for RACADM (srvadmin-argtable2, srvadmin-idracadm7, srvadmin-hapi).
• If the RPM's files are installed directly without the script, the path will not be set to the RPM files once the host is logged out leads to Racadm command failure.
• In case of UBUNTU installation, install_racadm.sh and uninstall_racadm.sh scripts has to run using bash as below:
  bash ./install_racadm.sh
  bash ./uninstall_racadm.sh
  $PATH information will differ between host and SSH login.

IPMI Tool:
To install the latest version of RAC Tools, do the following:
1 Uninstall the existing IPMI tool:
	a) Query the existing IPMI tool: rpm -qa | grep ipmitool
	   If the IPMI tool is already installed, the query returns ipmitool-x.x.xx-x.x.xx.
	b) To uninstall the IPMI tool:•
	   On systems running SUSE Linux Enterprise Server  type rpm -e ipmitool-x.x.xx-x.x.xx•
	   On systems running Red Hat Enterprise Linux 6.x, type rpm –e ipmitool•
	   On systems running Red Hat Enterprise Linux 7.x, type rpm –e OpenIPMI-tools
2 Browse to the downloaded DRAC tools directory and got to IPMI tool sub folder and then
  type rpm -ivh ipmitool*.rpm
3 To update already available Dell IPMI Tool type rpm -Uvh ipmitool*.rpm


SCV:
1. Navigate to the directory where the tar.gz of iDRACTools is downloaded.
2. Run tar -zxvf on the tar.gz to unzip the contents into the current directory.
3. Inside the folder where you extracted the files, navigate to iDRACTools/scv folder.
4. To install the SCV binary, execute 'install_scv.sh' script.
   
To uninstall SCV, use the 'uninstall_scv.sh' script.


==========================================================================================
Resources and support
==========================================================================================
------------------------------------------------------------------------------------------
Accessing documents using direct links
------------------------------------------------------------------------------------------
You can directly access the documents using the following links:
• dell.com/idracmanuals		 —	iDRAC and Lifecycle Controller
• dell.com/openmanagemanuals	 —	Enterprise System Management
• dell.com/serviceabilitytools	 —	Serviceability Tools
• dell.com/OMConnectionsClient	 —	Client System Management
• dell.com/OMConnectionsClient	 —	OpenManage Connections Client systems management 
• dell.com/OMConnectionsEnterpriseSystemsManagement — OpenManage Connections Enterprise
                                                      Systems Management

------------------------------------------------------------------------------------------
Accessing documents using product selector
------------------------------------------------------------------------------------------
You can also access documents by selecting your product.
1. Go to dell.com/manuals.
2. In the All products section, click Software --> Enterprise Systems Management.
3. Click the desired product and then click the desired version, if applicable.
4. Click Manuals & documents. 

==========================================================================================
Contacting Dell EMC
==========================================================================================
Dell EMC provides several online and telephone-based support and service options.
Availability varies by country and product, and some services may not be available in
your area. To contact Dell EMC for sales, technical support, or customer service issues,
go to www.dell.com/contactdell.

If you do not have an active Internet connection, you can find contact information on
your purchase invoice, packing slip, bill, or the product catalog.

==========================================================================================
Information in this document is subject to change without notice.
© 2021 Dell Inc. or its subsidiaries. All rights reserved.
Dell, EMC, and other trademarks are trademarks of Dell Inc. or its subsidiaries.
Other trademarks may be trademarks of their respective owners.

Rev: A00
