#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

main() {

	# temporary
	build_mesheryctl

	~/mesheryctl mesh validate "$@" -t ~/auth.json
}

build_mesheryctl() {
	git clone https://github.com/DelusionalOptimist/meshery.git
	git checkout fix-mesh-validate
	make -C meshery/mesheryctl/ make
	mv ./mehsery/mesheryctl ~/
}

main
