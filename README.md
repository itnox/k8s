# kubernetes Installaion #

### Pre Requisites ###

1. 4 VMs Ubuntu 20.04, 1 Control plane node and 3 worker nodes
2. Static IPs on individual VMs
3. /etc/hosts hosts file includes name to IP mappings for VMs
4. Swap is disabled
5. Take snapshots prior to installation, this way you can install and revert to snapshot if needed 

### SWAP Disable ###

we need to disable swap because kubernetes require to disable SWAP.
1. we are off SWAP by command 
2. Edit your SWAP in /etc/fstab so, it will be off on reboot.

sudo swapoff -a
sudo sed 's/\(^\/swap\)/#\/swap/g' -i /etc/fstab

### Set Modprobe ###

1. Run modprobe command to set pverlay and br_netfilter values
2. Add /etc/modules-load.d/k8s.conf file for permanent changes 

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

### Set sysctl Params ###

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

### Apply sysctl ###

sudo sysctl --system

### Install Containerd ###

sudo apt-get update
sudo apt-get install -y containerd

### Create container configuration ###

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

### change SystemdCgroup = false to SystemdCgroup = true ###

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

### Restart & check status of containerd 

sudo systemctl restart containerd
sudo systemctl status containerd

## Install kubernetes packages ##

1. kubeadm
2. kubeclet
3. kubectl

### Add Google's apt repository gpg key ###

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

### Add Kubernetes apt repository ###

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

### update package list ###

sudo apt-get update
apt-cache policy kubelet | head -n 20 

### Install the required packages ###

1. First we are set the version
2. Install the required packages with same version  
3. Mark these packages as hold to beaing update

VERSION=1.24.4-00
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
sudo apt-mark hold kubelet kubeadm kubectl containerd

### systemd Units ###
1. Check the status of our kubelet and our container runtime, containerd.
2. enable kubelet and containerd for run on boot

sudo systemctl status kubelet.service 
sudo systemctl status containerd.service 

sudo systemctl enable kubelet.service
sudo systemctl enable containerd.service