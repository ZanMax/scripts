#!/usr/bin/python3
import os
import sys
import random
import string
import subprocess
import re


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def random_string_digits(string_length=32):
    """Generate a random string of letters and digits """
    letters_and_digits = string.ascii_letters + string.digits
    return ''.join(random.choice(letters_and_digits) for i in range(string_length))


def show_help():
    os.system('clear')
    print('')
    print(f'{bcolors.WARNING}- startapp{bcolors.ENDC} - create new blueprint app')
    print(f'{bcolors.WARNING}- config{bcolors.ENDC} - generate default config')
    print(f'{bcolors.WARNING}- config_db{bcolors.ENDC} - config database')
    print(f'{bcolors.WARNING}- models{bcolors.ENDC} - generate models.py')
    print(f'{bcolors.WARNING}- req{bcolors.ENDC} - create requirements file')
    print(f'{bcolors.WARNING}- gitignore{bcolors.ENDC} - create .gitignore file')
    print(f'{bcolors.WARNING}- frontend / front{bcolors.ENDC} - create {bcolors.WARNING}VUE JS{bcolors.ENDC} project')
    print(f'{bcolors.WARNING}- front_run{bcolors.ENDC} - run front application')
    print(f'{bcolors.WARNING}- front_build{bcolors.ENDC} - build front application / result dist folder')
    print('')


if len(sys.argv) > 1:
    command = sys.argv[1]

    if command == 'help':
        show_help()

    if command == 'startapp':
        command_arg = sys.argv[2]

        os.mkdir(sys.argv[2])
        os.chdir(sys.argv[2])

        with open('__init__.py', 'a') as f:
            f.write("import os\n")
            f.write("from flask import Blueprint\n\n")
            f.write("static_folder = os.path.join(os.pardir, 'static')\n")
            f.write("{0} = Blueprint('admins', __name__, static_folder=static_folder)\n\n".format(sys.argv[2]))
            f.write("from . import views\n")

        with open('views.py', 'a') as f:
            f.write("from . import {0}\n".format(sys.argv[2]))

    if command == 'config':
        with open('config.py', 'a') as f:
            SECRET_KEY = random_string_digits()
            JWT_SECRET_KEY = random_string_digits()
            f.write("SECRET_KEY = '{0}'\n".format(SECRET_KEY))
            f.write("JWT_SECRET_KEY = '{0}'\n".format(JWT_SECRET_KEY))
            f.write("JWT_ACCESS_TOKEN_EXPIRES = False\n")
            f.write("DEBUG = False\n")
            f.write("DATABASE_DEBUG = False\n")
            f.write("SQLALCHEMY_POOL_PRE_PING = True\n")
            f.write("SWAGGER = {'title': 'API Docs','uiversion': 3}\n")

    if command == 'config_db':
        db_host = input("DB host: ")
        db_user = input("DB user: ")
        db_pwd = input("DB password: ")
        db_name = input("DB name: ")

        with open('config.py', 'a') as f:
            f.write("DATABASE_URI = 'mysql+mysqldb://{0}:{1}@{2}/{3}'\n".format(db_user, db_pwd, db_host, db_name))

    if command == 'models':
        with open('config.py', 'r') as f:
            configs = f.readlines()

        for config in configs:
            if 'DATABASE_URI' in config:
                database_uri = re.search(r"(mysql.*)'$", config).group(1)

                with open('models.py', 'w') as f:
                    process = subprocess.Popen(['sqlacodegen', database_uri], stdout=f)

    if command == 'req':
        with open('requirements.txt', 'w') as f:
            process = subprocess.Popen(['pip', 'freeze'], stdout=f)

    if command == 'gitignore':
        pass

    if command == 'frontend' or command == 'front':
        process = subprocess.run(["vue-init webpack frontend"], shell=True)

    if command == 'front_run':
        os.chdir('frontend')
        os.system('npm run dev')

    if command == 'front_build':
        os.chdir('frontend')
        os.system('npm run build')

else:
    show_help()
