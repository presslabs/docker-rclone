FROM golang:1.12 as builder

ARG RCLONE_VERSION="v1.47.0"
ARG DOCKERIZE_VERSION="1.2.0"

WORKDIR /rootfs
RUN set -ex \
    && wget -q https://github.com/presslabs/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz -O /tmp/dockerize.tar.gz \
    && tar -zxf "/tmp/dockerize.tar.gz" -C /rootfs

WORKDIR /rclone
RUN set -ex \
    && wget -q "https://github.com/ncw/rclone/archive/${RCLONE_VERSION}.tar.gz"  -O /tmp/rclone.tar.gz \
    && tar -zxf "/tmp/rclone.tar.gz" -C /rclone --strip-components=1 \
    && make install \
    && cp /usr/bin/rclone /rootfs/rclone

COPY /rootfs /rootfs

RUN ls -l /rootfs/

FROM gcr.io/distroless/base:dfa3b24ed3d0987cc1788a04026e3bab03caa9a2
ENV GOOGLE_APPLICATION_CREDENTIALS=/tmp/google_credentials.json
COPY --from=builder /rootfs /
USER nobody
ENTRYPOINT ["/dockerize", "-template", "/templates/rclone.conf.tmpl:/tmp/rclone.conf", "-no-overwrite", "-template", "/templates/google_credentials.json.tmpl:/tmp/google_credentials.json", "/rclone", "--config", "/tmp/rclone.conf"]
CMD ["version"]
