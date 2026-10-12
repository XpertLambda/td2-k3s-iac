#!/bin/bash
# Step 15 (bonus), parts A to D: migration, new backend and frontend code, deploy.
# Run in terminal B after: source ~/td2/env.sh   (commit to Git first: git add -A && git commit -m "before bonus")
set -e
BASE="$HOME/td2"

echo "### A. Migration (init.sql does NOT replay on helm upgrade)"
kubectl -n td2 exec -i postgres-0 -- psql -U app -d appdb < "$BASE/bonus/migration.sql"
kubectl -n td2 exec postgres-0 -- psql -U app -d appdb -c "\d visits"   # [S31]

echo; echo "### B and C. Install the new backend code and the new frontend page"
cp "$BASE/bonus/backend-configmap-code.yaml"  "$BASE/helm/backend/templates/configmap-code.yaml"
cp "$BASE/bonus/frontend-configmap-html.yaml" "$BASE/helm/frontend/templates/configmap-html.yaml"
helm lint "$BASE/helm/backend" "$BASE/helm/frontend"

echo; echo "### D. Deploy"   # [S32]
helm upgrade backend  "$BASE/helm/backend"  -n td2 --wait --timeout 3m
helm upgrade frontend "$BASE/helm/frontend" -n td2 --wait --timeout 3m
kubectl -n td2 rollout status deployment/backend
kubectl -n td2 rollout status deployment/frontend
kubectl -n td2 get pods
