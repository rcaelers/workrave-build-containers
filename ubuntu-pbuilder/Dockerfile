FROM ubuntu:resolute

LABEL maintainer "Rob Caelers <rob.caelers@gmail.com>"

ARG GIT_COMMIT_HASH
ARG TARGETARCH
ARG BUILDPLATFORM

ENV WORKRAVE_CONTAINER_COMMIT=${GIT_COMMIT_HASH}
RUN mkdir /workrave && \
  echo ${GIT_COMMIT_HASH} > /workrave/container-commit

RUN \
  export _PYTHON_SUBPROCESS_USE_POSIX_SPAWN=0 && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get dist-upgrade -y && \
  apt-get install -y debian-archive-keyring binfmt-support pbuilder qemu-user-static devscripts debootstrap && \
  apt-get install -y --reinstall qemu-user-static && \
  apt-get clean

COPY pbuilderrc-build /root/.pbuilderrc

RUN for dist in resolute questing noble jammy; do \
  echo Architecture: ${TARGETARCH}; \
  _PYTHON_SUBPROCESS_USE_POSIX_SPAWN=0 ARCH=${TARGETARCH} DIST=$dist pbuilder --create --distribution $dist --basetgz /var/cache/pbuilder/base-$dist.tgz; \
  done

# Replace with the runtime pbuilderrc that has mounts enabled
COPY pbuilderrc /root/.pbuilderrc

CMD ["/bin/bash"]
