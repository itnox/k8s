#!/bin/bash

wget https://docs.projectcalico.org/manifests/calico.yaml

IPV4_CIDR=10.10.0.0/16

sed -e "s/172\.16\.0\.0/$IPV4_CIDR/g" calico.yaml

sudo kubeadm init

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f calico.yaml