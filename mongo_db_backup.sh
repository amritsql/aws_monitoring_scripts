########## PRE-REQUISITES #############
### 1) python installed in linux ##############################################
### 2) aws cli installed in linux, if not can follow below steps for ubuntu ###
###  a)  curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" ##########
###  b) python get-pip.py --user ##############################################
### 3) must have created and assigned s3 role to ec2 instance #################
###############################################################################





#!/bin/bash -x
PATH=$PATH:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
echo $PATH
##### considering /mongodb/db_backups is the backup location for mongo database #####
backup_location="/mongodb/db_backups"
DIR=`date +%m%d%y_%H%M%S`
DEST=$backup_location/MONGO$DIR


if [ -d "$backup_location" ] 
then
    echo "Directory for taking mongo db backup exists." 
else
    mkdir -p $backup_location
fi



rm -rf $backup_location/* > /opt/script/flow.log


if [  -d "$DEST" ]; then
 rm -rf $backup_location/$DEST >> /opt/script/flow.log
fi


mkdir -p $DEST >> /opt/script/flow.log
mongodump -h localhost -d db_name -u user_name -p user_password -o $DEST >> /opt/script/flow.log
tar -cvzf $DEST/MONGO_$DIR.tar $DEST >> /opt/script/flow.log
chown mongodb:mongodb -R $DEST >> /opt/script/flow.log
chmod 755 -R $DEST >> /opt/script/flow.log
gzip $DEST/MONGO_$DIR.tar >> /opt/script/flow.log
sleep 1m >> /opt/script/flow.log
aws s3 cp $DEST/MONGO_$DIR.tar.gz s3://enter-s3-mongo-backup-path --exclude "*" --include "*.gz" >> /opt/script/flow.log

########################################################################################################################
########################################################################################################################
########## SET THIS UP IN CRON FOR DAILY AUTOMATED BACKUP ##############################################################
########## take backup everyday at 5 am ################################################################################
# 0 5 * * * /bin/bash -v /opt/script/mongo_db_backup.sh ################################################################
########################################################################################################################
