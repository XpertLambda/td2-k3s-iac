#!/bin/bash
# Step 15 (bonus), part F. Take the browser screenshot [S34] BEFORE running this:
# after the rollback the page shows "Hors ligne" (frontend still calls /api/visits).
FIP=${FIP:-$(cd "$HOME/td2/terraform" && terraform output -raw floating_ip)}

echo "### History before the rollback: expect 3 revisions  [S35]"
helm history backend -n td2

read -r -p "Screenshot S35 taken? Press Enter to roll back: " _
helm rollback backend -n td2
kubectl -n td2 rollout status deployment/backend          # [S36]

echo "### /api/visits must be 404 again"
curl -sI "http://$FIP/api/visits" | head -1

echo; echo "### History after the rollback: the rollback is revision 4"
helm history backend -n td2
