#!/bin/sh
set -e

sleep 10

kubeadm init --config /tmp/master-configuration.yml \
  --ignore-preflight-errors=Swap

kubeadm token create ${token}

[ -d $HOME/.kube ] || mkdir -p $HOME/.kube
ln -s /etc/kubernetes/admin.conf $HOME/.kube/config

until $(curl --output /dev/null --silent --head --fail http://localhost:6443); do
  echo "Waiting for API server to respond"
  sleep 5
done

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# See: https://kubernetes.io/docs/admin/authorization/rbac/
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts
