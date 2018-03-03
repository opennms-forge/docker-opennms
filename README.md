## Horizon Version Tags

* `drift`, bleeding edge feature release of Horizon 22 with features develop in the [Drift project](https://wiki.opennms.org/wiki/DevProjects/Drift)
* `bleeding`, daily bleeding edge version of Horizon 22 using OpenJDK 8u161-jdk
* `21.0.4-1`, `latest` is a reference to last stable release of Horizon using OpenJDK 8u161-jdk
* `21.0.3-1`, using OpenJDK 8u161-jdk
* `21.0.2-1`, using OpenJDK 8u161-jdk
* `21.0.1-1`, using OpenJDK 8u151-jdk
* `21.0.0-1`, using OpenJDK 8u151-jdk
* `20.1.0-1`, using OpenJDK 8u144-jdk
* `20.0.2-1`, using OpenJDK 8u144-jdk
* `20.0.1-1`, using OpenJDK 8u131-jdk
* `20.0.0-1`, using OpenJDK 8u131-jdk
* `19.1.0-1`, using OpenJDK 8u131-jdk
* `19.0.1-1`, using OpenJDK 8u131-jdk
* `19.0.0-1`, using OpenJDK 8u131-jdk
* `18.0.4-1`, using OpenJDK 8u121-jdk
* `18.0.3-1`, using OpenJDK 8u121-jdk
* `foundation-2017` release candidate Meridian 2017, OpenJDK 8u121-jdk
* `foundation-2016` release candidate Meridian 2016, OpenJDK 8u121-jdk

## General Project Information

* CI/CD Status: [![CircleCI](https://circleci.com/gh/opennms-forge/docker-horizon-core-web.svg?style=svg)](https://circleci.com/gh/opennms-forge/docker-horizon-core-web)
* Container Image Info: [![](https://images.microbadger.com/badges/version/opennms/horizon-core-web:bleeding.svg)](https://microbadger.com/images/opennms/horizon-core-web:bleeding "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/opennms/horizon-core-web:bleeding.svg)](https://microbadger.com/images/opennms/horizon-core-web:bleeding "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/license/opennms/horizon-core-web:bleeding.svg)](https://microbadger.com/images/opennms/horizon-core-web:bleeding "Get your own license badge on microbadger.com") [![Anchore Image Overview](https://anchore.io/service/badges/image/efe8ba583bc83fa02c79f09a6e080280158468e7386a82e698a104656b45ebc4)](https://anchore.io/image/dockerhub/efe8ba583bc83fa02c79f09a6e080280158468e7386a82e698a104656b45ebc4?repo=opennms%2Fhorizon-core-web&tag=bleeding)
* CI/CD System: [CircleCI]
* Docker Container Image Repository: [DockerHub]
* Issue- and Bug-Tracking: [GitHub issue]
* Source code: [GitHub]
* Chat: [IRC] or [Web Chat]
* Maintainer: ronny@opennms.org

## Horizon Docker files

This repository provides snapshots for Horizon as docker images.
The image provides the Horizon core monitoring services and the web application.

It is recommended to use `docker-compose` to build a service stack using the official PostgreSQL image.
In case you have already a PostgreSQL database running, you can provide the database configuration in the `.opennms.env` and `.postgres.env` environment files, otherwise users and database will be created.

Data is by default persisted on your Docker host using a local volume driver for the following data:

```
# PostgreSQL database
psql.data:
  driver: local

# OpenNMS Horizon RRD files, logs and generated PDF reports
opennms.data:
  driver: local

# OpenNMS Horizon configuration files
opennms.etc:
  driver: local
```

It is required to manually edit OpenNMS configuration files, you can add your own configuration files by providing a `etc-overlay` directory.
On startup the files overwrite the default configuration.

```
- ./etc-overlay:/opt/opennms-etc-overlay
```

If you prefer to have you OpenNMS Horizon configuration on your Docker host in a specific directory, you can mount a directory with your config like this:

```
volumes:
    - ./myHorizonConfig:/opt/opennms/etc
```
In case the directory is empty, it will be initialized with a default pristine configuration from `/opt/opennms/share/etc-pristine`.

IMPORTANT: Take care about configurations which can be changed through the Web UI which are persisted on the file system, e.g. users.xml, groups.xml, surveillance-categories.xml, snmp-config.xml, etc.

## Requirements

* docker 17.05.0-ce, build 89658be
* docker-compose 1.17.0, build ac53b73
* git

## Usage

```
git clone https://github.com/opennms-forge/docker-horizon-core-web.git
cd docker-horizon-core-web
docker-compose up -d
```

The web application is exposed on TCP port 8980.
You can login with default user *admin* with password *admin*.
Please change immediately the default password to a secure password.

To get a help for all available container options just run:

```
docker run --rm opennms/horizon-core-web
```

## running with Cassandra / Newts

By default the OpenNMS horizon image will run using rrds for performance data storage. 
However OpenNMS horizon can also be configured to run with Newts/Cassandra. 
Additional Newts/Cassandra run options are included in the docker-entrypoint.sh.
These options can initialise OpenNMS to use Newts and initialise the Newts tables in Cassandra.
A docker-compose file is provided which illustrates how to run OpenNMS with a small single Cassandra node on the same machine.

## Set Java Options

It is easily possible to add Java options to control the behavior of the JVM for performance tuning or debugging.
The environment variable `JAVA_OPTS` is passed on the Java command and can be used to extend or overwrite JVM options.

IMPORTANT: To give more control the Java binary command natively in the docker-entrypoint.sh and Java options in `opennms.conf` are *not* evaluated.
           The java process has PID 1 and

Used in an environment file:
```
env_file:
  - .java.env

cat .java.env
JAVA_OPTS=-XX:+UseParallelGC -XX:+PrintGCDetails -XX:+PrintFlagsFinal
```

Used in docker-compose service environment definition:

```
opennms:
  container_name: opennms.core.web
  image: opennms/horizon-core-web:latest
  environment:
    - JAVA_OPTS=-XX:+UseParallelGC -XX:+PrintGCDetails -XX:+PrintFlagsFinal
```

## Java and Container Heap Memory

To control and isolate resource usage of processes the Kernel feature _cgroups (Control Groups)_ is used.
With the combination of Java there are some additional things to take care of regarding the _Maximum Heap Size_ and limiting memory usage of the container.

By default [JVM ergonomics](https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gc-ergonomics.html) calculates the _Maximum Heaps Size_ based on the Docker host memory and not by the memory set with with _cgroups_.

To ensure the JVM calculates the _Maximum Heap Size_ correct you have two options:

1) Set the correct _Maximum Heap Size_ manually with `-Xmx` see section above _Set Java Options_
2) If no -Xmx option is set, you can automatically calculate the _Maximum Heap Size_ with enabling the experimental cgroup aware feature with

```
JAVA_OPTS=-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
```

As of Java SE 8u131 the JVM is Docker-aware with Docker CPU limits transparently.
As long if `-XX:ParallelGCThreads` or `-XX:CICompilerCount` are not specified, the JVM will apply the Docker CPU limit as the number CPUs and calculates the number of GC and JIT compiler threads just like running on bare metal.

## Update and Maintenance

The entry point script is used to control starting behavior.

```
-f: Apply overlay configuration if exist and just start OpenNMS Horizon
-i: If necessary initialize database, create pristine configuration, do an upgrade and apply the overlay config but do *not* start Horizon
-s: Same as `-i` but start OpenNMS Horizon, this should be the default
```

If you want to enforce an update, create a `/opt/opennms/etc/do-upgrade` file.
Starting with `-i` or `-s` will run the `install -dis` command once to update the configuration and database schema.

## Support and Issues

Please open issues in the [GitHub issue] section.

## Environment Variables

* `POSTGRES_HOST`: PostgreSQL database host, default: `database`
* `POSTGRES_PORT`: Port to access PostgreSQL database, default: `5432`
* `POSTGRES_USER`: PostgreSQL admin user, default: `postgres`
* `POSTGRES_PASSWORD`: PostgreSQL admin password, default: `postgres`
* `OPENNMS_DBNAME`: Database name for OpenNMS Horizon, default: `opennms`
* `OPENNMS_DBUSER`: User to access the OpenNMS Horizon database, default: `opennms`
* `OPENNMS_DBPASS`: Password for OpenNMS Horizon database user, default: `opennms`
* `OPENNMS_KARAF_SSH_HOST`: Listening address for Karaf SSH port, default: `0.0.0.0`
* `OPENNMS_KARAF_SSH_PORT`: SSH port for Karaf, default: `8101`

## Build Argument

* `MIRROR_HOST`: Server with RPM packages, default: `yum.opennms.org`
* `OPENNMS_VERSION`: Version of OpenNMS Horizon RPM files, default: `stable`

[GitHub]: https://github.com/opennms-forge/docker-horizon-core-web.git
[DockerHub]: https://hub.docker.com/r/opennms/horizon-core-web
[GitHub issue]: https://github.com/opennms-forge/docker-horizon-core-web
[CircleCI]: https://circleci.com/gh/opennms-forge/docker-horizon-core-web
[Web Chat]: https://chats.opennms.org/opennms-discuss
[IRC]: irc://freenode.org/#opennms
