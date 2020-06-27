# SPDX-License-Identifier: MIT
# Copyright (c) 2020 Gennady Trafimenkov

FROM ubuntu:18.04

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN echo "== dependencies ==" \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        nano \
        nginx \
        python3-pip \
    && pip3 install pipenv \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/cph-test \
    && echo "done"

WORKDIR /opt/cph-test/

COPY . .

RUN echo "== app dependencies, nginx config, etc. ==" \
    && pipenv install \
    && pipenv run project/manage.py collectstatic --noinput \
    && mv docker/nginx.default /etc/nginx/sites-available/default \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && echo "done"

ENTRYPOINT ["./docker/entrypoint.sh"]
