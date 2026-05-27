#!/usr/bin/env bash

set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
AI_DIR="${DOTFILES_ROOT}/ai"
JA_DIR="${AI_DIR}/ja"
ENTITY_DIR="${AI_DIR}/entity"
STATE_DIR="${AI_DIR}/state"
HASH_FILE="${STATE_DIR}/hashes"
FORCE_REBUILD=false

while getopts 'r' opt; do
  case "${opt}" in
    r) FORCE_REBUILD=true ;;
    *) exit 1 ;;
  esac
done
shift $((OPTIND - 1))

log() {
  echo "[ai build] $*"
}

if [ ! -d "${JA_DIR}" ]; then
  log "ja_dir not found: ${JA_DIR}"
  exit 1
fi

# shellcheck source=../modules/translate.sh
source "${DOTFILES_ROOT}/modules/translate.sh"

mkdir -p "${ENTITY_DIR}"
mkdir -p "${STATE_DIR}"

tmp_hash_file="$(mktemp)"
translated_count=0
removed_count=0
scanned_count=0
skipped_count=0
sources=()

cleanup() {
  rm -f "${tmp_hash_file}"
}
trap cleanup EXIT

log "start"
log "ja_dir=${JA_DIR}"
log "entity_dir=${ENTITY_DIR}"
log "hash_file=${HASH_FILE}"

while IFS= read -r -d '' src; do
  sources+=("${src}")
done < <(find "${JA_DIR}" -type f -print0)
log "source_files=${#sources[@]}"

if [ -f "${HASH_FILE}" ]; then
  log "checking deleted files from previous hash snapshot"
  while IFS=$'\t' read -r old_rel _old_hash; do
    [ -z "${old_rel}" ] && continue
    if [ ! -f "${JA_DIR}/${old_rel}" ]; then
      target="${ENTITY_DIR}/${old_rel}"
      if [ -f "${target}" ]; then
        rm -f "${target}"
        parent_dir="$(dirname "${target}")"
        while [ "${parent_dir}" != "${ENTITY_DIR}" ] && [ -d "${parent_dir}" ]; do
          rmdir "${parent_dir}" 2>/dev/null || break
          parent_dir="$(dirname "${parent_dir}")"
        done
        removed_count=$((removed_count + 1))
        log "removed: ${old_rel}"
      fi
    fi
  done < "${HASH_FILE}"
fi

log "scanning source files"
for src in "${sources[@]}"; do
  rel="${src#${JA_DIR}/}"
  scanned_count=$((scanned_count + 1))
  read -r current_hash _ < <(shasum -a 256 "${src}")
  old_hash=""

  if [ -f "${HASH_FILE}" ]; then
    old_hash="$(awk -F '\t' -v p="${rel}" '$1 == p {print $2; exit}' "${HASH_FILE}")"
  fi

  if [ "${current_hash}" != "${old_hash}" ] || [ "${FORCE_REBUILD}" = true ]; then
    dst="${ENTITY_DIR}/${rel}"
    log "translating: ${rel}"
    mkdir -p "$(dirname "${dst}")"
    translate_cmd "${src}" | sed '/^```/d' > "${dst}"
    translated_count=$((translated_count + 1))
    log "translated: ${rel}"
  else
    skipped_count=$((skipped_count + 1))
    log "skip (unchanged): ${rel}"
  fi

  printf '%s\t%s\n' "${rel}" "${current_hash}" >> "${tmp_hash_file}"
done

mv "${tmp_hash_file}" "${HASH_FILE}"
trap - EXIT

log "done"
log "scanned=${scanned_count} translated=${translated_count} skipped=${skipped_count} removed=${removed_count}"
