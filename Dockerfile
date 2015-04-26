FROM ubuntu:14.04

MAINTAINER Manel Martinez <manel@nixelsolutions.com>

RUN apt-get update && \
    apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository -y ppa:gluster/glusterfs-3.5 && \
    apt-get update && \
    apt-get install -y nodejs nginx supervisor glusterfs-client

RUN mkdir -p /var/log/supervisor /mnt/ranchervol

ENV GLUSTER_VOL ranchervol
ENV GLUSTER_PEER **ChangeMe**
ENV DEBUG 0

WORKDIR /mnt/ranchervol

RUN mkdir -p /usr/local/bin
ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*.sh
ADD ./etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD ./etc/nginx/sites-available/asteroids /etc/nginx/sites-available/asteroids
RUN rm -f /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/asteroids /etc/nginx/sites-enabled/asteroids

CMD ["/usr/local/bin/run.sh"]
