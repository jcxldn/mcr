FROM ghcr.io/jcxldn/mcr:latest

COPY ./entrypoint.sh /runner/ptero.entrypoint.sh

RUN apk add --no-cache --update curl ca-certificates openssl git tar sqlite fontconfig \
    && chmod +x /runner/ptero.entrypoint.sh

ENV  USER=container HOME=/home/container OVERRIDE_JAR_DL_PATH=/home/container/server.jar

WORKDIR /home/container

ENTRYPOINT ["/runner/ptero.entrypoint.sh"]