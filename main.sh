#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

main() {
	args=()
	if [[ -n "${INPUT_PROVIDER_TOKEN:-}" ]]; then
		echo $INPUT_PROVIDER_TOKEN
		args+=(--provider-token ${INPUT_PROVIDER_TOKEN})
	fi

	"$SCRIPT_DIR/meshery.sh" "${args[@]}"
}

main
