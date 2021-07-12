#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

main() {
	local service_mesh_adapter=
	local spec=
	local service_mesh=

	# temporary
	build_mesheryctl

	parse_command_line "$@"
	docker network connect bridge meshery_meshery_1
	docker network connect minikube meshery_meshery_1
	docker network connect minikube meshery_meshery-"$service_mesh"_1
	docker network connect bridge meshery_meshery-"$service_mesh"_1

	~/mesheryctl system config minikube -t ~/auth.json
	echo $spec $service_mesh_adapter
	~/mesheryctl mesh validate --spec $spec --adapter $service_mesh_adapter -t ~/auth.json
}

build_mesheryctl() {
	git clone -b fix-mesh-validate https://github.com/DelusionalOptimist/meshery.git ~/meshery
	make -C ~/meshery/mesheryctl/ make
	mv ~/meshery/mesheryctl/mesheryctl ~/mesheryctl
	chmod +x ~/mesheryctl
}

parse_command_line() {
	while :
	do
		case "${1:-}" in
			--service-mesh)
				if [[ -n "${2:-}" ]]; then
					# figure out assigning port numbers and adapter names
					service_mesh=$2
					service_mesh_adapter="meshery-$2:10009"
					shift
				else
					echo "ERROR: '--service-mesh' cannot be empty." >&2
					exit 1
				fi
				;;
			-s|--spec)
				if [[ -n "${2:-}" ]]; then
					spec=$2
					shift
				else
					echo "ERROR: '--spec' cannot be empty." >&2
					exit 1
				fi
				;;
			*)
				break
				;;
		esac
		shift
	done
}

main "$@"
