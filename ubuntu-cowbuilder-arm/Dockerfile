FROM ubuntu:mantic

LABEL maintainer "Rob Caelers <rob.caelers@gmail.com>"

ARG GIT_COMMIT_HASH
ENV WORKRAVE_CONTAINER_COMMIT=${GIT_COMMIT_HASH}
RUN mkdir /workrave && \
    echo ${GIT_COMMIT_HASH} > /workrave/container-commit

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get install -y debian-archive-keyring cowbuilder pbuilder qemu-user-static debootstrap binfmt-support && \
  apt-get clean

COPY pbuilderrc /root/.pbuilderrc

RUN update-binfmts --display; \
    for dist in mantic lunar jammy focal; do \
       ARCH=arm64 DIST=$dist cowbuilder --create --distribution $dist --basepath /var/cache/pbuilder/base-$dist.cow; \
    done

CMD ["/bin/bash"]
