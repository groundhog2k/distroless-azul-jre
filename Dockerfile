FROM buildpack-deps:bullseye-curl AS distroless

# Debian rootfs download
ARG BULLSEYE_ROOTFS="https://github.com/debuerreotype/docker-debian-artifacts/raw/b3d13cfc071091e16812b6147f26e822b3a8ff92/bullseye/slim/rootfs.tar.xz"
# ARG BOOKWORM_ROOTFS="https://github.com/debuerreotype/docker-debian-artifacts/raw/de5fb2efd50a009baa2aaccd2b7874ec728bd7a9/bookworm/slim/rootfs.tar.xz"

WORKDIR /debianroot
RUN apt-get update && apt-get install -y xz-utils
# download and extract debian rootfs into workdir
RUN curl -SL ${BULLSEYE_ROOTFS} -o rootfs.tar.xz
# extract only the minimum that is necessary to execute JRE
RUN tar xvf rootfs.tar.xz usr/lib/locale lib/x86_64-linux-gnu lib64 etc/os-release etc/ld.so.conf.d etc/debian_version usr/lib/x86_64-linux-gnu usr/lib/os-release --same-owner

# remove downloaded archive
RUN rm rootfs.tar.xz

FROM buildpack-deps:bullseye-curl AS jre

# Target Azul java version in the docker image
ARG ZULU_VERSION="zulu11.54.25-ca-jre11.0.14.1"
# Base URL for the download
ARG ZULU_BASE_URL="https://cdn.azul.com/zulu/bin"

# Download and unpack Azul JRE
RUN mkdir -p /usr/share/jre \
    && curl -fsSL -o /tmp/jre.tar.gz ${ZULU_BASE_URL}/${ZULU_VERSION}-linux_x64.tar.gz \
    && tar -xzf /tmp/jre.tar.gz -C /usr/share/jre --strip-components=1 \
    && chown root:root -R /usr/share/jre
# create a symlink to java executable
RUN mkdir -p /symlink \
    && ln -s /usr/share/jre/bin/java /symlink/java

FROM scratch
# copy debian rootfs parts
COPY --from=distroless /debianroot /
# copy unpacked JRE
COPY --from=jre /usr/share/jre /usr/share/jre
# copy symlink
COPY --from=jre /symlink /usr/bin

# adjust image settings (default user, java_home and locales)
ENV LC_ALL=C.UTF-8 JAVA_HOME=/usr/share/jre
USER 1001
ENTRYPOINT [ "/usr/bin/java" ]