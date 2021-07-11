#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

main() {

	# temporary
	build_mesheryctl

	~/mesheryctl mesh validate "$@" -t ~/auth.json
}

build_mesheryctl() {
	git clone -b fix-mesh-validate https://github.com/DelusionalOptimist/meshery.git
	make -C meshery/mesheryctl/ make
	mv ./mehsery/mesheryctl ~/
}

main
