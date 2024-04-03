#!/bin/bash
set -e
rm -f /tmp/.X*-lock
rm -f /tmp/.X11-unix/X*
export DISPLAY=${DISPLAY:-:0}
DISPLAY_NUMBER=$(echo $DISPLAY | cut -d: -f2)
export NOVNC_PORT=${NOVNC_PORT:-8080}
export VNC_PORT=${VNC_PORT:-5900}
VNC_RESOLUTION=${VNC_RESOLUTION:-1280x800}
if [ -n "$VNC_PASSWORD" ]; then
  mkdir -p /root/.vnc
  echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd
  chmod 0600 /root/.vnc/passwd
  export VNC_SEC=
else
  export VNC_SEC="-securitytypes TLSNone,X509None,None"
fi
export LOCALFBPORT=$((${VNC_PORT} + DISPLAY_NUMBER))
export VGLRUN="${VGLRUN:-/usr/bin/vglrun}"
export SUPD_LOGLEVEL="${SUPD_LOGLEVEL:-TRACE}"
export VGL_DISPLAY="${VGL_DISPLAY:-egl}"

# fix perms and launch supervisor with the above environment variables
chown -R slic3r:slic3r /home/slic3r/ /configs/ /prints/ /dev/stdout && exec gosu slic3r supervisord -e $SUPD_LOGLEVEL
