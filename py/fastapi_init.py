#!/usr/bin/python3
import os
import sys
import random
import string
import subprocess
import re
from pathlib import Path

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

APP_ROOT = Path(__file__).parent.parent

def touch(path):
    with open(path, 'a'):
        os.utime(path, None)

def random_string_digits(string_length=32):
    """Generate a random string of letters and digits """
    letters_and_digits = string.ascii_letters + string.digits
    return ''.join(random.choice(letters_and_digits) for i in range(string_length))


def show_help():
    os.system('clear')
    print('')
    print(f'{bcolors.WARNING}- startapp{bcolors.ENDC} - create new project structure')
    print(f'{bcolors.WARNING}- config{bcolors.ENDC} - generate default config')
    print(f'{bcolors.WARNING}- config_db{bcolors.ENDC} - config database')
    print(f'{bcolors.WARNING}- req{bcolors.ENDC} - create requirements file')
    print(f'{bcolors.WARNING}- frontend / front{bcolors.ENDC} - create {bcolors.WARNING}VUE JS{bcolors.ENDC} project')
    print(f'{bcolors.WARNING}- front_run{bcolors.ENDC} - run front application')
    print(f'{bcolors.WARNING}- front_build{bcolors.ENDC} - build front application / result dist folder')
    print('')


if len(sys.argv) > 1:
    command = sys.argv[1]

    if command == 'help':
        show_help()

    if command == 'startapp':

        print(f'{bcolors.WARNING} --> create project structure{bcolors.ENDC}')

        os.mkdir('app')
        os.chdir('app')

        os.mkdir('models')
        os.mkdir('schemas')
        os.mkdir('core')
        os.mkdir('db')
        os.mkdir('utils')
        os.mkdir('api')

        os.chdir('api')
        os.mkdir('endpoints')

        os.chdir(APP_ROOT)
        os.chdir('app')
        
        touch('__init__.py')
        touch('main.py')

        os.chdir('api')
        touch('__init__.py')
        os.chdir('endpoints')
        touch('__init__.py')

        os.chdir(APP_ROOT)
        os.chdir('app/core')
        touch('__init__.py')

        os.chdir(APP_ROOT)
        os.chdir('app/db')
        touch('__init__.py')        

        os.chdir(APP_ROOT)
        os.chdir('app/models')
        touch('__init__.py')

        os.chdir(APP_ROOT)
        os.chdir('app/schemas')
        touch('__init__.py')

        os.chdir(APP_ROOT)
        os.chdir('app/utils')
        touch('__init__.py')

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

    if command == 'req':
        with open('requirements.txt', 'w') as f:
            process = subprocess.Popen(['pip', 'freeze'], stdout=f)

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
