#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

main() {

	echo "Checking if a k8s cluster exits..."
	kubectl config current-context
	if [[ $? -eq 0 ]]
	then
		echo "Cluster found"
	else
		printf "Cluster not found. \nCreating one...\n"
		create_k8s_cluster
		echo "Cluster created successfully!"
	fi

  curl -L https://git.io/meshery | PLATFORM=kubernetes bash -

	kubectl config view --minify --flatten > ~/minified_config
	mv ~/minified_config ~/.kube/config

	echo '{ "meshery-provider": "None", "token": null }' | jq '.token = ""' > ~/auth.json

	sleep 120

	mesheryctl perf apply --profile test --url https://google.com -t ~/auth.json

}

create_k8s_cluster() {
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	sudo install minikube-linux-amd64 /usr/local/bin/minikube
	minikube start --driver=docker
	sleep 60
}

#create_k8s_cluster() {
#	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
#	chmod +x ./kind
#	mv ./kind usr/local/bin/kind && export KUBECONFIG=${HOME}/.kube/config
#	kind create cluster --name kind --wait 300s
#}

main
