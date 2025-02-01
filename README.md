# kino

My homeserver's media stack setup in Terraform.

## Setup
First you need to have a kubernetes cluster running, since this is still a single node setup you can easily install for example k3s:
```bash
curl -sfL https://get.k3s.io | sh - 
```

<!-- For k3s had to do this in order for traefik ingresses to work.
```bash
firewall-cmd --permanent --add-port=6443/tcp #apiserver
firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 #pods
firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 #services
firewall-cmd --reload
``` -->

Now you can deploy to the cluster.
```bash
terraform init
sudo terraform apply -auto-approve
```

## Variables

### namespace
This is the kubernetes name space to where 