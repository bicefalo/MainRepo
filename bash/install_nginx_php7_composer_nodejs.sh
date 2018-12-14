#/bin/bash

#Custom Variables
composer_home=/opt/composer
node_home=/opt/nodejs
temporal_directory=/tmp
node_version=node-v8.12.0-linux-x64
profile_file=/etc/profile

pretty_print()
{
	echo "$1" | sed 's/./=/g'
	echo "$1"
	echo "$1" | sed 's/./=/g'
}

apt_process () 
{
pretty_print "Updating ubuntu repository."
apt update > /dev/null
if [ $? -eq 0 ] 
then
	pretty_print "update completed."
else
	pretty_print "Was not posible to update the repo in this moment."
	exit 1
fi

pretty_print "Installing python, nginx, php7.2 and mysql-server"
apt install -y python nginx  php7.2  mysql-server > /dev/null
if [ $? -eq 0 ] 
then
	pretty_print "Instalation completed."
else
	pretty_print "Installation failed, pls check."
	exit 1
fi

pretty_print "Stopping apache2 service."
systemctl stop apache2 > /dev/null
if [ $? -eq 0 ] 
then
	pretty_print "Service stopped sucessfully."
else
	pretty_print "Service is already down."
fi

pretty_print "Disabling apache2 service."
systemctl disable apache2 > /dev/null
if [ $? -eq 0 ] 
then
	pretty_print "Service disabled sucessfully."
else
	pretty_print "Service is already down."
fi
}


composer_install () {
pretty_print "Downloading getcomposer installer..."
wget https://getcomposer.org/installer -O ${temporal_directory}/composer-setup.php
if [ $? -eq 0 ] 
then
	pretty_print "Download completed to /tmp folder."
else
	pretty_print "Failed to download composer installer, pls check."
	exit 1
fi

pretty_print "Trying to install php composer..."

if [ ! -d ${composer_home} ]
then
	mkdir -p ${composer_home}
fi

cd ${temporal_directory}
php composer-setup.php
if [ $? -eq 0 ] 
then
	if  ! grep composer ${profile_file} > /dev/null
	then
		if grep PATH ${profile_file} > /dev/null
		then
			previous_path="$(grep PATH ${profile_file}  | cut -d"=" -f2)"
			sed -i "s#PATH=.*#PATH=${PATH}:${previous_path}:${composer_home}#g" ${profile_file}
			mv ${temporal_directory}/composer.phar ${composer_home}/composer.phar
			rm ${temporal_directory}/composer-setup.php
			pretty_print "Composer install completed."
		fi
	else
		mv ${temporal_directory}/composer.phar ${composer_home}/composer.phar
		rm ${temporal_directory}/compser-setup.php
		pretty_print "Composer install completed."
	fi
else
	pretty_print "Failed to install composer, pls check."
	exit 1
fi


}

nodejs_install() {
pretty_print "Downloading nodejs8.12.0 installer..."
wget https://nodejs.org/dist/v8.12.0/${node_version}.tar.xz -O ${temporal_directory}/${node_version}.tar.xz
if [ $? -eq 0 ] 
then
	pretty_print "Download completed to /tmp folder."
else
	pretty_print "Failed to download nodejs installer, pls check."
	exit 1
fi

pretty_print "Trying to install nodejs..."

if [ ! -d ${node_home} ]
then
	mkdir -p ${node_home} || { pretty_print "Not able to create ${node_home} directory."; exit 1; }
fi

if  ! grep nodejs ${profile_file}  
then
	pretty_print "Extracting node installer."
	tar -xvf ${temporal_directory}/${node_version}.tar.xz -C ${temporal_directory} || { pretty_print "Extraction failed"...; exit 1; }
	cp -r ${temporal_directory}/${node_version}/* ${node_home} || { pretty_print "Installing new files..."; exit 1; }
	rm -rf ${temporal_directory}/${node_version}.tar.xz ${temporal_directory}/${node_version}/
	if grep PATH ${profile_file}
	then	
	        previous_path="$(grep PATH ${profile_file}  | cut -d"=" -f2)"
		sed -i "s#PATH=.*#PATH=${PATH}:${previous_path}:${node_home}#g" ${profile_file}
		pretty_print "nodejs install completed."
	else
		pretty_print "You already have nodejs installed in this server... Exiting..."
		echo "PATH=${PATH}:${previous_path}/${node_home}/bin" >> ${profile_file}
	fi
fi

}

#apt_process
composer_install
nodejs_install
