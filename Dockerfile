FROM opennms/openjdk:8u161-jdk

LABEL maintainer "Ronny Trommer <ronny@opennms.org>"

ARG OPENNMS_VERSION=develop
ARG MIRROR_HOST=yum.opennms.org

ENV OPENNMS_KARAF_SSH_HOST 0.0.0.0
ENV OPENNMS_KARAF_SSH_PORT 8101

RUN yum -y --setopt=tsflags=nodocs update && \
    rpm -Uvh https://${MIRROR_HOST}/repofiles/opennms-repo-${OPENNMS_VERSION}-rhel7.noarch.rpm && \
    rpm --import https://${MIRROR_HOST}/OPENNMS-GPG-KEY && \
    yum -y install iplike \
                   rrdtool \
                   jrrd2 \
                   opennms-core \
                   opennms-webapp-jetty && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /opt/opennms/logs \
           /var/opennms/rrd \
           /var/opennms/reports && \
    mkdir -p /opennms-data/logs \
             /opennms-data/rrd \
             /opennms-data/reports && \
    ln -s /opennms-data/logs /opt/opennms/logs && \
    ln -s /opennms-data/rrd /var/opennms/rrd && \
    ln -s /opennms-data/reports /var/opennms/reports

COPY ./assets/opennms-datasources.xml.tpl /root
COPY ./assets/org.apache.karaf.shell.cfg.tpl /root
COPY ./assets/opennms-newts-config.properties.tpl /root

COPY ./docker-entrypoint.sh /

## Volumes for storing data outside of the container
VOLUME [ "/opt/opennms/etc", "/opt/opennms-etc-overlay", "/opennms-data" ]

LABEL license="AGPLv3" \
      org.opennms.horizon.version="${OPENNMS_VERSION}" \
      vendor="OpenNMS Community" \
      name="Horizon"

WORKDIR /opt/opennms

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "-h" ]

##------------------------------------------------------------------------------
## EXPOSED PORTS
##------------------------------------------------------------------------------
## -- OpenNMS HTTP        8980/TCP
## -- OpenNMS JMX        18980/TCP
## -- OpenNMS KARAF RMI   1099/TCP
## -- OpenNMS KARAF SSH   8101/TCP
## -- OpenNMS MQ         61616/TCP
## -- OpenNMS Eventd      5817/TCP
## -- SNMP Trapd           162/UDP
## -- Syslog Receiver      514/UDP
EXPOSE 8980 18980 1099 8101 61616 5817 162/udp 514/udp
