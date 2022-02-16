#!/usr/bin/env bash

FILE="/usr/libdata/configsync/cs.dat"
ORIGINALDIR=${PWD}
BACKUPDIR="/var/local/ucs"

# record current version of as3.
AS3_VERSION=$(curl -s -u admin:fakepass http://localhost:8100/mgmt/shared/appsvcs/info | jq -r '.version')

# remount /user as rw:
mount -o remount,rw /usr/
echo Remounted /var as read-write.

cd ${BACKUPDIR}

# backup and timestamp current cs.dat file
cp  ${FILE} cs.dat-$(date +%s)
echo Current cs.dat file backed up to ${BACKUPDIR}.
echo Below are the edits made to the iAppsLX section of cs.dat.

# comment out the iAppsLX section
sed -e '/2605/ s/^#*/#/' -i ${FILE}
sed -e '/2606/ s/^#*/#/' -i ${FILE}

# output relevant lines
cat ${FILE} | grep '2605\|2606'

# remount /usr as ro:
mount -o remount,ro /usr/
echo Remounted /var as read-only.

cd $ORIGINALDIR

# UCS backup. The backup name shows:
# - Device hostname
# - Backup timestamp
# - AS3 version running at time of backup. During restore you will have to manually re-install the iControl LX extensions including AS3.
time tmsh save sys ucs $(echo $HOSTNAME | cut -d'.' -f1)-$(date +%H%M-%m%d%y)-$AS3_VERSION
