# This image is based off of ironpeakservices/hardened-alpine with a few minor tweaks

# This is the latest version as of 2/2/2021
FROM alpine:3.13.1

# make a pipe fail on the first failure
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

# Update all packages
RUN apk update --no-cache

# Add needed packages
RUN apk add --no-cache openssh

# Set envrionment variables

# User apps should be using
ENV APP_USER=app
# Home directory
ENV APP_HOME_DIR=/${APP_USER}
# Where persistent data should be stored
ENV DATA_DIR=${APP_HOME_DIR}/data
# Where configuration should be stored
ENV CONF_DIR=${APP_HOME_DIR}/conf

# Add custom user and setup home directory
RUN adduser -s /bin/true -u 1000 -D -h ${APP_HOME_DIR} ${APP_USER} \
  && mkdir ${DATA_DIR} ${CONF_DIR} \
  && chown -R ${APP_USER} ${APP_HOME_DIR} $CONF_DIR \
  && chmod 700 ${APP_HOME_DIR} ${DATA_DIR} ${CONF_DIR}

# Remove cron jobs
RUN rm -fr /var/spool/cron && \
	rm -fr /etc/crontabs && \
	rm -fr /etc/periodic

# Remove all accounts except root and app
# RUN sed -i -r "/^('${APP_USER}'|root|nobody)/!d" /etc/group && \
#     sed -i -r "/^('${APP_USER}'|root|nobody)/!d" /etc/passwd

# Remove interactive login shell for everybody
RUN sed -i -r 's#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd

# Disable password login for everybody
RUN while IFS=: read -r username _; do passwd -l "$username"; done < /etc/passwd || true

# Remove temp shadow,passwd,group
RUN find /bin /etc /lib /sbin /usr -xdev -type f -regex '.*-$' -exec rm -f {} +

# Ensure system dirs are owned by root and not writable by anybody else.
RUN find /bin /etc /lib /sbin /usr -xdev -type d \
  -exec chown root:root {} \; \
  -exec chmod 0755 {} \;

# Remove suid & sgid files
RUN find /bin /etc /lib /sbin /usr -xdev -type f -a \( -perm +4000 -o -perm +2000 \) -delete

# Remove dangerous commands
RUN find /bin /etc /lib /sbin /usr -xdev \( \
  -iname hexdump -o \
  -iname chgrp -o \
  -iname ln -o \
  -iname od -o \
  -iname strings -o \
  -iname su -o \
  -iname sudo \
  \) -delete

# Remove init scripts since we do not use them.
RUN rm -fr /etc/init.d /lib/rc /etc/conf.d /etc/inittab /etc/runlevels /etc/rc.conf /etc/logrotate.d

# Remove root home dir
RUN rm -fr /root

# Remove fstab
RUN rm -f /etc/fstab

# Remove any symlinks that we broke during previous steps
RUN find /bin /etc /lib /sbin /usr -xdev -type l -exec test ! -e {} \; -delete

# add-in post installation file for permissions
COPY post-install.sh ${APP_HOME_DIR}/
RUN chmod 500 ${APP_HOME_DIR}/post-install.sh

USER ${APP_USER}

# default directory is /app
WORKDIR ${APP_HOME_DIR}