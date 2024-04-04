# ORIGINAL REPO  https://github.com/damanikjosh/virtualgl-turbovnc-docker/blob/main/Dockerfile 
ARG UBUNTU_VERSION=22.04

FROM nvidia/opengl:1.2-glvnd-runtime-ubuntu${UBUNTU_VERSION}
LABEL authors="Joshua J. Damanik - vajonam, Michael Helfrich - helfrichmichael"

ARG VIRTUALGL_VERSION=3.1.1-20240228
ARG TURBOVNC_VERSION=3.1.1-20240127
ENV DEBIAN_FRONTEND noninteractive

RUN 
# Install some basic dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget xorg xauth gosu supervisor x11-xserver-utils libegl1-mesa libgl1-mesa-glx \
    locales-all libpam0g libxt6 libxext6 dbus-x11 xauth x11-xkb-utils xkb-data python3 xterm novnc \
    lxde gtk2-engines-murrine gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine arc-theme \
    freeglut3 libgtk2.0-dev libwxgtk3.0-gtk3-dev libwx-perl libxmu-dev libgl1-mesa-glx libgl1-mesa-dri  \
    xdg-utils locales locales-all pcmanfm jq curl git bzip2 gpg-agent software-properties-common \
    && mkdir -p /usr/share/desktop-directories \
    # Install Firefox without Snap.
    && add-apt-repository ppa:mozillateam/ppa \
    && apt update \
    && apt install -y firefox-esr --no-install-recommends \
    # Clean everything up.
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install virtualgl and turbovnc
RUN wget -qO /tmp/virtualgl_${VIRTUALGL_VERSION}_amd64.deb https://packagecloud.io/dcommander/virtualgl/packages/any/any/virtualgl_${VIRTUALGL_VERSION}_amd64.deb/download.deb?distro_version_id=35\
    && wget -qO /tmp/turbovnc_${TURBOVNC_VERSION}_amd64.deb https://packagecloud.io/dcommander/turbovnc/packages/any/any/turbovnc_${TURBOVNC_VERSION}_amd64.deb/download.deb?distro_version_id=35 \
    && dpkg -i /tmp/virtualgl_${VIRTUALGL_VERSION}_amd64.deb \
    && dpkg -i /tmp/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
    && rm -rf /tmp/*.deb

# Install prusaslicer
WORKDIR /slic3r
ADD get_latest_prusaslicer_release.sh /slic3r
RUN chmod +x /slic3r/get_latest_prusaslicer_release.sh \
  && latestSlic3r=$(/slic3r/get_latest_prusaslicer_release.sh url) \
  && slic3rReleaseName=$(/slic3r/get_latest_prusaslicer_release.sh name) \
  && curl -sSL ${latestSlic3r} > ${slic3rReleaseName} \
  && rm -f /slic3r/releaseInfo.json \
  && mkdir -p /slic3r/slic3r-dist \
  && tar -xjf ${slic3rReleaseName} -C /slic3r/slic3r-dist --strip-components 1 \
  && rm -f /slic3r/${slic3rReleaseName} \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get autoclean \
  && groupadd slic3r \
  && useradd -g slic3r --create-home --home-dir /home/slic3r slic3r \
  && mkdir -p /slic3r \
  && mkdir -p /configs \
  && mkdir -p /prints/ \
  && chown -R slic3r:slic3r /slic3r/ /home/slic3r/ /prints/ /configs/ \
  && locale-gen en_US \
  && mkdir /configs/.local \
  && mkdir -p /configs/.config/ \
  && ln -s /configs/.config/ /home/slic3r/ \
  && mkdir -p /home/slic3r/.config/ \
  && echo "XDG_DOWNLOAD_DIR=\"/prints/\"" >> /home/slic3r/.config/user-dirs.dirs \
  && echo "file:///prints prints" >> /home/slic3r/.gtk-bookmarks

# Generate key for novnc and cleanup erros
RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/novnc.pem -out /etc/novnc.pem -days 365 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhost" \
    && rm /etc/xdg/autostart/lxpolkit.desktop \
    && mv /usr/bin/lxpolkit /usr/bin/lxpolkit.ORIG

ENV PATH ${PATH}:/opt/VirtualGL/bin:/opt/TurboVNC/bin

ADD entrypoint.sh /entrypoint.sh
ADD supervisord.conf /etc/

# Add a default file to resize, etc for noVNC.
ADD vncresize.html /usr/share/novnc/index.html

VOLUME /configs/
VOLUME /prints/

ENTRYPOINT ["/entrypoint.sh"]
