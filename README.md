[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/hanoii/ddev-global-cache/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/hanoii/ddev-global-cache/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/hanoii/ddev-global-cache)](https://github.com/hanoii/ddev-global-cache/commits)
[![release](https://img.shields.io/github/v/release/hanoii/ddev-global-cache)](https://github.com/hanoii/ddev-global-cache/releases/latest)

# DDEV Global Cache

## Overview

This add-on integrates Global Cache into your [DDEV](https://ddev.com/) project.

## Installation

```bash
ddev add-on get hanoii/ddev-global-cache
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev describe` | View service status and used ports for Global Cache |
| `ddev logs -s global-cache` | Check Global Cache logs |
| `ddev ssh -s global-cache` | Open a shell in the Global Cache container |

## Advanced Customization

To change the Docker image:

```bash
ddev dotenv set .ddev/.env.global-cache --global-cache-docker-image="ddev/ddev-utilities:latest"
ddev add-on get hanoii/ddev-global-cache
ddev restart
```

Make sure to commit the `.ddev/.env.global-cache` file to version control.

All customization options (use with caution):

| Variable | Flag | Default |
| -------- | ---- | ------- |
| `GLOBAL_CACHE_DOCKER_IMAGE` | `--global-cache-docker-image` | `ddev/ddev-utilities:latest` |

## Credits

**Contributed and maintained by [@hanoii](https://github.com/hanoii)**
