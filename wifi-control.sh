#!/usr/bin/env bash

docker stop wifi
unifyRunDir="$HOME/unify"
unifyBackupDir="/mnt/g/My Drive/Unify"
if [ -d "$unifyBackupDir" ]; then
  rsync -ravP "$unifyRunDir/" "$unifyBackupDir/"
else
  echo "Backup Dir Not Mounted"
  exit 1
fi

docker rm wifi

docker run -d \
  --name=wifi \
  -e PUID=1000 \
  -e PGID=1000 \
  -p 3478:3478/udp \
  -p 10001:10001/udp \
  -p 8080:8080 \
  -p 8443:8443 \
  -p 1900:1900/udp \
  -p 8843:8843 \
  -p 8880:8880 \
  -p 6789:6789 \
  -p 5514:5514/udp \
  -v "$unifyRunDir:/config" \
  --restart unless-stopped \
  lscr.io/linuxserver/unifi-controller

docker start wifi

echo "Fixing Permissions in 15 secs"
sleep 15

sudo chmod -R 777 ./run ./logs ./data ./custom-cont-init.d ./custom-*
docker restart wifi
