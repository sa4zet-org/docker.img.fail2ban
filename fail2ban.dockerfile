FROM ghcr.io/sa4zet-org/docker.img.debian:latest AS build-stage

ARG docker_img
ENV DOCKER_TAG=$docker_img

RUN apt-get update \
  && apt-get -y install \
    fail2ban \
    nftables

RUN apt-get --purge -y autoremove \
    && apt-get clean \
    && rm -rf /tmp/* /var/lib/apt/lists/*

FROM ghcr.io/sa4zet-org/docker.img.debian:latest AS final-stage
COPY --from=build-stage / /

ENV DOCKER_TAG=ghcr.io/sa4zet-org/docker.img.fail2ban

HEALTHCHECK \
  --interval=3m \
  --retries=2 \
  --timeout=2s \
  CMD fail2ban-client ping || exit 1

ENTRYPOINT [ "fail2ban-server", "-f", "-x", "-v", "--logtarget", "stdout"]
