#!/usr/bin/python3
import os
import sys
import random
import string
import subprocess
from re import sub
from pathlib import Path
import stat
import requests


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def show_help():
    os.system('clear')
    print('')
    print(f'{bcolors.WARNING}- init{bcolors.ENDC} - create {bcolors.WARNING}VUE JS{bcolors.ENDC} project')
    print(f'{bcolors.WARNING}- run{bcolors.ENDC} - run front application')
    print(f'{bcolors.WARNING}- build{bcolors.ENDC} - build front application / result dist folder')
    print('')


if len(sys.argv) > 1:
    command = sys.argv[1]

    if command == 'help':
        show_help()

    if command == 'init':
        process = subprocess.run(["vue-init webpack frontend"], shell=True)

    if command == 'run':
        os.chdir('frontend')
        os.system('npm run dev')

    if command == 'build':
        os.chdir('frontend')
        os.system('npm run build')
