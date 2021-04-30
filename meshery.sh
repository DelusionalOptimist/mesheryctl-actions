#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

main() {

	clone_meshery
	install_mesheryctl
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
install_mesheryctl() {
	echo 'Building mesheryctl...'

	make -C ./meshery/mesheryctl make

	echo "Installing mesheryctl in /usr/local/bin..."

	WHOAMI=$(whoami)
	if mv ${PWD}/meshery/mesheryctl/mesheryctl /usr/local/bin/mesheryctl ; then
	  echo "mesheryctl installed."
	else
	  if sudo mv ${PWD}/meshery/mesheryctl/mesheryctl /usr/local/bin/mesheryctl ; then
	    echo "Permission Resolved: mesheryctl installed using sudo permissions."
	  else
	    echo "Cannot install mesheryctl. Check permissions of $WHOAMI for /usr/local/bin."
	    exit 1
	  fi
	fi

}

install_meshery() {
	echo 'Installing Meshery on namespace meshery...'

	kubectl create namespace meshery
	helm install meshery --namespace meshery meshery/install/kubernetes/helm/meshery
}

main
