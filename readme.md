# django-todo application, Kubernetes ready

## Components

- `todo` - Django application (forked from https://github.com/shacker/django-todo)
- `project` - Django project (forked from https://github.com/shacker/gtd)

## Local development

- install pipenv
- `pipenv install`
- `cd project`
- `./manage.py migrate`
- `./manage.py createsuperuser`
- `./manage.py runserver`
