#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

main() {

	# get kubectl
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	pwd

	# TODO: config with the adapter specified by user
	mkdir ~/.meshery
	cp $SCRIPT_DIR/config.yaml ~/.meshery

	# get mesheryctl
  curl -L https://git.io/meshery | PLATFORM=kubernetes bash -

	mesheryctl version

}

main
