# Get and install Easy noVNC.
FROM golang:1.14-buster AS easy-novnc-build
WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

# Get TigerVNC and Supervisor for isolating the container.
FROM debian:buster
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/share/desktop-directories

# Get all of the remaining dependencies for the OS, VNC, and Prusaslicer.
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends lxterminal nano wget openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip && \
    rm -rf /var/lib/apt/lists

RUN apt update && apt install -y --no-install-recommends --allow-unauthenticated \
        lxde gtk2-engines-murrine gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine arc-theme \
        freeglut3 libgtk2.0-dev libwxgtk3.0-gtk3-dev libwx-perl libxmu-dev libgl1-mesa-glx libgl1-mesa-dri  \
        xdg-utils locales locales-all pcmanfm jq curl git firefox-esr \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install Prusaslicer
# Many of the commands below were derived and pulled from previous work by dmagyar on GitHub.
# Here's their Dockerfile for reference https://github.com/dmagyar/prusaslicer-vnc-docker/blob/main/Dockerfile.amd64
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
  # We can now set the Download directory for Firefox and other browsers. 
  # We can also add /prints/ to the file explorer bookmarks for easy access.
  && echo "XDG_DOWNLOAD_DIR=\"/prints/\"" >> /home/slic3r/.config/user-dirs.dirs \
  && echo "file:///prints prints" >> /home/slic3r/.gtk-bookmarks 

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY menu.xml /etc/xdg/openbox/
COPY supervisord.conf /etc/
EXPOSE 8080

VOLUME /configs/
VOLUME /prints/

# It's time! Let's get to work! We use /configs/ as a bindable volume for Prusaslicers configurations. We use /prints/ to provide a location for STLs and GCODE files.
CMD ["bash", "-c", "chown -R slic3r:slic3r /home/slic3r/ /configs/ /prints/ /dev/stdout && exec gosu slic3r supervisord"]