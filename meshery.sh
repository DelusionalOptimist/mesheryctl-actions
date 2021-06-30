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
  curl -L https://git.io/meshery | PLATFORM=docker bash -


	export KUBECONFIG=${HOME}/.kube/config
	kubectl cluster-info --context kind-kind

	# install meshery
	git clone https://github.com/layer5io/meshery.git; cd meshery
	kubectl create namespace meshery
	helm install meshery --namespace meshery install/kubernetes/helm/meshery
	cd ../

	mesheryctl version

}

main
