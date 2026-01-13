#!/bin/bash
git clone https://github.com/huksley/skypilot/ sky
cd sky
git checkout feat-verda-cloud

if [ ! -f ${HOME}/.verda/config.json ]; then
  echo "Creating ${HOME}/.verda/config.json"
  mkdir -p ${HOME}/.verda
  echo "Enter your Verda Cloud credentials"
  read -p "Enter your client ID: " client_id
  read -p "Enter your client secret: " client_secret
  echo "{\"client_id\": \"$client_id\", \"client_secret\": \"$client_secret\"}" > ${HOME}/.verda/config.json
fi

export UV_PYTHON=3.8
export VIRTUAL_ENV=.venv
uv venv --seed .venv
source .venv/bin/activate
uv pip install --prerelease=allow "azure-cli>=2.65.0"
uv pip install ".[all]"
uv run sky check
npm --prefix sky/dashboard install && npm --prefix sky/dashboard run build
uv run sky api stop
uv run sky api start

EXTRA_ARGS=""
if [[ "$USE_SPOT" == "1" ]] || [[ "$USE_SPOT" == "true" ]]; then
  EXTRA_ARGS="--use-spot"
fi

uv run sky launch --gpus ${GPU_TYPE:-B200}:${GPU_COUNT:-1} ${EXTRA_ARGS:-}
