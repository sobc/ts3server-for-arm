# ARM Teamspeak Docker Image

This Docker image provides a Teamspeak server specifically built for ARM
architecture. It allows you to easily deploy and run a Teamspeak server on
ARM-based systems with mariadb support.

## Why another Teamspeak Docker image for ARM architecture?

The TeamSpeak executable is only available for x86_64 architecture. Therefore, I
was pleased to find the
[teamspeak3-server-arm](https://github.com/ertagh/teamspeak3-server-arm) image,
which supports ARM architecture.

However, this image lacks support for the MariaDB plugin and some configuration
options. I prefer the way the [official TeamSpeak
image](https://github.com/TeamSpeak-Systems/teamspeak-linux-docker-images)
handles configuration using environment variables, which is more convenient.

Combining these ideas, I created a new image that supports both ARM architecture
and MariaDB, and allows configuration via environment variables.

## Remarks 

Currently, I just pushed an image to dockerhub for aarch64 architecture. For
other architectures, the Dockerfile needs some adjustments. Maybe I will add
support in the future.

## Usage

To use this Teamspeak Docker image, follow these steps:

1. Pull the Docker image from the Docker Hub repository:

    ```bash
    docker pull sobc/teamspeak:aarch64
    ```

2. Run a sample server container:

    ```bash
    docker run -p 9987:9987/udp -p 10011:10011 -p 30033:30033 -e TS3SERVER_LICENSE=accept sobc/teamspeak:aarch64
    ```

3. Access the Teamspeak server:

    Once the container is running, you can access the Teamspeak server using a
    Teamspeak client. Connect to the server using the IP address or hostname of
    the system running the Docker container.

## Configuration

The Docker image supports the same configuration options as the official
TeamSpeak image. You can find them in the official documentation on
[dockerhub](https://hub.docker.com/_/teamspeak) 
