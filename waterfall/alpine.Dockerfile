FROM jcxldn/minecraft-runner:base-papermc-alpine

ARG PRODUCT=waterfall
ENV PRODUCT=$PRODUCT
ARG API_URL=https://papermc.io
ENV API_URL=$API_URL

# Install yq (yaml processor) for healthcheck
# Until we update to alpine 3.13, we don't have yq by default in our repos
RUN echo "@edgecommunity https://dl-cdn.alpinelinux.org/alpine/edge/community" > /etc/apk/repositories \
    && apk add --no-cache yq@edgecommunity