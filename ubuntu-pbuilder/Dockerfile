# syntax=docker/dockerfile:1-labs

FROM ubuntu:stonking

LABEL maintainer="Rob Caelers <rob.caelers@gmail.com>"

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
  apt-get install -y debian-archive-keyring binfmt-support pbuilder qemu-user-binfmt devscripts debootstrap && \
  apt-get install -y --reinstall qemu-user-binfmt && \
  apt-get clean

COPY pbuilderrc-build /root/.pbuilderrc

# debootstrap must mount /proc inside the chroot for package configuration.
# Grant mount permissions only to the archive-creation step.
RUN --security=insecure set -eu; \
  for dist in stonking resolute noble jammy; do \
    echo "Creating ${dist} base archive for ${TARGETARCH}"; \
    archive="/var/cache/pbuilder/base-${dist}.tgz"; \
    _PYTHON_SUBPROCESS_USE_POSIX_SPAWN=0 ARCH="${TARGETARCH}" DIST="$dist" \
      pbuilder --create --distribution "$dist" --basetgz "$archive"; \
    test -s "$archive"; \
    tar -tzf "$archive" > /dev/null; \
  done

# Replace with the runtime pbuilderrc that enables the remaining mounts
COPY pbuilderrc /root/.pbuilderrc

CMD ["/bin/bash"]
