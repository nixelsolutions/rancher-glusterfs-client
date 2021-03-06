FROM ubuntu:14.04

MAINTAINER Manel Martinez <manel@nixelsolutions.com>

RUN apt-get update && \
    apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository -y ppa:gluster/glusterfs-3.5 && \
    apt-get update && \
    apt-get install -y git nodejs nginx supervisor glusterfs-client dnsutils


ENV GLUSTER_VOL ranchervol
ENV GLUSTER_VOL_PATH /mnt/${GLUSTER_VOL}
ENV GLUSTER_PEER **ChangeMe**
ENV DEBUG 0

ENV HTTP_CLIENT_PORT 80
ENV GAME_SERVER_PORT 443
ENV HTTP_DOCUMENTROOT ${GLUSTER_VOL_PATH}/asteroids/documentroot

EXPOSE ${HTTP_CLIENT_PORT}
EXPOSE ${GAME_SERVER_PORT}

RUN mkdir -p /var/log/supervisor ${GLUSTER_VOL_PATH}
WORKDIR ${GLUSTER_VOL_PATH}

RUN mkdir -p /usr/local/bin
ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*.sh
ADD ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD ./etc/nginx/sites-available/asteroids /etc/nginx/sites-available/asteroids

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm -f /etc/nginx/sites-enabled/default
RUN ln -fs /etc/nginx/sites-available/asteroids /etc/nginx/sites-enabled/asteroids
RUN perl -p -i -e "s/HTTP_CLIENT_PORT/${HTTP_CLIENT_PORT}/g" /etc/nginx/sites-enabled/asteroids
RUN HTTP_ESCAPED_DOCROOT=`echo ${HTTP_DOCUMENTROOT} | sed "s/\//\\\\\\\\\//g"` && perl -p -i -e "s/HTTP_DOCUMENTROOT/${HTTP_ESCAPED_DOCROOT}/g" /etc/nginx/sites-enabled/asteroids

RUN perl -p -i -e "s/GAME_SERVER_PORT/${GAME_SERVER_PORT}/g" /etc/supervisor/conf.d/supervisord.conf
RUN HTTP_ESCAPED_DOCROOT=`echo ${HTTP_DOCUMENTROOT} | sed "s/\//\\\\\\\\\//g"` && perl -p -i -e "s/HTTP_DOCUMENTROOT/${HTTP_ESCAPED_DOCROOT}/g" /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/local/bin/run.sh"]
