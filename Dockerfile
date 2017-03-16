FROM debian:jessie
MAINTAINER djavanargent

# set version for s6 overlay
ARG OVERLAY_VERSION="v1.19.1.1"
ARG OVERLAY_ARCH="amd64"

# set environment variables
ENV \
  DEBIAN_FRONTEND="noninteractive" \
  HOME="/root" \
  LANGUAGE="en_US.UTF-8" \
  LANG="en_US.UTF-8" \
  TERM="xterm" \
  PLEX_DOWNLOAD="https://downloads.plex.tv/plex-media-server" \
  PLEX_INSTALL="https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu" \
  PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
  PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
  PLEX_MEDIA_SERVER_INFO_DEVICE=docker \
  PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
  PLEX_MEDIA_SERVER_USER=media

# generate locale
RUN \
# install apt-utils
  apt-get update && \
  apt-get install -y \
    apt-utils \
    locales && \
  echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen en_US.UTF-8 && \
  dpkg-reconfigure locales && \
  /usr/sbin/update-locale LANG=en_US.UTF-8 && \
# install packages
  apt-get install -y \
    avahi-daemon \
    curl \
    dbus \
    wget && \
# add s6 overlay
  curl -o /tmp/s6-overlay.tar.gz -L "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" && \
  tar zxf /tmp/s6-overlay.tar.gz -C / && \
# create media user
  useradd -u 1001 -U -d /config -s /bin/false media && \
  usermod -G users media && \
# make folders
  mkdir -p \
    /app \
    /config \
    /defaults && \
# install plex
  curl -o /tmp/plexmediaserver.deb -L "${PLEX_INSTALL}" && \
  dpkg -i /tmp/plexmediaserver.deb && \
# change media home folder to fix plex hanging at runtime with usermod
 usermod -d /app media && \

# cleanup
  apt-get clean && \
  rm -rf \
    /etc/default/plexmediaserver \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 32400 32400/udp 32469 32469/udp 5353/udp 1900/udp
VOLUME /config /movies /music /tv

ENTRYPOINT ["/init"]
