[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/hanoii/ddev-global-cache/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/hanoii/ddev-global-cache/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/hanoii/ddev-global-cache)](https://github.com/hanoii/ddev-global-cache/commits)
[![release](https://img.shields.io/github/v/release/hanoii/ddev-global-cache)](https://github.com/hanoii/ddev-global-cache/releases/latest)

# DDEV Global Cache

## Overview

[DDEV v1.25.6](https://ddev.com/blog/release-v1-25-6/#cache-volumes-for-each-project)
gave each project its own cache volume, mounted at `/mnt/ddev-project-cache`,
and stopped mounting the shared `ddev-global-cache` volume in the `web`
container. Each project now downloads its packages again on its first install.

This add-on mounts `ddev-global-cache` back in `web` at `/mnt/ddev-global-cache`
and points the package manager caches at it, as DDEV did before v1.25.6, so
all projects with this add-on share them again:

| Cache | Location | Set through |
| ----- | -------- | ----------- |
| Composer | `/mnt/ddev-global-cache/composer` | `COMPOSER_CACHE_DIR` |
| npm | `/mnt/ddev-global-cache/npm` | `npm_config_cache` |
| corepack | `/mnt/ddev-global-cache/corepack` | `COREPACK_HOME` |
| pip | `/mnt/ddev-global-cache/pip` | `PIP_CACHE_DIR` |
| Yarn classic | `/mnt/ddev-global-cache/yarn/classic` | `GLOBAL_CACHE_YARN_DIR`, applied with `yarn config set cache-folder` |
| Yarn berry | `/mnt/ddev-global-cache/yarn/berry` | `GLOBAL_CACHE_YARN_DIR`, applied as the `~/.yarn/berry/cache` symlink, used only with `enableGlobalCache` |

The Yarn settings are applied by `.ddev/web-entrypoint.d/global-cache.sh` each
time `web` starts.

## Why

DDEV made caches per project to keep projects apart. A shared cache let one
project's Terminus login carry into every other project.

The package caches are a different case. With many projects, mostly on the
same frameworks, separate caches mean:

- Every new or recreated project downloads the same Composer and npm packages
  again, so first installs are slow, and they need a network connection that a
  shared cache would often make unnecessary.
- Each project keeps its own copy of the same packages, so disk use grows with
  every project.
- `ddev delete` removes the project cache, so deleting and recreating a project
  starts from nothing.

This add-on shares only the package download caches, which mostly hold the same
public packages for every project. Anything that holds credentials or
per-project state, like Terminus or shell history, stays in the project cache.

Packages from private repositories are cached too, so every project with this
add-on can read them. For a project where that matters, either remove the
add-on from it with `ddev add-on remove hanoii/ddev-global-cache`, or keep only
the caches that matter in the project, as below.

> [!TIP]
> To keep a cache in the project, set its variable back to the path DDEV uses
> without this add-on, in `.ddev/.env.web`. For example, for private Composer
> packages:
>
> ```bash
> # .ddev/.env.web
> COMPOSER_CACHE_DIR=/mnt/ddev-project-cache/composer
> ```
>
> The other caches work the same way:
>
> | Variable | Per-project value |
> | -------- | ----------------- |
> | `COMPOSER_CACHE_DIR` | `/mnt/ddev-project-cache/composer` |
> | `npm_config_cache` | `/mnt/ddev-project-cache/npm` |
> | `COREPACK_HOME` | `/mnt/ddev-project-cache/corepack` |
> | `PIP_CACHE_DIR` | `/mnt/ddev-project-cache/pip` |
> | `GLOBAL_CACHE_YARN_DIR` | `/mnt/ddev-project-cache/yarn` |
>
> Values in `.ddev/.env.web` replace the add-on's, see
> [Override Order](https://docs.ddev.com/en/stable/users/configuration/environment-variables/#override-order).
> Run `ddev restart` afterwards.

These stay in the project cache:

- Shell and client history, `n` Node.js downloads: they were already kept per
  project before v1.25.6.
- Terminus: its cache holds the Pantheon login, which DDEV moved to the project
  cache so one project's login doesn't carry into others. To share it anyway,
  set `TERMINUS_CACHE_DIR` in the project:

  ```bash
  ddev config --web-environment-add=TERMINUS_CACHE_DIR=/mnt/ddev-global-cache/terminus/cache
  ```

The caches DDEV v1.25.5 and earlier left in `ddev-global-cache` are used
again, so packages downloaded before the upgrade aren't fetched again.

## Installation

```bash
ddev add-on get hanoii/ddev-global-cache
ddev restart
```

After installation, make sure to commit the `.ddev` directory to version control.

Requires DDEV v1.25.6 or newer. Earlier versions share these caches on their own.

## Clearing the cache

The cache is shared by every project, and `ddev delete` doesn't remove it. To
clear it:

```bash
ddev poweroff
docker volume rm ddev-global-cache
```

DDEV recreates the volume on the next `ddev start`.

## Credits

**Contributed and maintained by [@hanoii](https://github.com/hanoii)**
