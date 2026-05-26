set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

link:
    ./scripts/link.sh
