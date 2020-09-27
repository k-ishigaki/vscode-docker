FROM ubuntu:20.04
LABEL maintainer="Kazuki Ishigaki<k-ishigaki@frontier.hokudai.ac.jp>"

ARG USER_ID
ARG GROUP_ID

RUN apt-get update && apt-get install -y \
    gettext-base \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create the user for Visual Studio Code server
RUN chown --recursive ${USER_ID}:${GROUP_ID} /root && \
    getent group ${GROUP_ID} || addgroup --quiet --gid ${GROUP_ID} group && \
    getent passwd ${USER_ID} || adduser --quiet --home /root --uid ${USER_ID} --gid ${GROUP_ID} --disabled-login user && \
    echo user ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user

RUN { \
    echo '#!/bin/sh -e'; \
    echo 'sudo chown --recursive ${USER_ID}:${GROUP_ID} /root/.vscode-server'; \
    echo '"$@"'; \
    } | envsubst > /entrypoint && chmod +x /entrypoint
ENTRYPOINT [ "/entrypoint" ]
