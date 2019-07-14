ARG ALPINE_VERSION=3.10

# Package Distribution
FROM getft/packages:0.1.0 as packages

# Python Dependencies
FROM alpine:$ALPINE_VERSION as python

RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories
RUN apk add python python-dev libffi-dev gcc py-pip py-virtualenv linux-headers musl-dev openssl-dev make

COPY requirements.txt /requirements.txt

RUN pip install -r /requirements.txt --install-option="--prefix=/dist" --no-build-isolation

# Geodesic base image
FROM alpine:$ALPINE_VERSION

ENV BANNER "getFT"
ENV FZF_COLORS "solarized_dark"
ENV HOME /conf

# Install all packages as root
USER root

# Use TLS for alpine default repos
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories && \
    echo "@testing https://alpine.global.ssl.fastly.net/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "@community https://alpine.global.ssl.fastly.net/alpine/edge/community" >> /etc/apk/repositories

# Install alpine package manifest
COPY packages.txt /etc/apk/

RUN apk add --update $(grep -v '^#' /etc/apk/packages.txt) && \
    mkdir -p /etc/bash_completion.d/ /etc/profile.d/ /conf && \
    touch /conf/.gitconfig

RUN echo "net.ipv6.conf.all.disable_ipv6=0" > /etc/sysctl.d/00-ipv6.conf

# Disable vim from reading a swapfile (incompatible with goofys)
RUN mkdir -p /etc/vim
RUN echo 'set noswapfile' >> /etc/vim/vimrc

# NodeJS Dependencies
RUN npm install -g \
      serverless@1.45.1

# Copy python dependencies
COPY --from=python /dist/ /usr/

# Copy installer over to make package upgrades easy
COPY --from=packages /packages/install/ /packages/install/

# Copy package binaries
COPY --from=packages /packages/bin/ /usr/local/bin/

# Configure aws-okta to easily assume roles
ENV AWS_OKTA_ENABLED=false

# AWS
ENV AWS_DATA_PATH=/localhost/.aws
ENV AWS_CONFIG_FILE=${AWS_DATA_PATH}/config
ENV AWS_SHARED_CREDENTIALS_FILE=${AWS_DATA_PATH}/credentials

# Configure aws-vault to easily assume roles (not related to HashiCorp Vault)
ENV AWS_VAULT_ENABLED=true
ENV AWS_VAULT_SERVER_ENABLED=false
ENV AWS_VAULT_BACKEND=file
ENV AWS_VAULT_ASSUME_ROLE_TTL=1h
ENV AWS_VAULT_SESSION_TTL=12h

# Shell
ENV SHELL=/bin/bash
ENV LESS=R
ENV SSH_AGENT_CONFIG=/var/tmp/.ssh-agent

# Override default SSH_KEY path
ENV SSH_KEY=/null_path

# Set a default terminal to "dumb" (headless) to make `tput` happy
ENV TERM=dumb

# Reduce `make` verbosity
ENV MAKEFLAGS="--no-print-directory"
ENV MAKE_INCLUDES="Makefile Makefile.*"

# This is not a "multi-user" system, so we'll use `/etc` as the global configuration dir
# Read more: <https://wiki.archlinux.org/index.php/XDG_Base_Directory>
ENV XDG_CONFIG_HOME=/etc

# Clean up file modes for scripts
RUN find ${XDG_CONFIG_HOME} -type f -name '*.sh' -exec chmod 755 {} \;

# Install "root" filesystem
COPY rootfs/ /

WORKDIR /conf

ENTRYPOINT ["/bin/bash"]
CMD ["-c", "init"]
