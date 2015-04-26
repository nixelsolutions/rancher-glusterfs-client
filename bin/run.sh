#!/bin/bash

[ "$DEBUG" == "1" ] && set -x

if [ "${GLUSTER_PEER}" == "**ChangeMe**" ]; then
   echo "ERROR: You did not specify "GLUSTER_PEER" environment variable - Exiting..."
   exit 0
fi

echo "=> Mounting GlusterFS volume ${GLUSTER_VOL} from cluster ${GLUSTER_PEER}..."
mount -t glusterfs ${GLUSTER_PEER}:/${GLUSTER_VOL}  /mnt/${GLUSTER_VOL}

/usr/bin/supervisord
