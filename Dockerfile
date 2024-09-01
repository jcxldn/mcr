FROM golang:alpine as dltool-builder

WORKDIR /src

COPY dltool/ .

# Build dltool and make sure it runs properly
RUN go build -ldflags "-s -w" -o /dist/dltool; \
    /dist/dltool

FROM ghcr.io/jcxldn/java:22-jre-adoptium-musl

COPY --from=dltool-builder /dist/dltool /usr/local/bin
COPY entrypoint /runner/entrypoint
COPY runner /runner/runner

# PaperMC Base, libstdc++ for spark
# libc6-compat for Velocity (https://github.com/PaperMC/velocity/commit/f67d85493ee709a52f3ee8cac4ece56af78afade)
# lm-sensors for CoreProtect (uses jSensors which loads glibc libsensors.so if not present)
RUN apk add --no-cache ca-certificates wget libstdc++ lm-sensors-dev libc6-compat; \ 
    chmod +x /runner/entrypoint; \
    chmod +x /runner/runner; \
    adduser -D -h /home/container container;

USER container

ENV PATH="/opt/jdk/bin:${PATH}" \
    SHOULD_CREATE_EULA_TXT=1

WORKDIR /home/container

ENTRYPOINT ["/runner/entrypoint"]
