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

	# get yq
	wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O $SCRIPT_DIR/yq
	sudo chmod +x $SCRIPT_DIR/yq

	# get helm
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
	chmod 700 get_helm.sh
	./get_helm.sh

	# get meshery helm charts
	curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
	git clone https://github.com/layer5io/meshery.git; cd meshery
	kubectl create namespace meshery
	./$SCRIPT_DIR/yq e '.service.type = "NodePort"' -i install/kubernetes/helm/meshery/values.yaml

	# install meshery using helm
	helm install meshery --namespace meshery install/kubernetes/helm/meshery
	kubectl expose deployment meshery --port=9081 --type=NodePort

	# get mesheryctl
  curl -L https://git.io/meshery | PLATFORM=kubernetes bash -

	echo '{ "meshery-provider": "None", "token": null }' | jq '.token = ""' > ~/auth.json

	sleep 15

	mesheryctl perf apply --profile test --url https://google.com -t ~/auth.json

}

#create_k8s_cluster() {
#	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
#	sudo install minikube-linux-amd64 /usr/local/bin/minikube
#	minikube start --driver=docker
#}

create_k8s_cluster() {
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
	chmod +x ./kind
	mv ./kind usr/local/bin/kind && export KUBECONFIG=${HOME}/.kube/config
	kind create cluster --name kind --wait 300s
}

main
