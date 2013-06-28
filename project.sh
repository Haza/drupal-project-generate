#!/bin/bash
mkdir /projects/$1
mkdir /projects/$1/logs
mkdir /projects/$1/www
mkdir /projects/$1/conf

echo "##### Creating directory for : $1 #####"

ls /projects/$1 -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/' 

echo "##### Creating apache conf #####"

touch /projects/$1/conf/apache.conf
echo "<VirtualHost *:80>" > /projects/$1/conf/apache.conf
echo "	ServerName $1.dev" >> /projects/$1/conf/apache.conf
echo "	ServerAdmin webmaster@localhost" >> /projects/$1/conf/apache.conf
echo " " >> /projects/$1/conf/apache.conf
echo "	DocumentRoot /projects/$1/www" >> /projects/$1/conf/apache.conf
echo "	<Directory />" >> /projects/$1/conf/apache.conf
echo "		Options FollowSymLinks" >> /projects/$1/conf/apache.conf
echo "		AllowOverride None" >> /projects/$1/conf/apache.conf
echo "	</Directory>" >> /projects/$1/conf/apache.conf
echo "	<Directory /projects/$1/www/>" >> /projects/$1/conf/apache.conf
echo "		Options Indexes FollowSymLinks MultiViews" >> /projects/$1/conf/apache.conf
echo "		AllowOverride All" >> /projects/$1/conf/apache.conf
echo "		Order allow,deny" >> /projects/$1/conf/apache.conf
echo "		allow from all" >> /projects/$1/conf/apache.conf
echo "	</Directory>" >> /projects/$1/conf/apache.conf
echo " " >> /projects/$1/conf/apache.conf
echo "	ErrorLog /projects/$1/logs/error.log" >> /projects/$1/conf/apache.conf
echo "	LogLevel warn" >> /projects/$1/conf/apache.conf
echo "	CustomLog /projects/$1/logs/access.log combined" >> /projects/$1/conf/apache.conf
echo "</VirtualHost>" >> /projects/$1/conf/apache.conf

cowsay -n < /projects/$1/conf/apache.conf

echo "Linker le fichier de conf dans apache ? (y/n)" 
  read ACCORD 
if [[ ${ACCORD} == "y" ]]
then
 sudo ln -s /projects/$1/conf/apache.conf /etc/apache2/sites-enabled/$1
 sudo /etc/init.d/apache2 restart
fi


echo "Telecharger la derniere version de drupal ? (y/n)" 
  read ACCORD 
if [[ ${ACCORD} == "y" ]]
then
 cd /projects/$1/www/

 drush dl
 cp drupal-*/.htaccess ./
 mv drupal-*/* ./
 echo "And moved to /projects/$1/www/"
 rm -rf drupal-*
 cp sites/default/default.settings.php sites/default/settings.php
 echo "---- Creating /projects/$1/www/sites/default/settings.php"
 echo "---- Setting permissions : /projects/$1/www/sites/default/settings.php"
 mkdir sites/default/files
 echo "---- Creating /projects/$1/www/sites/default/files/"
 chmod 777 sites/default/settings.php
 chmod 777 sites/default/files/ -R
 echo "---- Setting permissions : /projects/$1/www/sites/default/files/"
fi


echo "Creer base de donnée $1 ? (y/n)" 
  read ACCORD 
if [[ ${ACCORD} == "y" ]]
then
 mysql -e "CREATE DATABASE $1"
fi

echo "--- Fill settings.php with database informations"
echo "\$db_url = 'mysql://sqluser:password@localhost/$1';" >> /projects/$1/www/sites/default/settings.php

echo "Installer le site ? (y/n)" 
  read ACCORD 
if [[ ${ACCORD} == "y" ]]
then
 echo "Votre mail : "
 read MAIL
 cd /projects/$1/www/
 drush si6 --site-name=$1 --account-mail=${MAIL}             
fi


