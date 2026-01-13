# SkyPilot + Verda Cloud Testing Scripts

## What is SkyPilot?

[SkyPilot](https://github.com/skypilot-org/skypilot) is an open-source framework for running AI and batch workloads across multiple cloud providers (AWS, GCP, Azure, Kubernetes and Verda Cloud). It provides a unified interface to deploy and manage workloads with automatic cost optimization, fault tolerance, and resource management.

## What is this repo

This repo makes it easy to run fork by checking out the repo and configuring it with Verda Cloud credentials in one go.

Github pull requests in question:

- **[Add Verda Cloud (formerly DataCrunch) provider](https://github.com/skypilot-org/skypilot/pull/8160)**
- **[Add Verda cloud availability fetcher script](https://github.com/skypilot-org/skypilot/pull/8180)**
- **[Add availability csv for Verda Cloud to skypilot-catalog](https://github.com/skypilot-org/skypilot-catalog/pull/166)**
- **[Add availability periodic fetcher for Verda Cloud to skypilot-catalog](https://github.com/skypilot-org/skypilot-catalog/pull/165)**

### Scripts

#### `sky-build-launch.sh`

Builds and launches a SkyPilot job using upcoming Verda Cloud branch (`feat-verda-cloud` from `huksley/skypilot`).

**What it does:**
- Clones the SkyPilot repository and checks out your branch
- Sets up Verda Cloud credentials (prompts if not configured)
- Creates a Python virtual environment using `uv`
- Installs dependencies (Azure CLI, SkyPilot with all extras)
- Runs `sky check` to verify configuration
- Builds the SkyPilot dashboard
- Starts the Sky API server
- Launches a GPU job (default: 1x B200 GPU)

**Environment Variables:**
- `GPU_TYPE`: GPU type to use (default: `B200`)
- `GPU_COUNT`: Number of GPUs (default: `1`)
- `USE_SPOT`: Set to `1` to use spot instances

**Example:**
```bash
GPU_TYPE=A100 GPU_COUNT=2 USE_SPOT=1 ./sky-build-launch.sh
```

To shutdown skypilot cluster, use sky down <cluster-name>

#### `sky-cleanup.sh`

Cleans up all SkyPilot-related files and configurations.

**What it does:**
- Stops the Sky API server
- Removes the cloned SkyPilot directory
- Removes Verda Cloud configuration (`~/.verda`)
- Removes SkyPilot configuration (`~/.sky`)

**Usage:**
```bash
./sky-cleanup.sh
```

## Prerequisites

- `uv` package manager installed
- `npm` for building the dashboard
- Verda Cloud credentials (will be prompted on first run)


## Running manually

After first run of `./sky-build-launch` go to the `sky` folder and run `uv run sky ...`
