#!/usr/bin/env python

from app.models import Setting, User
import os

if __name__ == '__main__':
    Setting().set('pdns_api_url', os.environ.get('PDNS_API_URL', 'http://authoritative:8081/'))
    Setting().set('pdns_api_key', os.environ.get('PDNS_API_KEY', 'pdns'))
    Setting().set('pdns_version', os.environ.get('PDNS_VERSION', '4.1.8'))
    Setting().set('signup_enabled', True if os.environ.get('SIGNUP_ENABLED', 'no').lower() == 'yes' else False)

    firstname = os.environ.get('ADMIN_FIRSTNAME', 'Administrator')
    lastname = os.environ.get('ADMIN_LASTNAME', 'User')
    password = os.environ.get('ADMIN_PASSWORD', 'admin')
    email = os.environ.get('ADMIN_EMAIL', 'admin@example.org')

    user = User(username='admin', plain_text_password=password, email=email, firstname=firstname, lastname=lastname)
    if not user.create_local_user()['status']:
        user.update_local_user()
