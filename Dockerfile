FROM opennms/openjdk:11.0.3.7-b1

LABEL maintainer "Ronny Trommer <ronny@opennms.org>"

ARG OPENNMS_VERSION="stable"
ARG MIRROR_HOST=yum.opennms.org
ARG OPENNMS_UID=10001

ENV OPENNMS_KARAF_SSH_HOST 0.0.0.0
ENV OPENNMS_KARAF_SSH_PORT 8101
ENV JAVA_OPTS="-Xmx1024m -XX:MaxMetaspaceSize=512m"

RUN yum -y --setopt=tsflags=nodocs update && \
    rpm -Uvh https://${MIRROR_HOST}/repofiles/opennms-repo-${OPENNMS_VERSION/\//-}-rhel7.noarch.rpm && \
    rpm --import https://${MIRROR_HOST}/OPENNMS-GPG-KEY && \
    curl https://yum.opennms.org/stable/rhel7/jicmp/jicmp-2.0.5-1.el7.centos.x86_64.rpm -o /tmp/jicmp.rpm && \
    curl https://yum.opennms.org/stable/rhel7/jicmp6/jicmp6-2.0.4-1.el7.centos.x86_64.rpm -o /tmp/jicmp6.rpm && \
    yum -y install rsync && \
    yum -y install /tmp/jicmp.rpm && \
    yum -y install /tmp/jicmp6.rpm && \
    yum -y install gettext \
                   iplike \
                   rrdtool \
                   jrrd2 \
                   opennms-core \
                   opennms-webapp-jetty \
                   opennms-plugin-protocol-cifs \
                   opennms-webapp-hawtio && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /opt/opennms/logs \
           /var/opennms/rrd \
           /var/opennms/reports && \
    mkdir -p /opennms-data/logs \
             /opennms-data/rrd \
             /opennms-data/mibs \
             /opennms-data/reports \
             /opt/opennms-etc-overlay \
             /opt/opennms/assets && \
    mv /var/opennms/mibs/compiled /opennms-data/mibs/ && \
    rm -rf /var/opennms/mibs && \
    ln -s /opennms-data/logs /opt/opennms/logs && \
    ln -s /opennms-data/rrd /var/opennms/rrd && \
    ln -s /opennms-data/mibs /var/opennms/mibs && \
    ln -s /opennms-data/reports /var/opennms/reports && \
    mkdir -p /var/opennms/data-pristine && \
    cp -r /opennms-data/* /var/opennms/data-pristine/ && \
    sed -r -i '/RUNAS/s/root/opennms/' /opt/opennms/bin/opennms && \
    sed -r -i '/RUNAS/s/root/opennms/' /opt/opennms/bin/install && \
    sed -r -i '/RUNAS/s/root/opennms/' /opt/opennms/bin/upgrade && \
    sed -r -i '/^myuser/s/=.*/=$RUNAS/' /opt/opennms/bin/install && \
    sed -r -i '/^myuser/s/=.*/=$RUNAS/' /opt/opennms/bin/upgrade && \
    sed -r -i '/^myuser/s/=.*/=$RUNAS/' /opt/opennms/bin/opennms && \
    sed -r -i 's/"162"/"1162"/' /opt/opennms/etc/trapd-configuration.xml && \
    sed -r -i 's/"162"/"1162"/' /opt/opennms/share/etc-pristine/trapd-configuration.xml && \
    groupadd -g ${OPENNMS_UID} opennms && \
    useradd -u ${OPENNMS_UID} -g ${OPENNMS_UID} -r -d /opt/opennms -s /usr/bin/bash opennms && \
    cp /etc/skel/.bash* /opt/opennms/ && \
    chown opennms:opennms -R /opt/opennms /opennms-data /opt/opennms-etc-overlay && \
    chgrp -R 0 /opt/opennms /opennms-data /opt/opennms-etc-overlay && \
    chmod -R g=u /opt/opennms /opennms-data /opt/opennms-etc-overlay && \
    setcap cap_net_raw+ep ${JAVA_HOME}/bin/java && \
    echo ${JAVA_HOME}/lib/jli > /etc/ld.so.conf.d/java-latest.conf && \
    ldconfig

COPY ./assets/opennms-datasources.xml.tpl /opt/opennms/assets
COPY ./assets/org.apache.karaf.shell.cfg.tpl /opt/opennms/assets
COPY ./assets/newts.properties.tpl /opt/opennms/assets

COPY ./docker-entrypoint.sh /

LABEL license="AGPLv3" \
      org.opennms.horizon.version="${OPENNMS_VERSION}" \
      vendor="OpenNMS Community" \
      name="Horizon"

WORKDIR /opt/opennms
USER ${OPENNMS_UID}

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "-f" ]

##------------------------------------------------------------------------------
## EXPOSED PORTS
##------------------------------------------------------------------------------
## -- OpenNMS HTTP        8980/TCP
## -- OpenNMS JMX        18980/TCP
## -- OpenNMS KARAF RMI   1099/TCP
## -- OpenNMS KARAF SSH   8101/TCP
## -- OpenNMS MQ         61616/TCP
## -- OpenNMS Eventd      5817/TCP
## -- SNMP Trapd          1162/UDP
## -- Syslog Receiver    10514/UDP
EXPOSE 8980 8101 1162/udp
