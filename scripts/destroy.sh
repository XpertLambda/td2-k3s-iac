#!/bin/bash
# Step 16: clean destruction. IRREVERSIBLE. Take all screenshots first.
# Run in terminal B after: source ~/td2/env.sh   (tunnel still open in terminal A)
BASE="$HOME/td2"

read -r -p "All screenshots saved? Type DESTROY to continue: " answer
[ "$answer" = "DESTROY" ] || { echo "Aborted."; exit 1; }

echo "### 16.1 Helm uninstall  [S41]"
helm uninstall frontend -n td2
helm uninstall backend -n td2
helm uninstall postgres -n td2
kubectl -n td2 delete pvc --all
kubectl delete namespace td2

echo; echo "### 16.2 terraform destroy  [S39]  (answer yes)"
(cd "$BASE/terraform" && terraform destroy)

echo; echo "### What remains in OpenStack (shared resources)  [S40]"
openstack network list
openstack subnet list
openstack router list
openstack keypair list
openstack image list

echo; echo "### 16.3 Local cleanup"
pkill -f "ssh.*6443:127.0.0.1:6443" || true
rm -f "$BASE/ansible/kubeconfig" "$BASE/ansible/inventory.ini"
echo "Done. Also close terminal A (tunnel) and run: unset KUBECONFIG"
