#ddev-generated
# Points the yarn caches at GLOBAL_CACHE_YARN_DIR, undoing what the web
# container's start.sh sets up in /mnt/ddev-project-cache. It runs after
# start.sh, so this wins. An environment variable can't do this:
# YARN_CACHE_FOLDER would also move a berry project's own .yarn/cache.
# This file is sourced by start.sh, so it runs in a subshell and never fails.
(
  yarn_dir="${GLOBAL_CACHE_YARN_DIR:-/mnt/ddev-global-cache/yarn}"
  mkdir -p /mnt/ddev-global-cache/{composer,corepack,npm,pip} "${yarn_dir}"/{classic,berry}

  # yarn classic (v1)
  cd ~ &&
    { timeout 1 yarn config set cache-folder "${yarn_dir}/classic" >/dev/null ||
      echo "cache-folder \"${yarn_dir}/classic\"" >>~/.yarnrc; }

  # yarn berry, only used by projects that set enableGlobalCache
  mkdir -p ~/.yarn/berry &&
    ln -sfn "${yarn_dir}/berry" ~/.yarn/berry/cache
) || echo "global-cache.sh: unable to fully set up the global cache" >&2
