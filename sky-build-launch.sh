#!/bin/bash
set -euo pipefail

if [ ! -d sky ]; then
  echo "Cloning SkyPilot repository [Verda Cloud branch]"
  git clone https://github.com/huksley/skypilot/ sky
  (cd sky && git checkout feat-verda-cloud)
fi

cd sky

# Reverse LazyImport bug fix
# curl -o LazyImport.patch https://gist.githubusercontent.com/huksley/aa5bf9420ab101e96294877fc8bcf4f9/raw/b3868efe7bd6a4cda7fa5ebab23406067089c597/LazyImport.patch
# patch -p1 < LazyImport.patch

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

if [ -d .venv ]; then
  echo "Removing existing virtual environment"
  rm -Rf .venv
fi

uv venv --seed .venv
source .venv/bin/activate
uv pip install --prerelease=allow "azure-cli>=2.65.0"
uv pip install ".[all]"
uv run sky check

if [ ! -f sky/dashboard/.next/BUILD_ID ]; then
  echo "Building SkyPilot dashboard (Next.js)"
  npm --prefix sky/dashboard install && npm --prefix sky/dashboard run build
fi

# Fetch Verda Cloud availability
uv run python -m sky.catalog.data_fetchers.fetch_verda

# Run SkyPilot api server at http://127.0.0.1:46580
uv run sky api stop || true
uv run sky api start

EXTRA_ARGS=""
if [[ "$USE_SPOT" == "1" ]] || [[ "$USE_SPOT" == "true" ]]; then
  EXTRA_ARGS="--use-spot"
fi

# Launch one SkyPilot cluster
uv run sky launch --gpus ${GPU_TYPE:-B200}:${GPU_COUNT:-1} ${EXTRA_ARGS:-}

# For running some job, execute this manually
# cd sky && uv run sky exec CLUSTER_NAME ../train.yml
