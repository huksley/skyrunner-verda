#!/bin/bash

if [ -d sky ]; then
  echo "Stopping sky API"
  (cd sky && uv run sky api stop)
  rm -Rf sky
fi

if [ -d ${HOME}/.verda ]; then
  echo "Removing ${HOME}/.verda"
  rm -Rf ${HOME}/.verda
fi

rm -Rf ${HOME}/.sky
