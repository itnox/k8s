#!/bin/bash
### Join Control Plane Node ###

#1. go to control plain node and run *kubeadm token create --print-join-command*
#2. run this command in all 3 nodes to join control plain node

kubeadm token create --print-join-command

kubeadm join 192.168.2.60:6443 --token sk3zg8.oby64wixpqrg76i7 --discovery-token-ca-cert-hash sha256:d895a1ed8b9f14fd756ff40732bcf888646c2b78ab3a8d18780f534d9015b8c9