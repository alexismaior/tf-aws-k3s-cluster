#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo hostnamectl set-hostname ${nodename} &&
curl -sfL https://get.k3s.io | sh -s - server \
  --datastore-endpoint="mysql://${dbuser}:${dbpassword}@tcp(${dbendpoint})/${dbname}" \
  --write-kubeconfig-mode 644 \
  --tls-san=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) \
  --no-deploy traefik
