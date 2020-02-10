# Django settings for gtd project.
import os

from django.contrib.messages import constants as message_constants

def get_debug_settings():
    return os.environ.get("DJANGO_DEBUG", "").lower() in ["true", "1", "yes", "y"]

DEBUG = get_debug_settings()

BASE_DIR = os.path.dirname(os.path.dirname(__file__))

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = "America/Los_Angeles"

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = "en-us"

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True


MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "project.urls"
LOGIN_URL = "/login"
LOGIN_REDIRECT_URL = "todo:lists"
LOGOUT_REDIRECT_URL = "home"

SESSION_EXPIRE_AT_BROWSER_CLOSE = True
SESSION_SECURITY_WARN_AFTER = 5
SESSION_SECURITY_EXPIRE_AFTER = 12

# See: https://docs.djangoproject.com/en/dev/ref/settings/#wsgi-application
WSGI_APPLICATION = "project.wsgi.application"

INSTALLED_APPS = (
    "django.contrib.admin",
    "django.contrib.admindocs",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.flatpages",
    "django.contrib.messages",
    "django.contrib.sessions",
    "django.contrib.sites",
    "django.contrib.staticfiles",
    "todo",
    "django_extensions",
)

# Static files and uploads

STATIC_URL = "/static/"
STATICFILES_DIRS = [os.path.join(BASE_DIR, "project", "static")]
STATIC_ROOT = os.path.join(BASE_DIR, "static")

# Uploaded media
MEDIA_ROOT = os.path.join(BASE_DIR, "media")
MEDIA_URL = "/media/"

# Without this, uploaded files > 4MB end up with perm 0600, unreadable by web server process
FILE_UPLOAD_PERMISSIONS = 0o644

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [os.path.join(BASE_DIR, "project", "templates")],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.template.context_processors.i18n",
                "django.template.context_processors.media",
                "django.template.context_processors.static",
                "django.template.context_processors.tz",
                "django.contrib.messages.context_processors.messages",
                # Your stuff: custom template context processors go here
            ]
        },
    }
]

# Override CSS class for the ERROR tag level to match Bootstrap class name
MESSAGE_TAGS = {message_constants.ERROR: "danger"}

####################################################################
# Environment specific settings
####################################################################

SECRET_KEY = os.environ.get('SECRET_KEY', 'lksdf98wrhkjs88dsf8-324ksdm')

# DEBUG = True
ALLOWED_HOSTS = ["*"]

def get_db_settings():
    CPHTEST_ENVIRONMENT = os.environ.get('CPHTEST_ENVIRONMENT', 'local')

    if CPHTEST_ENVIRONMENT == "local":
        return {
            'default': {
                'ENGINE': 'django.db.backends.sqlite3',
                'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
            }
        }

    if CPHTEST_ENVIRONMENT == "k8s":
        return {
            'default': {
                'ENGINE':   os.environ.get('DB_ENGINE',   'django.db.backends.postgresql'),
                'NAME':     os.environ.get('DB_NAME',     'cphtest'),
                'USER':     os.environ.get('DB_USER',     'cphtestuser'),
                'PASSWORD': os.environ.get('DB_PASSWORD', 'django'),
                'HOST':     os.environ.get('DB_HOST',     'p1-postgresql.default.svc.cluster.local'),
                'PORT':     os.environ.get('DB_PORT',     ''),
            },
        }

    return {}

DATABASES = get_db_settings()

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# TODO-specific settings
TODO_STAFF_ONLY = False
TODO_DEFAULT_LIST_SLUG = 'tickets'
TODO_DEFAULT_ASSIGNEE = None
TODO_PUBLIC_SUBMIT_REDIRECT = '/'

####################################################################
#
####################################################################
