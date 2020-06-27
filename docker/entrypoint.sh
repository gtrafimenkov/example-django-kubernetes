#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright (c) 2020 Gennady Trafimenkov
#
# This is entrypoint script for the application image.
#
# One or more of the following commands is required:
#
#   migrate      - perform migrations
#   debug        - run in debug mode (./manage.py runserver 0:8080)
#   nginx        - serve static files with nginx, proxy the rest to 127.0.0.1:8081
#   app          - run gunicorn application server on 127.0.0.1:8081
#   nginx+app    - run nginx and gunicorn in a single container (for testing)

set -e

if [[ 1 -gt $# ]]; then
    echo "At least one command is required"
    exit 1
fi

for command in $@; do
    case $command in
        migrate)
            pipenv run ./project/manage.py migrate
            ;;
        debug)
            DJANGO_DEBUG=1 pipenv run ./project/manage.py runserver 0:8080
            ;;
        nginx)
            nginx -g "daemon off;"
            ;;
        app)
            cd project && pipenv run gunicorn project.wsgi --bind 0.0.0.0:8081 --workers 2
            ;;
        nginx+app)
            nginx -g "daemon off;" &
            cd project && pipenv run gunicorn project.wsgi --bind 0.0.0.0:8081 --workers 2
            ;;
        create-test-superuser)
            pipenv run ./project/manage.py shell -c "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin')"
            # pipenv run project/manage.py createsuperuser --username admin --email admin@example.com
            ;;
        *)
            echo "Unknown command $command"
            exit 1
            ;;
    esac
done
