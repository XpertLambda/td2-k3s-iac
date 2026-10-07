output "vm_name" { value = openstack_compute_instance_v2.k3s.name }
output "floating_ip" { value = openstack_networking_floatingip_v2.k3s_fip.address }
output "private_ip" { value = openstack_compute_instance_v2.k3s.access_ip_v4 }
output "ssh_command" { value = "ssh ubuntu@${openstack_networking_floatingip_v2.k3s_fip.address}" }
