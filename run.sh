#!/bin/bash

if ! [ -e ./bin/activate  ] ; then
    ./setup_pyenv.sh
fi
source bin/activate

./make_env.sh

pip show openai
source .env.local
pylint do.py
python3 do.py
