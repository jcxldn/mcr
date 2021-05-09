# jdk required for jlink to find required modules.
FROM jcxldn/openjdk-alpine:16-jdk as jlink

# Recreate CDS Cache
RUN java -Xshare:dump \
	&& apk add --no-cache ca-certificates binutils \
	&& wget -O app.jar https://papermc.io/api/v1/paper/1.15.2/latest/download \
	&& wget -O 2.app.jar https://papermc.io/api/v1/waterfall/1.15/latest/download \
	# 'jdk.zipfs' - required for Spigot.
	# 'jdk.crypto.ec' - required for proper SSL/TLS support. - https://stackoverflow.com/questions/55439599/sslhandshakeexception-with-jlink-created-runtime
	# 'java.scripting' - required for MultiVerse support - https://github.com/dumptruckman/Buscript/blob/master/src/main/java/buscript/ScriptManager.java
	# 'jdk.management' - required for Spark Profiler <https://github.com/lucko/spark>
	# 'jdk.management.agent' - requrired for external JMX monitoring
	# 'jdk.httpserver' - required for Plan <https://github.com/plan-player-analytics/Plan>
	&& JDEPS=jdk.zipfs,jdk.crypto.ec,java.scripting,jdk.management,jdk.management.agent,jdk.httpserver,$(jdeps --ignore-missing-deps --list-deps --multi-release 14 app.jar 2.app.jar | awk -F'/' '{print $1}' | tr -d '[[:blank:]]' | sed ':a;N;$!ba;s/\n/,/g') \
	&& echo "Found deps: $JDEPS" \
	# Set java option to prevent 'exec spawn helper' error > https://stackoverflow.com/questions/61301818/java-failed-to-exec-spawn-helper-error-since-moving-to-java-14-on-linux
	&& _JAVA_OPTIONS="-Djdk.lang.Process.launchMechanism=vfork" jlink  --no-header-files --no-man-pages --compress=2 --strip-debug --module-path /opt/java/openjdk/jmods --add-modules $JDEPS --output /jlinked


# mc-monitor go binary for docker healthchecking
FROM golang:alpine as mcmonitor

RUN apk add --no-cache git \
    && git clone --depth 1 -b 0.8.0 https://github.com/itzg/mc-monitor \
    && cd mc-monitor \
    && GOOS=linux go build -ldflags="-s -w"

# Based on "docker.io/jcxldn/openjdk-alpine:14-jre", but without java.

FROM alpine:3.12

COPY common/papermc/entrypoint /runner/entrypoint
COPY common/papermc/runner /runner/runner
COPY common/papermc/healthcheck /runner/healthcheck

