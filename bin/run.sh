#!/bin/bash

set -e

[ "$DEBUG" == "1" ] && set -x && set +e

if [ "${GLUSTER_PEER}" == "**ChangeMe**" ]; then
   echo "ERROR: You did not specify "GLUSTER_PEER" environment variable - Exiting..."
   exit 0
fi

if [ "${RANCHER_SERVER_URL}" != "**ChangeMe**" ]; then
   # Stuff for active-passive load balancing because game does not share sessions across containers
   # Unused on 1.0 version
   # Get load balancer data
   lbconfig=`wget -O- "${RANCHER_SERVER_URL}/v1/loadbalancers"`
   lb_id=`echo $lbconfig | jq -r '.data | .[] | select(. name=="${BALANCER}") | .id'`
   lbcontainers=`wget -O- "${RANCHER_SERVER_URL}/v1/loadbalancers/$lb_id/loadbalancertargets"`
   lb_instances=`echo $lbcontainers | jq -r '.data | .[] | .instanceId'`
   echo "upstream nodejs {" > ${HTTP_DOCUMENTROOT}/../lb.instances
   for instance in $lb_instances; do
       instance=`wget -O- "${RANCHER_SERVER_URL}/v1/instances/$instance"`
       instance_ip=`echo $instance | jq -r '.primaryIpAddress'`
       echo "   server $instance_ip:${GAME_PORT};" >> ${HTTP_DOCUMENTROOT}/../lb.instances
   done
   echo "}" >> ${HTTP_DOCUMENTROOT}/../lb.instances
fi

echo "=> Mounting GlusterFS volume ${GLUSTER_VOL} from cluster ${GLUSTER_PEER}..."
ping -c 10 ${GLUSTER_PEER} >/dev/null 2>&1
mount -t glusterfs ${GLUSTER_PEER}:/${GLUSTER_VOL} ${GLUSTER_VOL_PATH}

if [ ! -d ${HTTP_DOCUMENTROOT} ]; then
   git clone https://github.com/BonsaiDen/NodeGame-Shooter.git ${HTTP_DOCUMENTROOT}
fi

my_public_ip=`dig -4 @ns1.google.com -t txt o-o.myaddr.l.google.com +short | sed "s/\"//g"`
perl -p -i -e "s/HOST = '.*'/HOST = '${my_public_ip}'/g" ${HTTP_DOCUMENTROOT}/client/config.js
perl -p -i -e "s/PORT = .*;/PORT = ${HTTP_SERVER_PORT};/g" ${HTTP_DOCUMENTROOT}/client/config.js

/usr/bin/supervisord
