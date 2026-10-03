#!/usr/bin/env bash
#
# Download or update the Call to Power II (ctp2) Freeciv mod and install it.
#
# Default mode copies the ctp2 ruleset into the user data directory, so it
# can be used with any installed Freeciv 3.2.x. With --build the whole fork
# is also compiled and installed.
#
# Usage: ctp2-update.sh [options]
#   --build          Also compile and install the fork (meson + ninja)
#   --repo-dir DIR   Where to keep the git checkout  (default ~/src/freeciv-ctp2)
#   --branch NAME    Branch to follow               (default below)
#   --prefix DIR     Install prefix for --build      (default ~/fc-ctp2)
#   --clients LIST   Clients to build with --build   (default gtk4)
#   -h, --help       Show this help
#
# Environment variables CTP2_REPO_URL, CTP2_BRANCH, CTP2_REPO_DIR,
# CTP2_PREFIX, CTP2_CLIENTS and FREECIV_USER_DATA override the defaults.
# CTP2_MESON_ARGS replaces the extra meson options used by --build
# (default: no sound, no modpack installer, no ruleset editor).

# Everything runs inside main() so that bash has parsed the whole script
# before 'git pull' possibly replaces this very file.
main() {
  set -euo pipefail

  local repo_url="${CTP2_REPO_URL:-https://github.com/kognar-dev/freeciv.git}"
  local branch="${CTP2_BRANCH:-claude/sweet-wozniak-6ym99r}"
  local repo_dir="${CTP2_REPO_DIR:-$HOME/src/freeciv-ctp2}"
  local prefix="${CTP2_PREFIX:-$HOME/fc-ctp2}"
  local clients="${CTP2_CLIENTS-gtk4}"
  local user_data="${FREECIV_USER_DATA:-$HOME/.freeciv/3.2}"
  local meson_args="${CTP2_MESON_ARGS:--Daudio=none -Dfcmp= -Dtools=}"
  local build=0

  while [ $# -gt 0 ]; do
    case "$1" in
      --build) build=1 ;;
      --repo-dir) repo_dir="$2"; shift ;;
      --branch) branch="$2"; shift ;;
      --prefix) prefix="$2"; shift ;;
      --clients) clients="$2"; shift ;;
      -h|--help) sed -n '3,19p' "$0" | sed 's/^# \{0,1\}//'; return 0 ;;
      *) echo "Unknown option: $1 (try --help)" >&2; return 1 ;;
    esac
    shift
  done

  if ! command -v git >/dev/null; then
    echo "git is required." >&2
    return 1
  fi

  # 1. Get or update the source
  if [ -d "$repo_dir/.git" ]; then
    echo "==> Updating $repo_dir ($branch)"
    if [ -n "$(git -C "$repo_dir" status --porcelain --untracked-files=no)" ]; then
      echo "Local changes in $repo_dir, not updating. Commit or stash them first." >&2
      return 1
    fi
    git -C "$repo_dir" fetch origin "$branch"
    git -C "$repo_dir" checkout -q -B "$branch" "origin/$branch"
  else
    echo "==> Cloning $repo_url ($branch) into $repo_dir"
    mkdir -p "$(dirname "$repo_dir")"
    git clone --branch "$branch" "$repo_url" "$repo_dir"
  fi
  echo "    Now at: $(git -C "$repo_dir" log -1 --format='%h %s')"

  # 2. Install the ruleset into the user data directory
  echo "==> Installing ctp2 ruleset into $user_data"
  mkdir -p "$user_data"
  rm -rf "$user_data/ctp2"
  cp -r "$repo_dir/data/ctp2" "$user_data/ctp2"
  cp "$repo_dir/data/ctp2.modpack" "$user_data/"
  # Build system files are not needed at runtime
  rm -f "$user_data/ctp2/Makefile.am" "$user_data/ctp2/.gitignore"

  # 3. Optionally build the fork
  if [ "$build" = 1 ]; then
    local tool
    for tool in meson ninja; do
      if ! command -v "$tool" >/dev/null; then
        echo "$tool is required for --build." >&2
        return 1
      fi
    done
    local builddir="$repo_dir/build-ctp2"
    echo "==> Building into $prefix (clients: ${clients:-none})"
    # shellcheck disable=SC2086 # meson_args is a list of options
    if [ -f "$builddir/build.ninja" ]; then
      meson configure "$builddir" -Dprefix="$prefix" -Dclients="$clients" \
        $meson_args
    else
      rm -rf "$builddir"
      meson setup "$builddir" "$repo_dir" -Dprefix="$prefix" -Dclients="$clients" \
        $meson_args
    fi
    ninja -C "$builddir" install
    if [ -n "$clients" ]; then
      echo "    Start with: $prefix/bin/freeciv-${clients%%,*}"
    fi
  fi

  echo "==> Done. In a new game, type '/rulesetdir ctp2' before starting."
}

main "$@"
