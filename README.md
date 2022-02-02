# Prusaslicer noVNC Docker Container

## Overview

This is a super basic noVNC build using supervisor to serve Prusaslicer in your favorite web browser. This was primarily built for users using the [popular unraid NAS software](https://unraid.net), to allow them to quickly hop in a browser, slice, and upload their favorite 3D prints.

A lot of this was branched off of dmagyar's awesome [prusaslicer-vnc-docker](https://hub.docker.com/r/dmagyar/prusaslicer-vnc-docker/) project, but I found it to be a bit complex for my needs and thought this approach would simplify things a lot.

## How to use

**In unraid**

If you're using unraid, open your Docker page and under `Template repositories`, add `https://github.com/helfrichmichael/unraid-templates` and save it. You should then be able to Add Container for prusaslicer-novnc. For unraid, the template will default to 6080 for the noVNC web instance.

**Outside of unraid**

To run this image, you can run the following command: `docker run --detach --volume=prusaslicer-novnc-data:/configs/ -p 8080:8080 -e SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt" 
--name=prusaslicer-novnc prusaslicer-novnc`

This will bind `/configs/` in the container to a local volume on my machine named `prusaslicer-novnc-data`, it will bind port `8080` to `8080`, and finally, it will provide an environment variable to keep Prusaslicer happy by providing an `SSL_CERT_FILE`.

## Links

[Prusaslicer](https://www.prusa3d.com/prusaslicer/)

[Supervisor](http://supervisord.org/)

[GitHub Source](https://github.com/helfrichmichael/prusaslicer-novnc)

[Docker](https://hub.docker.com/r/mikeah/prusaslicer-novnc)