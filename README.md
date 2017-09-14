[![](https://images.microbadger.com/badges/version/opennms/horizon-core-web.svg)](https://microbadger.com/images/opennms/horizon-core-web "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/opennms/horizon-core-web.svg)](https://microbadger.com/images/opennms/horizon-core-web "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/opennms/horizon-core-web.svg)](https://microbadger.com/images/opennms/horizon-core-web "Get your own license badge on microbadger.com")

## Supported tags

* `latest`, latest develop release Horizon 21
* `20.0.2-1`, stable Horizon 20
* `20.0.1-1`, stable Horizon 20
* `20.0.0-1`, stable Horizon 20
* `19.1.0-1`, stable Horizon 19
* `19.0.1-1`, stable Horizon 19
* `19.0.0-1`, stable Horizon 19
* `18.0.4-1`, stable Horizon 18
* `18.0.3-1`, stable Horizon 18
* `foundation-2017` release candidate 18.0.4 as base for Meridian
* `foundation-2016` release candidate 17.0.1 as base for Meridian

### latest

* CentOS 7 with OpenJDK 8u144-jdk
* Official PostgreSQL 9.6.3
* Horizon daily develop snapshot

### 20.0.2-1

* CentOS 7 with OpenJDK 8u144-jdk
* Official PostgreSQL 9.6.1
* Horizon 20.0.2-1

### 20.0.1-1

* CentOS 7 with OpenJDK 8u131-jdk
* Official PostgreSQL 9.6.1
* Horizon 20.0.1-1

### 20.0.0-1

* CentOS 7 with OpenJDK 8u131-jdk
* Official PostgreSQL 9.6.1
* Horizon 20.0.0-1

### 19.1.0-1

* CentOS 7 with OpenJDK 8u131-jdk
* Official PostgreSQL 9.6.1
* Horizon 19.1.0-1

### 19.0.1-1

* CentOS 7 with OpenJDK 8u131-jdk
* Official PostgreSQL 9.6.1
* Horizon 19.0.1-1

### 19.0.0-1

* CentOS 7 with OpenJDK 8u131-jdk
* Official PostgreSQL 9.6.1
* Horizon 19.0.0-1

### 18.0.4-1

* CentOS 7 with OpenJDK 8u121-jdk
* Official PostgreSQL 9.5
* Horizon 18.0.4-1

### 18.0.3-1

* CentOS 7 with OpenJDK 8u121-jdk
* Official PostgreSQL 9.5
* Horizon 18.0.3-1

### foundation-2017

* CentOS 7 with OpenJDK 8u121-jdk
* Official PostgreSQL 9.6.1
* Horizon 18.0.4

### foundation-2016

* CentOS 7 with OpenJDK 8u121-jdk
* Official PostgreSQL 9.5
* Horizon 17.0.1

## Horizon Docker files

This repository provides snapshots for Horizon as docker images.
The image provides the Horizon core monitoring services and the web application.

It is recommended to use `docker-compose` to build a service stack using the official PostgreSQL images.
In case you have already a PostgreSQL database running, you can provide the database configuration in the `.opennms.env` and `.postgres.env` environment files.

The compose file uses two data container.
They are not running and just for persisting data purposes:

* opennms_data: RRD/JRobin files, logs and configuration files
* db_data: PostgreSQL database files

IMPORTANT:
As long as you don't delete the `db_data` and `opennms_data` container you keep your data.

For the reason it is required to manually edit OpenNMS configuration files, it is recommended to mount the `/opt/opennms/etc` into a local directory on your host system. In case the directory is empty it will be initialized with a plain configuration from `etc-pristine`.

Just add the volumes directive in `docker-compose.yml` in the opennms service section:
```
volumes:
    - /myhost/opennms/etc:/opt/opennms/etc
```

## Requirements

* docker 1.11+
* docker-compose 1.8.0+
* git
* optional on MacOSX, Docker environment, e.g. Kitematic, boot2docker or similar

## Usage

```
git clone https://github.com/opennms-forge/docker-horizon-core-web.git
cd docker-horizon-core-web
docker-compose up -d
```

The web application is exposed on TCP port 8980. You can login with default user *admin* with password *admin*.
Please change immediately the default password to a secure password.

## Update and Maintenance

The entrypoint script is used to control starting behavior.
You can provide the following arguments in you `docker run` command or in your `docker-compose.yml`.

```
-f: Just start Horizon binary and do nothing else.
-i: Initialize database, pristine configuration files and data directory, do not start Horizon
-s: Initialize database, pristine configuration files and data directory and start Horizon
```

In case you want to update existing configuration the configuration initialization is guarded by the `configured` file in `/opt/opennms/etc`.
You can update the database by deleting the `configured` file and run with `-s`.

## Support and Issues

Please open issues in the [GitHub issue](https://github.com/opennms-forge/docker-horizon-core-web) section.

## Author

ronny@opennms.org
