#!/bin/bash
#===========================================
#
# FILE:		owncloud-upgrade.sh
# USAGE:	bash owncloud-upgrade.sh
# DESCRIPTION:	Upgrades your owncloud installation semi-automatically
# REQUIREMENTS:	bash
# BUGS:		Backup restore not working
# NOTES: 	
# AUTHOR:	Raphael Klein
# EMAIL:	raphael.klein@wh-netz.de
# CREATED:	23.02.2013
# REVISION:	0.1
#===========================================

tmpdir=/var/tmp/

### Do not edit below

echo "[$(date --rfc-3339=seconds)] This will allow you to do the following:"
echo " 1) Backup owncloud script (not your data!) [optional]"
echo " 2) Set URL to current version, download it, install it (apache will be stopped shortly!!!) [optional]"
echo " 3) nothing"

echo -n "[$(date --rfc-3339=seconds)] Enter the URL to owncloud tgz: "
read url
if [[ ! $url ]]
then
        echo "[$(date --rfc-3339=seconds)] Nothing done. Quitting."
	exit 1
fi

echo -n "[$(date --rfc-3339=seconds)] Enter the path to owncloud [/var/www/owncloud/]: "
read path
if [[ ! $path ]]
then
        path="/var/www/owncloud/"
fi

echo -n "[$(date --rfc-3339=seconds)] Backup path? (You'll be asked again later) [/var/backups/]: "
read backuppath
if [[ ! $backuppath ]]
then
        backuppath="/var/backups/"
fi

backupurl=$backuppath$(date +"%Y%m%d%H%M")_owncloud-backup.tar.gz
tmpfile=${tmpdir}owncloud.tar.bz2

read -p "[$(date --rfc-3339=seconds)] Backup $path to $backupurl? (y/n) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
        echo -e "\n[$(date --rfc-3339=seconds)] Starting Backup."
	tar cvpzf $backupurl --exclude=${path}data/ $path
        echo "[$(date --rfc-3339=seconds)] Backup was created."
else
        echo -e "\n[$(date --rfc-3339=seconds)] No Backup created."
fi

read -p "[$(date --rfc-3339=seconds)] Download and install $url? (y/n) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
        echo -e "\n[$(date --rfc-3339=seconds)] Downloading $url to $tmpdir."
	wget $url --output-document=$tmpfile
        echo "[$(date --rfc-3339=seconds)] Download complete."
	echo "[$(date --rfc-3339=seconds)] Unpacking $tmpfile."
	tar -xjf $tmpfile -C $tmpdir
	echo "[$(date --rfc-3339=seconds)] Unpacked $tmpfile in $tmpdir."

	read -p "[$(date --rfc-3339=seconds)] Replace everything in $path with new version? This cannot be undone without a backup. (y/n) " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
        	echo -e "\n[$(date --rfc-3339=seconds)] Stopping Apache."
		service apache2 stop
		echo "[$(date --rfc-3339=seconds)] Removing installation ($path)."
		rm -rf ${path}3rdparty/ ${path}COPYING-AGPL ${path}COPYING-README ${path}core/ ${path}db_structure.xml ${path}index.php ${path}lib/ ${path}search/ ${path}status.php ${path}apps/ ${path}files/ ${path}l10n/ ${path}ocs/ ${path}settings/ ${path}AUTHORS ${path}public.php ${path}README ${path}remote.php ${path}themes/ ${path}webapps.php ${path}cron.php
        	echo "[$(date --rfc-3339=seconds)] Copying ${tmpdir}owncloud/ to $path."
		cp -r ${tmpdir}owncloud/* $path
		echo "[$(date --rfc-3339=seconds)] Setting correct permissions to $path."
		chown -R www-data:www-data $path
		echo "[$(date --rfc-3339=seconds)] Starting Apache."
		service apache2 start
	else
        	echo -e "\n[$(date --rfc-3339=seconds)] Installation skipped."
	fi
	
	echo "[$(date --rfc-3339=seconds)] Removing $tmpfile and ${tmpdir}owncloud/."
	rm -rf ${tmpdir}owncloud
	rm $tmpfile
else
        echo -e "\n[$(date --rfc-3339=seconds)] Not installed."
fi

read -p "[$(date --rfc-3339=seconds)] Load Backup? (y/n) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
        echo -e "\n[$(date --rfc-3339=seconds)] Not implemented yet."
else
	echo -e "\n"
fi

exit 1
