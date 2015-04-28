#!/bin/bash

set -e

[ "$DEBUG" == "1" ] && set -x && set +e

if [ "${GLUSTER_PEER}" == "**ChangeMe**" ]; then
   echo "ERROR: You did not specify "GLUSTER_PEER" environment variable - Exiting..."
   exit 0
fi

echo "=> Mounting GlusterFS volume ${GLUSTER_VOL} from cluster ${GLUSTER_PEER}..."
mount -t glusterfs ${GLUSTER_PEER}:/${GLUSTER_VOL} ${GLUSTER_VOL_PATH}

echo "=> Setting up asteroids game..."
if [ ! -d ${HTTP_DOCUMENTROOT} ]; then
   git clone https://github.com/BonsaiDen/NodeGame-Shooter.git ${HTTP_DOCUMENTROOT}
fi

if [ `echo ${TYPE} | tr '[:lower:]' '[:upper:]'` == "GAME_SERVER" ]; then
   my_public_ip=`dig -4 @ns1.google.com -t txt o-o.myaddr.l.google.com +short | sed "s/\"//g"`
   perl -p -i -e "s/HOST = '.*'/HOST = '${my_public_ip}'/g" ${HTTP_DOCUMENTROOT}/client/config.js
   perl -p -i -e "s/PORT = .*;/PORT = ${HTTP_SERVER_PORT};/g" ${HTTP_DOCUMENTROOT}/client/config.js
fi

/usr/bin/supervisord
