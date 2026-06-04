#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

quarto render --profile english
quarto render --profile german
quarto preview "$@"
