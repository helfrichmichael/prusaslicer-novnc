# Prusaslicer noVNC Docker Container

## Overview

This is a super basic noVNC build using supervisor to serve Prusaslicer in your favorite web browser. This was primarily built for users using the [popular unraid NAS software](https://unraid.net), to allow them to quickly hop in a browser, slice, and upload their favorite 3D prints.

A lot of this was branched off of dmagyar's awesome [prusaslicer-vnc-docker](https://hub.docker.com/r/dmagyar/prusaslicer-vnc-docker/) project, but I found it to be a bit complex for my needs and thought this approach would simplify things a lot.

## How to use

### In unraid

If you're using unraid, open your Docker page and under `Template repositories`, add `https://github.com/helfrichmichael/unraid-templates` and save it. You should then be able to Add Container for prusaslicer-novnc. For unraid, the template will default to 6080 for the noVNC web instance.

### Outside of unraid

#### Docker
To run this image, you can run the following command: `docker run --detach --volume=prusaslicer-novnc-data:/configs/ --volume=prusaslicer-novnc-prints:/prints/ -p 8080:8080 -e SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt" 
--name=prusaslicer-novnc prusaslicer-novnc`

This will bind `/configs/` in the container to a local volume on my machine named `prusaslicer-novnc-data`. Additionally it will bind `/prints/` in the container to `superslicer-novnc-prints` locally on my machine, it will bind port `8080` to `8080`, and finally, it will provide an environment variable to keep Prusaslicer happy by providing an `SSL_CERT_FILE`.

#### Docker Compose
To use the pre-built image, simply clone this repository or copy `docker-compose.yml` and run `docker compose up -d`.

To build a new image, clone this repository and run `docker compose up -f docker-compose.build.yml --build -d`

### Using a VNC Viewer

To use a VNC viewer with the container, the default port for TurobVNC is 5900. You can add this port by adding `-p 5900:5900` to your command to start the container to open this port for access. See note below about ports related to `VNC_PORT` environment variable. 


### GPU Acceleration/Passthrough

Like other Docker containers, you can pass your Nvidia GPU into the container using the `NVIDIA_VISIBLE_DEVICES` and `NVIDIA_DRIVER_CAPABILITIES` envs. You can define these using the value of `all` or by providing more narrow and specific values. This has only been tested on Nvidia GPUs.

In unraid you can set these values during set up. For containers outside of unraid, you can set this by adding the following params or similar  `-e NVIDIA_DRIVER_CAPABILITIES="all" NVIDIA_VISIBLE_DEVICES="all"`. If using Docker Compose, uncomment the enviroment variables in the relevant docker-compose.yaml file.

In addition to the information above, to enable **Hardware 3D acceleration** (which helps with visualizing complex models and  sliced layers), you must set an environment variable. You can do this by either adding `-e ENABLEHWGPU=true` to the `docker run` command or including `- ENABLEHWGPU=true` in your Docker Compose configuration.

### Other Environment Variables

Below are the default values for various environment variables:

- `DISPLAY=:0`: Sets the DISPLAY variable (usually left as 0).
- `SUPD_LOGLEVEL=INFO`: Specifies the log level for supervisord. Set to `TRACE` to see output for various commands helps if you are debugging something. See superviosrd manual for possible levels.
- `ENABLEHWGPU=`: Enables HW 3D acceleration. Default is `false` to maintain backward compatability.
- `VGL_DISPLAY=egl`: Advanced setting to target specific cards if you have multiple GPUs
- `NOVNC_PORT=8080`: Sets the port for the noVNC HTML5/web interface.
- `VNC_RESOLUTION=1280x800`: Defines the resolution of the VNC server.
- `VNC_PASSWORD=`: Defaults to no VNC password, but you can add one here.
- `VNC_PORT=5900`: Defines the port for the VNC server, allowing direct connections using a VNC client. Note that the `DISPLAY` number is added to the port number (e.g., if your display is :1, the VNC port accepting connections will be `5901`).

## Links

[Prusaslicer](https://www.prusa3d.com/prusaslicer/)

[TruboVNC] (https://www.turbovnc.org/)

[VirtualGL](https://virtualgl.org/)

[Supervisor](http://supervisord.org/)

[GitHub Source](https://github.com/helfrichmichael/prusaslicer-novnc)

[Docker](https://hub.docker.com/r/mikeah/prusaslicer-novnc)

<a href="https://www.buymeacoffee.com/helfrichmichael" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
