FROM        ghcr.io/astral-sh/uv:0.8.3-python3.13-alpine@sha256:99ce5a7ebcf37cec9d8df603d816d13e2508401a13df9a8d35598b665ae25b3c 

# renovate: datasource=repology depName=alpine_3_22/gcc versioning=loose
ARG         GCC_VERSION="14.2.0-r6"
# renovate: datasource=repology depName=alpine_3_22/build-base versioning=loose
ARG         BUILD_BASE_VERSION="0.5-r3"
# renovate: datasource=repology depName=alpine_3_22/libffi-dev versioning=loose
ARG         LIBFFI_VERSION="3.4.8-r0"
# renovate: datasource=repology depName=alpine_3_22/libretls-dev versioning=loose
ARG         LIBRETLS_VERSION="3.7.0-r2"
# renovate: datasource=repology depName=alpine_3_22/cargo versioning=loose
ARG         CARGO_VERSION="1.87.0-r0"
# renovate: datasource=repology depName=alpine_3_22/fuse3 versioning=loose
ARG         FUSE3_VERSION="3.16.2-r1"

ARG         TARGETPLATFORM

WORKDIR     /app

ADD         requirements.txt .

RUN         --mount=type=cache,sharing=locked,target=/root/.cache,id=home-cache-$TARGETPLATFORM \
            --mount=type=cache,sharing=locked,target=/root/.cargo,id=home-cargo-$TARGETPLATFORM \
            apk add --no-cache \
              fuse3=${FUSE3_VERSION} \
              libgcc=${GCC_VERSION} \
            && \
            sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf && \
            apk add --no-cache --virtual .build-deps \
              gcc=${GCC_VERSION} \
              build-base=${BUILD_BASE_VERSION} \
              libffi-dev=${LIBFFI_VERSION} \
              libretls-dev=${LIBRETLS_VERSION} \
              fuse3-dev=${FUSE3_VERSION} \
              cargo=${CARGO_VERSION} \
            && \
            uv sync --frozen && \
            apk del .build-deps && \
            chown -R nobody:nogroup /app

COPY        --chown=nobody:nogroup tgmount .

USER        nobody
WORKDIR     /app/data
STOPSIGNAL  SIGINT

HEALTHCHECK --interval=5m --timeout=1m --start-period=2m --retries=5 \
    CMD mountpoint -q /app/data/mnt

ENTRYPOINT  [ "uv", "run", "-m", "tgmount" ]
