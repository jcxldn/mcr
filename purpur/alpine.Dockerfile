FROM jcxldn/minecraft-runner:base-papermc-alpine

ARG PRODUCT=purpur
ENV PRODUCT=$PRODUCT
ARG API_URL=https://purpur.pl3x.net
ENV API_URL=$API_URL