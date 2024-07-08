FROM harbor.local/docker.io/ubuntu:24.04

ARG S6_OVERLAY_VERSION=3.2.0.0
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
    S6_OVERLAY_VERSION=$S6_OVERLAY_VERSION \
    TARGETARCH=${TARGETARCH}

RUN apt-get update && \
    apt-get install --no-install-recommends -y tar xz-utils wget gpg coreutils lsb-release ca-certificates tzdata

ADD assets/install /install
RUN /install

RUN apt-get remove --purge --allow-remove-essential -y xz-utils wget gpg lsb-release && \
    apt-get autoremove --allow-remove-essential -y && \
    apt-get clean && \
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/* /install

FROM scratch AS runtime
COPY --from=0 / /

ENV PATH=/command:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
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
ARG VCS_REF

LABEL \
    maintainer="G.J.R. Timmer <gjr.timmer@gmail.com>" \
    build_version="${BUILD_DATE}" \
    org.opencontainers.image.authors="G.J.R. Timmer <gjr.timmer@gmail.com>" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.title="${CI_PROJECT_NAME}" \
    org.opencontainers.image.url="${CI_PROJECT_URL}" \
    org.opencontainers.image.documentation="${CI_PROJECT_URL}" \
    org.opencontainers.image.source="${CI_PROJECT_URL}.git" \
    org.opencontainers.image.ref.name=${VCS_REF} \
    org.opencontainers.image.revision=${VCS_REF} \
    org.opencontainers.image.base.name="ubuntu:24.04" \
    org.opencontainers.image.licenses=MIT \
    org.opencontainers.image.vendor=timmertech.nl
