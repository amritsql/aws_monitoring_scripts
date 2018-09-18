#!/bin/bash -x
PATH=$PATH:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
echo $PATH
##### considering /mongodb/db_backups is the backup location for mongo database #####
backup_location="/mongodb/db_backups"



rm -rf $backup_location/* > /opt/script/flow.log
DIR=`date +%m%d%y_%H%M%S`
DEST=$backup_location/MONGO$DIR

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
