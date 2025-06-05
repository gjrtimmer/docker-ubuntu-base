FROM docker.io/ubuntu:24.10 AS install

ARG S6_OVERLAY_VERSION=3.2.1.0
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
    S6_OVERLAY_VERSION=$S6_OVERLAY_VERSION \
    TARGETARCH=${TARGETARCH}

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install --no-install-recommends -y tar xz-utils wget gpg coreutils lsb-release ca-certificates tzdata && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/*

COPY assets/install /install
RUN /install && \
    mkdir -p /var/run/s6 /run/s6 /run/s6/container_environment

RUN apt-get remove --purge --allow-remove-essential -y xz-utils wget gpg lsb-release && \
    apt-get autoremove --allow-remove-essential -y && \
    apt-get clean && \
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/* /install

FROM scratch AS runtime
COPY --from=install / /

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
    HOME=/root \
    TERM=xterm \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_VERBOSITY=1 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

WORKDIR "/"
ENTRYPOINT ["/init"]

ARG BUILD_DATE
ARG CI_PROJECT_NAME
ARG CI_PROJECT_URL
ARG VCS_REF_NAME
ARG VCS_REF_SHA

LABEL maintainer="G.J.R. Timmer <gjr.timmer@gmail.com>"
LABEL org.opencontainers.image.version="${BUILD_DATE}"
LABEL org.opencontainers.image.authors="G.J.R. Timmer <gjr.timmer@gmail.com>"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.title="${CI_PROJECT_NAME}"
LABEL org.opencontainers.image.url="${CI_PROJECT_URL}"
LABEL org.opencontainers.image.documentation="${CI_PROJECT_URL}"
LABEL org.opencontainers.image.source="${CI_PROJECT_URL}.git"
LABEL org.opencontainers.image.ref.name=${VCS_REF_NAME}
LABEL org.opencontainers.image.revision=${VCS_REF_SHA}
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.vendor=timmertech.nl
LABEL org.opencontainers.image.base.name="ubuntu:24.10"
