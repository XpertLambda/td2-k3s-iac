#!/bin/bash
# Step 15 (bonus), part E. CLOSE any browser tab on NovaShop first: the page calls
# /api/visits every 5 seconds and would add rows, so the count would not be 5.
FIP=${FIP:-$(cd "$HOME/td2/terraform" && terraform output -raw floating_ip)}

for i in $(seq 1 5); do
  curl -s "http://$FIP/api/visits"
  echo ""
done

kubectl -n td2 exec postgres-0 -- psql -U app -d appdb -c \
  "SELECT COUNT(*), COUNT(DISTINCT pod_name) FROM visits;"      # [S33]
