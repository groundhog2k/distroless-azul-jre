FROM buildpack-deps:bullseye-curl AS jre

# Target Azul java version in the docker image
ARG ZULU_VERSION="zulu11.62.17-ca-jre11.0.18"
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

FROM groundhog2k/distroless-base-image:bullseye
# copy unpacked JRE
COPY --from=jre /usr/share/jre /usr/share/jre
# copy symlink
COPY --from=jre /symlink /usr/bin

# adjust image settings (default user, java_home and locales)
ENV LC_ALL=C.UTF-8 JAVA_HOME=/usr/share/jre
USER 1001
ENTRYPOINT [ "/usr/bin/java" ]
