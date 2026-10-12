#!/bin/bash
# Step 13: end-to-end validation. Run in terminal B after: source ~/td2/env.sh
set -u
FIP=${FIP:-$(cd "$HOME/td2/terraform" && terraform output -raw floating_ip)}
echo "URL : http://$FIP"

echo; echo "### 1) Helm releases  [S19]"
helm list -n td2

echo; echo "### 2) Kubernetes objects  [S20]"
kubectl -n td2 get pods,svc,statefulset,ingress,pvc

echo; echo "### 3) Endpoints  [S21]"
kubectl -n td2 get endpoints

echo; echo "### 4) Simple HTTP test  [S22]"
curl -I "http://$FIP" | head -3

echo; echo "### 5) Frontend load-balancing via X-Pod-Name  [S23]"
for i in $(seq 1 6); do
  curl -sI "http://$FIP" | grep -i '^X-Pod-Name'
done

echo; echo "### 6) Full chain /api/items  [S24]"
curl -s "http://$FIP/api/items" | python3 -m json.tool
