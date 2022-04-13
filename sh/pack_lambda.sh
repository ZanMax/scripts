#!/bin/bash

echo "Packaging Python Lambda"

pythondir=$(ls venv/lib)
echo "Python: " $pythondir

source venv/bin/activate
cd venv/lib/$pythondir/site-packages
zip -r ../../../../deployment-package.zip .
cd ../../../../
zip -g deployment-package.zip lambda_function.py

echo "deployment-package.zip ready to deploy"