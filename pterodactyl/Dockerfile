FROM ghcr.io/jcxldn/mcr:latest

COPY ./pterodactyl/entrypoint.sh /runner/ptero.entrypoint.sh

USER root

RUN apk add --no-cache --update curl ca-certificates openssl git tar sqlite fontconfig \
    && chmod +x /runner/ptero.entrypoint.sh

USER container

ENV USER=container HOME=/home/container OVERRIDE_JAR_DL_PATH=/home/container/server.jar

ENTRYPOINT ["/runner/ptero.entrypoint.sh"]