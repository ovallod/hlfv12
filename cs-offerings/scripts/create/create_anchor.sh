#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

# Default to "channel1" if not defined
if [ -z "${CHANNEL_NAME}" ]; then
	echo "CHANNEL_NAME not defined. I will use \"channel1\"."
	echo "I will wait 5 seconds before continuing."
	sleep 5
fi
CHANNEL_NAME=${CHANNEL_NAME:-channel1}

echo "Deleting old channel pods if exists"
echo "Running: ${KUBECONFIG_FOLDER}/../scripts/delete/delete_anchor-pods.sh"
${KUBECONFIG_FOLDER}/../scripts/delete/delete_anchor-pods.sh


echo "Preparing yaml file for create channel"
sed -e "s/%CHANNEL_NAME%/${CHANNEL_NAME}/g"  ${KUBECONFIG_FOLDER}/create_anchor.yaml.base > ${KUBECONFIG_FOLDER}/create_anchor.yaml

echo "Creating createchannel pod"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/create_anchor.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/create_anchor.yaml

while [ "$(kubectl get pod -a createanchor | grep createanchor | awk '{print $3}')" != "Completed" ]; do
    echo "Waiting for createanchors container to be Completed"
    sleep 1;
done



