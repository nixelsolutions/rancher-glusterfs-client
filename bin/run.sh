#!/bin/bash

[ "$DEBUG" == "1" ] && set -x

if [ "${GLUSTER_PEER}" == "**ChangeMe**" ]; then
   echo "ERROR: You did not specify "GLUSTER_PEER" environment variable - Exiting..."
   exit 0
fi

echo "=> Mounting GlusterFS volume ${GLUSTER_VOL} from cluster ${GLUSTER_PEER}..."
mount -t glusterfs ${GLUSTER_PEER}:/${GLUSTER_VOL}  /mnt/${GLUSTER_VOL}

echo "=> Configuring nginx..."
[ -e /etc/nginx/sites-enabled/default ] && rm -f /etc/nginx/sites-enabled/default
[ ! -L /etc/nginx/sites-enabled/asteroids ] && pushd /etc/nginx/sites-enabled && ln -s ../sites-available/asteroids . && popd

if [ ! -d /mnt/${GLUSTER_VOL}/asteroids ]; then
   echo "=> Setting up asteroids game..."
   pushd /mnt/${GLUSTER_VOL}
   git clone https://github.com/BonsaiDen/NodeGame-Shooter.git
   mv NodeGame-Shooter asteroids
   my_public_ip=`dig -4 @ns1.google.com -t txt o-o.myaddr.l.google.com +short | sed "s/\"//g"`   
   perl -p -i -e "s/HOST = '.*'/HOST = '$my_public_ip'/g" asteroids/client/config.js
   perl -p -i -e "s/PORT = .*;/PORT = 82;/g" asteroids/client/config.js
   popd
fi

/usr/bin/supervisord
