ARG BASE_IMAGE=
FROM ${BASE_IMAGE}

# Make a pipe fail on the first failure
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

# ensure we only use apk repositories over HTTPS (altough APK contain an embedded signature)
RUN echo "https://alpine.global.ssl.fastly.net/alpine/v$(cut -d . -f 1,2 < /etc/alpine-release)/main" > /etc/apk/repositories \
&& echo "https://alpine.global.ssl.fastly.net/alpine/v$(cut -d . -f 1,2 < /etc/alpine-release)/community" >> /etc/apk/repositories

# Standard non-root user for all Node.js applications
ENV APP_USER=app \
APP_UID=1001 \
APP_GID=1001

# Update base system
RUN apk add --no-cache ca-certificates

# Create standard application directory structure
# /app for everything app-related: /app/conf, /app/tmp, /app/data
RUN mkdir -p /app /app/conf /app/tmp /app/data && \
chmod 755 /app && \
chmod 750 /app/conf /app/tmp /app/data

# Create standard non-root user with predictable UID/GID
RUN addgroup -g $APP_GID -S $APP_USER && \
adduser -u $APP_UID -S $APP_USER -G $APP_USER -s /sbin/nologin -h /app && \
chown -R $APP_USER:$APP_USER /app

# Remove existing crontabs, if any
RUN rm -fr /var/spool/cron \
&& rm -fr /etc/crontabs \
&& rm -fr /etc/periodic

# Remove dangerous commands that could be exploited
RUN find /bin /etc /lib /sbin /usr -xdev \( \
-iname hexdump -o \
-iname chgrp -o \
-iname od -o \
-iname strings -o \
-iname su -o \
-iname sudo -o \
-iname nc -o \
-iname netcat -o \
-iname wget -o \
-iname curl \
\) -delete 2>/dev/null || true

# Remove unnecessary users, keeping only app and root
RUN sed -i -r "/^($APP_USER|root|nobody)/!d" /etc/group \
&& sed -i -r "/^($APP_USER|root|nobody)/!d" /etc/passwd

# Remove interactive login shell for everybody
RUN sed -i -r 's#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd

# Disable all user accounts with password login
RUN while IFS=: read -r username _; do passwd -l "$username" 2>/dev/null || true; done < /etc/passwd

# Remove any end user (whether admin or standard) permissions except for /tmp/
RUN find / -xdev -type d -perm +0002 -exec chmod o-w {} + 2>/dev/null || true \
&& find / -xdev -type f -perm +0002 -exec chmod o-w {} + 2>/dev/null || true \
&& chmod 777 /tmp/ \
&& chown $APP_USER:$APP_USER /tmp/

# Ensure system dirs are owned by root and not writable by anybody else
RUN find /bin /etc /lib /sbin /usr -xdev -type d \
-exec chown root:root {} \; \
-exec chmod 0755 {} \; 2>/dev/null || true

# Remove suid & sgid permissions, which could potentially be exploited for privilege escalation
RUN find /bin /etc /lib /sbin /usr -xdev -type f -a \( -perm +4000 -o -perm +2000 \) -delete 2>/dev/null || true

# Remove init scripts since we do not use them
RUN rm -fr /etc/init.d /lib/rc /etc/conf.d /etc/inittab /etc/runlevels /etc/rc.conf /etc/logrotate.d

# Remove kernel tunables, as they are not relevant in a container environment
RUN rm -fr /etc/sysctl* /etc/modprobe.d /etc/modules /etc/mdev.conf /etc/acpi

# Remove root home dir
RUN rm -fr /root

# Remove temporary shadow/passwd/group files
RUN rm -f /etc/shadow- /etc/passwd- /etc/group-

# Remove any symlinks that we broke during previous steps
RUN find /bin /etc /lib /sbin /usr -xdev -type l -exec test ! -e {} \; -delete 2>/dev/null || true

# Remove fstab
RUN rm -f /etc/fstab

# Security: Set strict umask for new files
RUN echo "umask 0027" >> /etc/profile

# Copy and run post-install script
COPY post-install.sh /usr/local/bin/post-install.sh
RUN chmod +x /usr/local/bin/post-install.sh && \
/usr/local/bin/post-install.sh

# Set working directory to the pre-configured app directory
WORKDIR /app