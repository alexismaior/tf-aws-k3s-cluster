echo '${private_key}' | tr -d '\r' | ssh-add - &&
#chmod 0600 ~/.ssh/id_rsa &&
ssh -o StrictHostKeyChecking=no \
 -o UserKnownHostsFile=/dev/null \
   ubuntu@${nodeip} "while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do sleep 1; done; sudo cat /etc/rancher/k3s/k3s.yaml" > ${k3s_path}/files/k3s-${nodename}.yaml &&
 sed -i 's/127.0.0.1/${nodeip}/' ${k3s_path}/files/k3s-${nodename}.yaml
