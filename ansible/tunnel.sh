#!/bin/bash
# SSH tunnel: localhost:6443 -> VM 127.0.0.1:6443 (K3s API). Keep this terminal open.
# The security group does not open 6443 on purpose.
HERE="$(cd "$(dirname "$0")" && pwd)"
FIP=$(cd "$HERE/../terraform" && terraform output -raw floating_ip)
pkill -f "ssh.*6443:127.0.0.1:6443" 2>/dev/null || true
sleep 1
echo "Tunnel localhost:6443 -> ${FIP}:6443 (Ctrl+C to close)"
sshpass -p azerty ssh -N \
  -o StrictHostKeyChecking=no \
  -o ExitOnForwardFailure=yes \
  -L 6443:127.0.0.1:6443 \
  ubuntu@"$FIP"
