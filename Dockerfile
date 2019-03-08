FROM golang:1-alpine as builder

ARG RCLONE_VERSION="1.46"
ARG ARCH="amd64"

RUN set -ex \
    && apk add --no-cache wget \
    && wget -q "http://downloads.rclone.org/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-${ARCH}.zip" \
    && unzip "rclone-v${RCLONE_VERSION}-linux-${ARCH}.zip" \
    && mv rclone-*-linux-${ARCH}/rclone /usr/bin

FROM golang:1-alpine
COPY --from=builder /usr/bin/rclone /usr/bin/rclone