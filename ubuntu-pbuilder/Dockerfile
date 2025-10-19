FROM ubuntu:questing

LABEL maintainer "Rob Caelers <rob.caelers@gmail.com>"

ARG GIT_COMMIT_HASH
ARG TARGETARCH
ARG BUILDPLATFORM

ENV WORKRAVE_CONTAINER_COMMIT=${GIT_COMMIT_HASH}
RUN mkdir /workrave && \
  echo ${GIT_COMMIT_HASH} > /workrave/container-commit

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get install -y debian-archive-keyring binfmt-support pbuilder qemu-user-static devscripts debootstrap && \
  apt-get install -y --reinstall qemu-user-static && \
  apt-get clean

COPY pbuilderrc /root/.pbuilderrc

RUN for dist in questing plucky noble jammy; do \
  echo Architecture: ${TARGETARCH}; \
  ARCH=${TARGETARCH} DIST=$dist pbuilder --create --distribution $dist --basetgz /var/cache/pbuilder/base-$dist.tgz; \
  done

CMD ["/bin/bash"]
