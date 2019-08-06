FROM golang:1.12 as builder

ARG RCLONE_VERSION="v1.48.0"
ARG DOCKERIZE_VERSION="1.2.0"

WORKDIR /rootfs
RUN set -ex \
    && wget -q https://github.com/presslabs/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz -O /tmp/dockerize.tar.gz \
    && tar -zxf "/tmp/dockerize.tar.gz" -C /rootfs

RUN set -ex \
    && git clone https://github.com/ncw/rclone /rclone

WORKDIR /rclone
RUN set -ex \
    && git checkout ${RCLONE_VERSION} \
    && make install \
    && cp /usr/bin/rclone /rootfs/rclone

COPY /rootfs /rootfs

RUN ls -l /rootfs/

# use distroless/base:nonroot
FROM gcr.io/distroless/base@sha256:559425d074a4632c650930338074b4ec6129dec84942ac449d3777451737d680
ENV GOOGLE_APPLICATION_CREDENTIALS=/tmp/google_credentials.json
COPY --from=builder /rootfs /
ENTRYPOINT ["/dockerize", "-template", "/templates/rclone.conf.tmpl:/tmp/rclone.conf", "-no-overwrite", "-template", "/templates/google_credentials.json.tmpl:/tmp/google_credentials.json", "/rclone", "--config", "/tmp/rclone.conf"]
CMD ["version"]
