set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

link:
    ./scripts/link.sh

ai-build:
    bash scripts/ai-build.sh

ai-rebuild:
    bash scripts/ai-build.sh -r

ai-link:
    bash scripts/ai-link.sh
