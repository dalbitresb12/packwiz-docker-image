#!/usr/bin/env bash

function log() {
  local msg=$1
  echo "[RUNNER] $msg"
}

function setup_workspace() {
  local source=$1
  local target=$2
  if [[ -d "$source" ]]; then
    pushd "$source" >/dev/null || return
    if ! packwiz list >/dev/null; then
      log "Invalid packwiz modpack found at $source, ignoring..."
      return
    fi
    popd >/dev/null || return
    log "Found a valid packwiz modpack at $source, copying to $target..."
    if [[ ! -d "$target" ]]; then
      mkdir -p "$target"
    fi
    cp -a "$source/." "$target/."
  fi
}

setup_workspace "/data" "/workspace"
exec packwiz "$@"
