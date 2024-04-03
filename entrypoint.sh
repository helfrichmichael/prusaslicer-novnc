#!/bin/bash -x 
set -e
rm -f /tmp/.X*-lock
rm -f /tmp/.X11-unix/X*
DISPLAY=${DISPLAY:-:10}
DISPLAY_NUMBER=$(echo $DISPLAY | cut -d: -f2)
export NOVNC_PORT=${NOVNC_PORT:-8080}
VNC_RESOLUTION=${VNC_RESOLUTION:-1280x800}
if [ -n "$VNC_PASSWORD" ]; then
  mkdir -p /root/.vnc
  echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd
  chmod 0600 /root/.vnc/passwd
fi
# vncserver "$DISPLAY" -securitytypes TLSNone,X509None,None -depth 24 -geometry "$VNC_RESOLUTION"
# websockify -D --web=/usr/share/novnc/ "$NOVNC_PORT" localhost:$((5900 + DISPLAY_NUMBER))
# echo "NoVNC server started on port $NOVNC_PORT"
# EXEC=$@
# exec "$@"
export VGLRUN=vglrun
chown -R slic3r:slic3r /home/slic3r/ /configs/ /prints/ /dev/stdout && exec gosu slic3r supervisord # -e TRACE
