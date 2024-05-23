FROM ghcr.io/jcxldn/java:22-jdk-adoptium-musl as jlink

# Recreate CDS Cache
RUN java -Xshare:dump \
    && apk add --no-cache ca-certificates binutils \
    # Required modules:
    # - 'java.base' - Base Java implementation
    # - 'jdk.unsupported' - sun.misc.Unsafe
    # - 'jdk.security.auth' - needed for paper to start correctly
    # - 'jdk.zipfs' - File system provider for .zip and .jar files (required to read resources from .jar file)
    # - 'jdk.crypto.ec' - required for proper SSL/TLS support. - https://stackoverflow.com/questions/55439599/sslhandshakeexception-with-jlink-created-runtime
    # - 'java.xml' - Java XML API (fabric uses org.xml.sax)
    # - 'java.desktop' - AWT/JavaBeans/etc - Java UI - Even with the nogui option fabric loads JavaBeans so this whole module is required
    # - 'java.management' - JMX (JVM monitoring and management)
    # - 'java.logging' - Java Logging API (Fabric loads this on startup in addition to log4j)
    # - 'java.sql' - JDBC API (also uses java.xml)
    # - 'java.naming' -  Java Naming and Directory Interface (JNDI) API
    #    - NOTE: 'java.naming' is not required for fabric to start, without it a warning will be displayed.
    # - 'java.compiler' - Required for the Fabric API to load correctly (uses java.compiler/javax.annotation.processing.Messager)
    # - 'java.scripting' - Required for Purpur
    && JDEPS=java.base,jdk.unsupported,jdk.security.auth,jdk.zipfs,jdk.crypto.ec,java.xml,java.desktop,java.management,java.logging,java.sql,java.naming,java.compiler,java.scripting \
    && echo "Using deps: $JDEPS" \
    # Set java option to prevent 'exec spawn helper' error > https://stackoverflow.com/questions/61301818/java-failed-to-exec-spawn-helper-error-since-moving-to-java-14-on-linux
    && _JAVA_OPTIONS="-Djdk.lang.Process.launchMechanism=vfork" jlink  --no-header-files --no-man-pages --compress=2 --strip-debug --module-path /opt/java/openjdk/jmods --add-modules $JDEPS --output /jlinked

FROM golang:alpine as dltool-builder

WORKDIR /src

COPY dltool/ .

# Build dltool and make sure it runs properly
RUN go build -ldflags "-s -w" -o /dist/dltool; \
    /dist/dltool

FROM alpine:latest

COPY --from=jlink /jlinked /opt/jdk/
COPY --from=dltool-builder /dist/dltool /usr/local/bin
COPY entrypoint /runner/entrypoint
COPY runner /runner/runner

# PaperMC Base, libstdc++ for spark
RUN apk add --no-cache ca-certificates wget libstdc++; \ 
    chmod +x /runner/entrypoint; \
    chmod +x /runner/runner; \
    adduser -D -h /home/container container;

USER container

ENV PATH="/opt/jdk/bin:${PATH}" \
    SHOULD_CREATE_EULA_TXT=1

WORKDIR /home/container

ENTRYPOINT ["/runner/entrypoint"]