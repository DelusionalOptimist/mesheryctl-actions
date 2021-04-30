#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

main() {

	clone_meshery
	build_mesheryctl
	install_meshery

}

# clone Meshery with the latest release tag
clone_meshery() {
	echo 'Cloning Meshery...'

	MESHERY_VERSION=$(curl -L -s https://api.github.com/repos/layer5io/meshery/releases | \
                  grep tag_name | sed "s/ *\"tag_name\": *\"\\(.*\\)\",*/\\1/" | \
                  grep -v "rc\.[0-9]$"| head -n 1 )

	git clone --depth=1 --branch $MESHERY_VERSION https://github.com/layer5io/meshery
}

# TODO: This step shouldn't be required once
# https://github.com/layer5io/meshery/pull/2770 gets merged
build_mesheryctl() {
	echo 'Building Mesheryctl...'

	make -C ./meshery/mesheryctl make
	cp meshery/mesheryctl/mesheryctl /usr/local/bin
}

install_meshery() {
	echo 'Installing Meshery on namespace meshery...'

	kubectl create namespace meshery
	helm install meshery --namespace meshery meshery/install/kubernetes/helm/meshery
}

main
