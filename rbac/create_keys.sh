#!/bin/bash

USERNAME="cloud_user"
KUBE_CONFIG="$USERNAME.kubeconfig"
CLIENT_CERT="${USERNAME}.crt"
CLIENT_KEY="${USERNAME}.key"
NAMESPACE="clouduser"

kubectl create namespace $NAMESPACE
openssl genrsa -out $USERNAME.key 2048

openssl req -new -key $USERNAME.key \
  -out $USERNAME.csr \
  -subj "/CN=${USERNAME}/O=cloud_users"

openssl x509 -req \
  -in $USERNAME.csr \
  -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -out $USERNAME.crt \
  -days 365

kubectl apply -f cloud_user-role.yaml
kubectl apply -f cloud_user-rolebinding.yaml

kubectl config set-cluster my-cluster \
  --server=https://<API_SERVER>:6443 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --kubeconfig=$KUBE_CONFIG


kubectl config set-credentials cloud_user \
  --client-certificate=$CLIENT_CERT \
  --client-key=$CLIENT_KEY \
  --embed-certs=true \
  --kubeconfig=$KUBE_CONFIG

kubectl config set-context cloud_user-context \
  --cluster=my-cluster \
  --namespace=$NAMESPACE \
  --user=$USER \
  --kubeconfig=$KUBE_CONFIG

kubectl config use-context cloud_user-context \
  --kubeconfig=$KUBE_CONFIG

mkdir -p /home/$USERNAME/.kube
cp $KUBE_CONFIG /home/$USERNAME/.kube/config
chown -R $USERNAME:$USERNAME /home/$USERNAME/.kube
