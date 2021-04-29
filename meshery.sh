#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

cp ./mesheryctl /usr/local/bin
git clone https://github.com/layer5io/meshery.git; cd meshery
kubectl create namespace meshery
helm install meshery --namespace meshery install/kubernetes/helm/meshery

mesheryctl
