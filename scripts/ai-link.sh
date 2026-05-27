#!/usr/bin/env bash

set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
AI_DIR="${DOTFILES_ROOT}/ai"
ENTITY_DIR="${AI_DIR}/entity"
ENTITY_DIR_ABS="$(cd "${ENTITY_DIR}" && pwd -P)"
MAP_FILE="${AI_DIR}/map.json"

if [ ! -f "${MAP_FILE}" ]; then
  echo "[ai link] map.json not found, skipping"
  exit 0
fi

log() {
  echo "[ai link] $*"
}

log "start"
log "entity_dir=${ENTITY_DIR}"
log "map_file=${MAP_FILE}"

create_link() {
  local src_path="$1"
  local dst_path="$2"
  local action="linked"
  local overwrite=false
  local target target_abs answer

  if [[ -e "${dst_path}" || -L "${dst_path}" ]]; then
    if [[ -L "${dst_path}" ]]; then
      target="$(readlink "${dst_path}")"
      [[ "${target}" != /* ]] && target="$(dirname "${dst_path}")/${target}"

      if [[ -e "${target}" ]]; then
        target_abs="$(cd "$(dirname "${target}")" && pwd -P)/$(basename "${target}")"
      else
        target_abs="${target}"
      fi

      if [[ "${target_abs}" == "${ENTITY_DIR_ABS}"/* ]]; then
        overwrite=true
        action="relinked"
      fi
    fi

    if [[ "${overwrite}" != true ]]; then
      answer=
      if [[ -r /dev/tty && -w /dev/tty ]]; then
        printf "overwrite: %s? [y/N] " "${dst_path}" >/dev/tty
        read -r answer </dev/tty || true
      fi

      case "${answer}" in
        [yY])
          overwrite=true
          action="overwritten"
          ;;
        *)
          log "skip (exists): ${dst_path}"
          skipped=$((skipped + 1))
          return
          ;;
      esac
    fi

    trash "${dst_path}"
  fi

  mkdir -p "$(dirname "${dst_path}")"
  ln -s "${src_path}" "${dst_path}"
  log "${action}: ${dst_path} -> ${src_path}"
  linked=$((linked + 1))
}

link_path() {
  local src="$1"
  local dst="$2"
  local src_is_dir=false
  local src_path dst_path item item_name item_dst

  src="${src/#\~/$HOME}"
  dst="${dst/#\~/$HOME}"
  [[ "${src}" =~ /$ ]] && src_is_dir=true
  src="${src%/}"
  dst="${dst%/}"

  if [[ "${src}" = /* ]]; then
    src_path="${src}"
  else
    src_path="${ENTITY_DIR}/${src}"
  fi

  if [[ "${dst}" = /* ]]; then
    dst_path="${dst}"
  else
    dst_path="${ENTITY_DIR}/${dst}"
  fi

  if [ ! -e "${src_path}" ]; then
    log "skip (source not found): ${src}"
    skipped=$((skipped + 1))
    return
  fi

  if [ -d "${src_path}" ] && ${src_is_dir}; then
    dst_path="${dst_path}/"
    mkdir -p "${dst_path}"
    while IFS= read -r -d '' item; do
      item_name="$(basename "${item}")"
      item_dst="${dst_path}${item_name}"
      create_link "${item}" "${item_dst}"
    done < <(find "${src_path}" -mindepth 1 -maxdepth 1 -print0)
    return
  fi

  if [[ "${dst_path}" =~ /$ ]]; then
    dst_path="${dst_path}$(basename "${src_path}")"
  fi

  create_link "${src_path}" "${dst_path}"
}

linked=0
skipped=0

while IFS=$'\t' read -r src dst; do
  [ -z "${src}" ] && continue
  link_path "${src}" "${dst}"
done < <(jq -r 'to_entries[] | .key as $src | .value[] | "\($src)\t\(.)"' "${MAP_FILE}")

log "done"
log "linked=${linked} skipped=${skipped}"
