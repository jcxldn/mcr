FROM adoptopenjdk:14-jre-hotspot


COPY runner /runner/runner
COPY entrypoint /runner/entrypoint

RUN (dpkg -s ca-certificates 2>/dev/null >/dev/null || (echo 'Installing ca-certificates...' && apt-get update && apt-get install -y ca-certificates)) && \
    sed -i 's/http:\/\/archive.ubuntu.com/https:\/\/ubuntu-cf-cdn.jcx.ovh/;s/http:\/\/security.ubuntu.com/https:\/\/ubuntu-security-cf-cdn.jcx.ovh/;s/http:\/\/ports.ubuntu.com/https:\/\/ubuntu-ports-cf-cdn.jcx.ovh/;s/http:\/\/old-releases.ubuntu.com/https:\/\/ubuntu-old-releases-cf-cdn.jcx.ovh/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget jq && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /runner/runner && \
    chmod +x /runner/entrypoint

WORKDIR /data

ENTRYPOINT ["/runner/entrypoint"]

# docker run [..] -v ./data:/data -Xmx1024M -Xms1024M
# All optimizations and auto-updating jar included.