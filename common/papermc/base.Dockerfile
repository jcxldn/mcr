FROM adoptopenjdk:14-jre-hotspot

COPY common/papermc/entrypoint /runner/entrypoint
COPY common/papermc/runner /runner/runner

RUN (dpkg -s ca-certificates 2>/dev/null >/dev/null || (echo 'Installing ca-certificates...' && apt-get update && apt-get install -y ca-certificates)) && \
    apt-get update && \
    apt-get install -y wget jq && \
    rm -rf /var/lib/apt/lists/* && \
	chmod +x /runner/entrypoint && \
	chmod +x /runner/runner

WORKDIR /data

ENTRYPOINT ["/runner/entrypoint"]

# docker run [..] -v ./data:/data -Xmx1024M -Xms1024M
# All optimizations and auto-updating jar included.