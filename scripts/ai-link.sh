#!/usr/bin/env bash

set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
AI_DIR="${DOTFILES_ROOT}/ai"
ENTITY_DIR="${AI_DIR}/entity"
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

linked=0
skipped=0

while IFS=$'\t' read -r src dst; do
  [ -z "${src}" ] && continue
  src="${src/#\~/$HOME}"
  dst="${dst/#\~/$HOME}"
  src_is_dir=false
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
    continue
  fi

  if [ -d "${src_path}" ] && ${src_is_dir}; then
    dst_path="${dst_path}/"
    mkdir -p "${dst_path}"
    while IFS= read -r -d '' item; do
      item_name="$(basename "${item}")"
      item_dst="${dst_path}${item_name}"

      if [ -L "${item_dst}" ]; then
        rm -f "${item_dst}"
      elif [ -e "${item_dst}" ]; then
        log "skip (exists and not symlink): ${item_dst}"
        skipped=$((skipped + 1))
        continue
      fi

      item_dst_dir="$(dirname "${item_dst}")"
      rel_item="$(perl -e 'use File::Spec; print File::Spec->abs2rel(@ARGV[0], @ARGV[1])' "${item}" "${item_dst_dir}")"
      ln -s "${rel_item}" "${item_dst}"
      log "linked: ${item_dst} -> ${item}"
      linked=$((linked + 1))
    done < <(find "${src_path}" -mindepth 1 -maxdepth 1 -print0)
    continue
  fi

  if [[ "${dst_path}" =~ /$ ]]; then
    dst_path="${dst_path}$(basename "${src_path}")"
  fi

  mkdir -p "$(dirname "${dst_path}")"

  if [ -L "${dst_path}" ]; then
    rm -f "${dst_path}"
  elif [ -e "${dst_path}" ]; then
    log "skip (exists and not symlink): ${dst}"
    skipped=$((skipped + 1))
    continue
  fi

  dst_dir="$(dirname "${dst_path}")"
  rel_src="$(perl -e 'use File::Spec; print File::Spec->abs2rel(@ARGV[0], @ARGV[1])' "${src_path}" "${dst_dir}")"
  ln -s "${rel_src}" "${dst_path}"
  log "linked: ${dst_path} -> ${src_path}"
  linked=$((linked + 1))
done < <(jq -r 'to_entries[] | "\(.key)\t\(.value)"' "${MAP_FILE}")

log "done"
log "linked=${linked} skipped=${skipped}"