# Add glibc
RUN export GLIBC_VERSION="2.31-r1"; \
	mkdir -p /lib /lib64 /usr/glibc-compat/lib/locale /usr/glibc-compat/lib64 /etc; \
	apk add --no-cache --virtual .fetch-deps ca-certificates binutils; \
		ARCH="$(apk --print-arch)"; \
		case "${ARCH}" in \
		aarch64|arm64) \
			ZLIB_URL='http://ports.ubuntu.com/ubuntu-ports/pool/main/z/zlib/zlib1g_1.2.11.dfsg-2ubuntu1_arm64.deb'; \
			GLIBC_ARCH='aarch64'; \
			glibc_setup () { \
				ln -s /usr/glibc-compat/lib/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1; \
				ln -s /usr/glibc-compat/lib/ld-linux-aarch64.so.1 /lib64/ld-linux-aarch64.so.1; \
				ln -s /usr/glibc-compat/lib/ld-linux-aarch64.so.1 /usr/glibc-compat/lib64/ld-linux-aarch64.so.1; \
				ln -s /usr/glibc-compat/etc/ld.so.cache /etc/ld.so.cache; \
			}; \
			;; \
			# Download glibc and link
		armhf|armv7l|armv7) \
			ZLIB_URL='http://ports.ubuntu.com/ubuntu-ports/pool/main/z/zlib/zlib1g_1.2.11.dfsg-2ubuntu1_armhf.deb'; \
			# Override GLIBC Version - since 2.28 there is a bug blocking it being used on QEMU
			# https://bugs.launchpad.net/qemu/+bug/1805913
			GLIBC_VERSION="2.27-r1"; \
			GLIBC_ARCH='arm-linux-gnueabihf'; \
			glibc_setup () { \
				ln -s /usr/glibc-compat/lib/ld-linux-armhf.so.3 /lib/ld-linux-armhf.so.3; \
				ln -s /usr/glibc-compat/lib/ld-linux-armhf.so.3 /lib64/ld-linux-armhf.so.3; \
				ln -s /usr/glibc-compat/lib/ld-linux-armhf.so.3 /usr/glibc-compat/lib64/ld-linux-armhf.so.3; \
				ln -s /usr/glibc-compat/etc/ld.so.cache /etc/ld.so.cache; \
			}; \
			;; \
		ppc64el|ppc64le) \
			ZLIB_URL='http://ports.ubuntu.com/ubuntu-ports/pool/main/z/zlib/zlib1g_1.2.11.dfsg-2ubuntu1_ppc64el.deb'; \
			GLIBC_ARCH='ppc64le'; \
			glibc_setup () { \
				ln -s /usr/glibc-compat/lib/ld-linux-powerpc64le.so.2 /lib/ld-linux-powerpc64le.so.2; \
				ln -s /usr/glibc-compat/lib/ld-linux-powerpc64le.so.2 /lib64/ld-linux-powerpc64le.so.2; \
				ln -s /usr/glibc-compat/lib/ld-linux-powerpc64le.so.2 /usr/glibc-compat/lib64/ld-linux-powerpc64le.so.2; \
				ln -s /usr/glibc-compat/etc/ld.so.cache /etc/ld.so.cache; \
				# Special case for ppc64le.
				ln -s /usr/glibc-compat/lib/ld64.so.2 /lib/ld64.so.2; \
				ln -s /usr/glibc-compat/lib/ld64.so.2 /lib64/ld64.so.2; \
			}; \
			;; \
		s390x) \
			ZLIB_URL='http://ports.ubuntu.com/ubuntu-ports/pool/main/z/zlib/zlib1g_1.2.11.dfsg-2ubuntu1_s390x.deb'; \
			GLIBC_ARCH='s390x'; \
			glibc_setup () { \
				ln -s /usr/glibc-compat/lib/ld-linux-s390x.so.2 /lib/ld-linux-s390x.so.2; \
				ln -s /usr/glibc-compat/lib/ld-linux-s390x.so.2 /lib64/ld-linux-s390x.so.2; \
				ln -s /usr/glibc-compat/lib/ld-linux-s390x.so.2/usr/glibc-compat/lib64/ld-linux-s390x.so.2; \
				ln -s /usr/glibc-compat/etc/ld.so.cache /etc/ld.so.cache; \
				# Special case for s390x.
				ln -s /usr/glibc-compat/lib/ld64.so.1 /lib/ld64.so.1; \
				ln -s /usr/glibc-compat/lib/ld64.so.1 /lib64/ld64.so.1; \
			}; \
			;; \
		amd64|x86_64) \
			ZLIB_URL='http://archive.ubuntu.com/ubuntu/pool/main/z/zlib/zlib1g_1.2.11.dfsg-2ubuntu1_amd64.deb'; \
			GLIBC_ARCH='x86_64'; \
			glibc_setup () { \
				ln -s /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2; \
				ln -s /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2; \
				ln -s /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /usr/glibc-compat/lib64/ld-linux-x86-64.so.2; \
				ln -s /usr/glibc-compat/etc/ld.so.cache /etc/ld.so.cache; \
				ln -sfn /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib; \
			}; \
			;; \
		*) \
			echo "Unsupported arch: ${ARCH}"; \
			exit 1; \
			;; \
		esac; \
		# Download glibc from repo
		wget -O- https://github.com/Prouser123/docker-glibc-multiarch-builder/releases/download/jcx-${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}-${GLIBC_ARCH}.tar.gz | tar zxvf - -C /; \
		# Link glibc
		glibc_setup; \
		
		# Download additional files
		wget https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/ld.so.conf -O /usr/glibc-compat/etc/ld.so.conf; \
	wget https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/nsswitch.conf -O /etc/nsswitch.conf; \
		
		# Download zlib
		mkdir -p /tmp/zlib; \
		cd /tmp/zlib; \
		wget -O zlib.deb ${ZLIB_URL}; \
		ar vx zlib.deb; \
		tar xvf data.tar.xz; \
		mv lib/$(ls lib)/* /usr/glibc-compat/lib/; \
		
		# Run strip on stuff
		strip /usr/glibc-compat/sbin/**; \
		strip /usr/glibc-compat/lib64/**; \
		strip /usr/glibc-compat/lib/** || echo 'Probably done with errors'; \
		strip /usr/glibc-compat/lib/*/* || echo 'Probably done with errors'; \
		
		# Remove unused files (https://github.com/sgerrand/alpine-pkg-glibc/blob/master/APKBUILD)
		rm /usr/glibc-compat/etc/rpc; \
		rm -rf /usr/glibc-compat/bin; \
		rm -rf /usr/glibc-compat/sbin; \
		rm -rf /usr/glibc-compat/lib/gconv; \
		rm -rf /usr/glibc-compat/lib/getconf; \
		rm -rf /usr/glibc-compat/lib/audit; \
		rm -rf /usr/glibc-compat/share; \
		rm -rf /usr/glibc-compat/var; \
		
		# Remove object files and static libraries. (https://blog.gilliard.lol/2018/11/05/alpine-jdk11-images.html)
		rm -rf /usr/glibc-compat/*.o; \
		rm -rf /usr/glibc-compat/*.a; \
		rm -rf /usr/glibc-compat/*/*.o; \
		rm -rf /usr/glibc-compat/*/*.a; \
		
		# 08/08/2020 hotfix for waterfall - added libstdc++ and libgcc and symlink
		# ----- Hotfix Start -----
 
		# Install libs
		apk add --no-cache libstdc++ libgcc; \
		
		# Strip libs to save space
		strip /usr/lib/libstdc++.so.6; \
		strip /usr/lib/libgcc_s.so.1; \
		
		# Link libs to other lib folders
		ln -sfn /usr/lib/libstdc++.so.6 /usr/glibc-compat/lib; \
		ln -sfn /usr/lib/libstdc++.so.6 /lib; \
		
		ln -sfn /usr/lib/libgcc_s.so.1 /usr/glibc-compat/lib; \
		ln -sfn /usr/lib/libgcc_s.so.1 /lib; \
		# ----- Hotfix End -----
		
		# Cleaning up...
		apk del --purge .fetch-deps; \
		rm -rf /var/cache/apk/*; \
		rm -rf /tmp/zlib; \
		
		# PaperMC Base
		apk add --no-cache ca-certificates wget jq; \ 
		chmod +x /runner/entrypoint; \
		chmod +x /runner/runner; \
		chmod +x /runner/healthcheck;

COPY --from=jlink /jlinked /opt/jdk/
COPY --from=mcmonitor /go/mc-monitor/mc-monitor /sbin/

ENV PATH="/opt/jdk/bin:${PATH}"

WORKDIR /data

ENTRYPOINT ["/runner/entrypoint"]

HEALTHCHECK --start-period=1m CMD /runner/healthcheck

# docker run [..] -v ./data:/data -Xmx1024M -Xms1024M
# All optimizations and auto-updating jar included.
