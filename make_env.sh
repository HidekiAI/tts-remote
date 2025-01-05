#!/bin/bash
set -o nounset                              # Treat unset variables as an error
_TARGET_CONFIG="config.json"

cp config.sample.json ${_TARGET_CONFIG}

if ! [ -e .env.local ] ; then
    echo "ERROR: Unable to lcoate '.env.local' file"
    exit 1
fi

source .env
if [ -z "${_EL_KEY_FROM_ENV_}" ] || [ "${_EL_KEY_FROM_ENV_}" == "DO NOT EDIT: Update .env.local" ] ; then
    echo "ERROR: Make sure to set _EL_KEY_FROM_ENV_ with your ElevenLabs API Key in .env.local"
    exit 2
fi

if [ -z "${_OAI_KEY_FROM_ENV_}" ] || [ "${_OAI_KEY_FROM_ENV_}" == "DO NOT EDIT: Update .env.local"  ] ; then
    echo "ERROR: Make sure to set _OAI_KEY_FROM_ENV_ with your OpenAI API key in .env.local"
    exit 3
fi

sed -i "s/_OAI_KEY_FROM_ENV_/${_OAI_KEY_FROM_ENV_}/g" ${_TARGET_CONFIG}
sed -i "s/_EL_KEY_FROM_ENV_/${_EL_KEY_FROM_ENV_}/g" ${_TARGET_CONFIG}
sed -i "s/_DEFAULT_OPEN_AI_PROMPT_FROM_ENV_/${_DEFAULT_OPEN_AI_PROMPT_FROM_ENV_}/g" ${_TARGET_CONFIG}

cat ${_TARGET_CONFIG}
