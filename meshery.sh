#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

main() {

	echo "Checking if a k8s cluster exits..."
	kubectl config current-context
	if [ $? -eq 0]
	then
		echo "Cluster found"
	else
		printf "Cluster not found. \nCreating one...\n"
		create_k8s_cluster()
		echo "Cluster created successfully!"

	# get kubectl
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	pwd

	# TODO: config with the adapter specified by user
	mkdir ~/.meshery
	cp $SCRIPT_DIR/config.yaml ~/.meshery

	# get mesheryctl
  curl -L https://git.io/meshery | PLATFORM=kubernetes bash -

	export TOKEN="${{ secrets.AUTH_TOKEN }}"
	echo '{ "meshery-provider": "None", "token": null }' | jq '.token = ""' > ~/auth.json

	mesheryctl perf apply --profile test --url https://google.com -t ~/auth.json

}

create_k8s_cluster() {
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	sudo install minikube-linux-amd64 /usr/local/bin/minikube
	minikube start --driver=docker
}

main
