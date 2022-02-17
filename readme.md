# Exclude iApps LX packages from F5 BigIP UCS backups for faster backups

You can decrease the time it takes to complete an F5 BigIP UCS backup, by excluding the iApps LX packages (especially, Application Services Extension 3) from UCS backups.

In my testing, excluding the iAppx LX packages did not affect the integrity of the backup and restore process, though you have to take an extra step during restore to manually re-install the iApps LX packages: https://support.f5.com/csp/article/K89634428

The exclude-iappslx.sh script will ensure the iApps LX packages are excluded from backups and will timestamp and rename the UCS backup with the version number of the most popular iApps LX package (Application Services Extension 3) to record the AS3 version that was running at the time of the backup (to reference during a restore).

## iApps LX packages _included_ in UCS backup

Here is a test on a BigIP 16.1.2.1 Virtual Edition, with a minimal config, and all iApps LX packages enabled.

```
time tmsh save sys ucs $(echo $HOSTNAME | cut -d'.' -f1)-$(date +%H%M-%m%d%y)
Saving active configuration...
/var/local/ucs/bigip1-cis-gcp-1322-021522.ucs is saved.
real    2m50.259s
user    0m7.524s
sys     0m7.287s
```

## iApps LX packages _excluded_ from UCS backup

And here is the same test with iApps LX packages excluded.

Download the exclude-iappslx.sh script and make it executable.

```
curl -O https://raw.githubusercontent.com/tmarfil/exclude-iappslx-from-f5bigip-ucs-backup/main/exclude-iappslx.sh
chmod +x ./exclude-iappslx.sh
```

Run the script on a BigIP.

```
./exclude-iappslx.sh
```

...or to run in the background and use minimal resources:

```
nice -n 20 ./exclude-iappslx.sh &
```
```
Remounted /usr as read-write.
Current cs.dat file backed up to /var/local/ucs.
Below are the edits made to the iAppsLX section of cs.dat.
#save.2605.save_pre     = iAppsLX_save_pre.sh
#save.2605.dir_opt      = /var/config/rest/iapps/RPMS.save
#save.2605.save_post    = (rm -rf /var/config/rest/iapps/RPMS.save)
#save.2606.file         = /var/config/rest/iapps/disable
Remounted /usr as read-only.
Saving active configuration...
/var/local/ucs/bigip1-cis-gcp-1402-021622-3.32.1.ucs is saved.

real    0m14.219s
user    0m5.758s
sys     0m5.667s
```
