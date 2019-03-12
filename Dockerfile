FROM golang:1-alpine as builder

ARG RCLONE_VERSION="17d90351916ed512d38a9eb724cc9b80490acaf6"

RUN set -ex \
    && apk add --no-cache wget make bash git \
    && wget -q "https://github.com/ncw/rclone/archive/${RCLONE_VERSION}.zip" \
    && mkdir rclone && unzip -d rclone "${RCLONE_VERSION}.zip" \
    && cd rclone/*/ &&  make install

FROM alpine:3.9

RUN apk update \
        && apk add ca-certificates bash

COPY --from=builder /usr/bin/rclone /usr/bin/rclone
COPY ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
