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

	sleep 30
}

create_k8s_cluster() {
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	sudo install minikube-linux-amd64 /usr/local/bin/minikube
	sudo apt update -y
	sudo apt install conntrack
	minikube version
	minikube start --driver=none --kubernetes-version=v1.20.7
	sleep 40
}

main
