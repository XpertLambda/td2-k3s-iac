#!/bin/bash
# Step 14.1: idempotence proof. Run in terminal B after: source ~/td2/env.sh
# Terminal A must still be running the tunnel (ansible/tunnel.sh).
BASE="$HOME/td2"

echo "### Terraform: expect 'No changes'  [S27]"
(cd "$BASE/terraform" && terraform plan)

echo; echo "### Ansible: expect changed=0 on every host  [S28]"
(cd "$BASE/ansible" && ansible-playbook playbook.yml)

echo; echo "### Helm upgrades, pod names must not change  [S29]"
kubectl -n td2 get pods
cd "$BASE/helm" || exit 1
helm upgrade postgres ./postgres -n td2
helm upgrade backend ./backend -n td2
helm upgrade frontend ./frontend -n td2
kubectl -n td2 get pods
