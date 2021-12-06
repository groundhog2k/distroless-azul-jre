ARG DEBIAN_BASE="11-slim"

FROM buildpack-deps:buster-curl AS builder

# Target Azul java version in the docker image
ARG ZULU_VERSION="zulu11.52.13-ca-jre11.0.13"
# Base URL for the download
ARG ZULU_BASE_URL="https://cdn.azul.com/zulu/bin"

# Download and unpack Azul JRE
RUN mkdir -p /usr/share/jre \
    && curl -fsSL -o /tmp/jre.tar.gz ${ZULU_BASE_URL}/${ZULU_VERSION}-linux_x64.tar.gz \
    && tar -xzf /tmp/jre.tar.gz -C /usr/share/jre --strip-components=1 \
    && chown root:root -R /usr/share/jre
RUN mkdir /symlink \
    && ln -s /usr/share/jre/bin/java /symlink/java

FROM debian:${DEBIAN_BASE} AS debian
RUN apt-get update && apt-get dist-upgrade -y

FROM scratch AS distroless
COPY --from=debian /etc/ld.so.conf.d /etc/ld.so.conf.d
COPY --from=debian /etc/os-release /etc/os-release
COPY --from=debian /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
COPY --from=debian /lib64 /lib64
COPY --from=debian /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
COPY --from=debian /usr/lib/locale /usr/lib/locale
COPY --from=debian /usr/lib/os-release /usr/lib/os-release
COPY --from=debian /usr/share/gcc /usr/share/gcc
COPY --from=debian /usr/share/gdb /usr/share/gdb

FROM scratch
COPY --from=distroless / /
COPY --from=builder /usr/share/jre /usr/share/jre
COPY --from=builder /symlink /usr/bin

ENV LC_ALL=C.UTF-8 JAVA_HOME=/usr/share/jre
USER 1001

ENTRYPOINT [ "/usr/bin/java" ]
