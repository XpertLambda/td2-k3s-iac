# TD2 - NovaShop: K3s industrialised with Terraform, Ansible and Helm

Course: IaC / DevSecOps (INSA CVL, STI 5A FISE). Author: Ahmad Saad.

A 3-tier application (nginx frontend, Python API, PostgreSQL) deployed on a single-node
K3s cluster running in an OpenStack (DevStack) VM, from an empty project to a working
site with three tools, each with its own responsibility:

| Layer | Tool | Folder | Role |
| --- | --- | --- | --- |
| Provision | Terraform | `terraform/` | security group, VM, floating IP (7 resources); reads shared resources through data sources |
| Configure | Ansible | `ansible/` | DNS fix and packages, K3s install, kubeconfig copy |
| Deploy | Helm | `helm/` | three charts: `postgres` (StatefulSet + PVC), `backend` (2 pods), `frontend` (2 pods + Ingress) |

```
 DevStack host (stack@devstack)                 VM k3s-<login>  (OpenStack)
 +------------------------------+   SSH 22     +----------------------------------+
 | Terraform --> inventory.ini  |------------->| K3s (Traefik Ingress, port 80)   |
 | Ansible  --> kubeconfig      |              |  namespace td2:                  |
 | Helm / kubectl --------------|--SSH tunnel->|   frontend x2 -> backend x2 -> postgres-0 (PVC)
 +------------------------------+   6443       +----------------------------------+
```

## Design choices

- **Data sources for shared infrastructure** (image, flavor, `asl-net`, `asl-subnet`, public network,
  key pair): Terraform reads them but never creates or destroys them, so `terraform destroy`
  cannot break the shared base.
- **No port 6443 in the security group** (only 22, 80, 443). `kubectl` and `helm` go through an
  SSH tunnel (`ansible/tunnel.sh`), so the K3s API is never exposed.
- **Idempotence**: `terraform plan` shows no changes, `ansible-playbook` reports `changed=0`,
  `helm upgrade` leaves pods untouched.
- **kubeconfig kept at `127.0.0.1`** (as K3s writes it): it is exactly what the tunnel needs, and
  it keeps the `kubeconfig` role idempotent (rewriting the address to the floating IP and back
  made the second playbook run report `changed=1`).
- **Checksum annotations** on the pod templates, so that a ConfigMap change (application code,
  HTML, nginx config) triggers a rollout; without them a changed ConfigMap does not restart pods.
- **Plain-text Postgres password** in `values.yaml`: accepted in this isolated lab, to be replaced
  by a secret manager (Ansible Vault, Sealed Secrets) in TD3.
- `PGDATA` is set so PostgreSQL starts on `local-path` volumes.

## Usage

Prerequisites: OpenStack credentials (`source ~/devstack/asl-openrc`), Terraform >= 1.6,
Ansible, Helm 3, kubectl, `sshpass`.

```bash
cp terraform/example.tfvars terraform/terraform.tfvars   # set your login (not "user")
cd terraform && terraform init && terraform apply         # VM, security group, floating IP
terraform output -raw ansible_inventory > ../ansible/inventory.ini
cd ../ansible && ansible-playbook playbook.yml            # prerequisites, K3s, kubeconfig
./tunnel.sh                                               # terminal A, keep open
export KUBECONFIG=$PWD/kubeconfig                         # terminal B
kubectl create namespace td2
cd ../helm && for c in postgres backend frontend; do helm install $c ./$c -n td2 --wait; done
curl -s http://$(cd ../terraform && terraform output -raw floating_ip)/api/items
```

Helper scripts are in `scripts/` (validation, idempotence proof, destruction) and the optional
visit-counter exercise is in `bonus/`.

Never commit `terraform.tfstate`, `terraform.tfvars` or `kubeconfig` (see `.gitignore`).

## Bonus: visit counter
- `bonus/migration.sql` creates the `visits` table (applied with `psql`, because `init.sql` only runs on a fresh volume).
- The backend exposes `/api/visits` (one row per call) and the frontend shows a "Visites totales" card.
- `helm upgrade` deployed it (revision 3 of the backend); `helm rollback` restored the previous version (revision 4), and `/api/visits` returned 404 again.
