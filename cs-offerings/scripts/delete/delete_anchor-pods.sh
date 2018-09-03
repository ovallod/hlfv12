#!/bin/bash

if [ "${PWD##*/}" == "delete" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/delete' folder"
fi

# The env variables don't matter as we are deleting pods
PEER_ADDRESS="DoesntMatter"
CHANNEL_NAME="DoesntMatter"
PEER_MSPID="DoesntMatter"
# Delete Create Channel Pod

echo "Preparing yaml for createchannel pod for deletion"
sed -e "s/%CHANNEL_NAME%/${CHANNEL_NAME}/g"  ${KUBECONFIG_FOLDER}/create_anchor.yaml.base > ${KUBECONFIG_FOLDER}/create_anchor.yaml

echo "Deleting Existing Create Channel Pod"
if [ "$(kubectl get pods -a | grep createanchor | wc -l | awk '{print $1}')" != "0" ]; then
	echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/create_anchor.yaml"
    kubectl delete -f ${KUBECONFIG_FOLDER}/create_anchor.yaml

    # Wait for the pod to be deleted
    while [ "$(kubectl get pods -a | grep createanchor | wc -l | awk '{print $1}')" != "0" ]; do
        echo "Waiting for old Create Channel Pod to be deleted"
        sleep 1;
    done

    echo "Create anchor pod deleted successfully."
else
    echo "createanchor pod doesn't exist. No need to delete."
fi


