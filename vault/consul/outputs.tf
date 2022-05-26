output "roles" {
  value = {
    consul_server   = vault_kubernetes_auth_backend_role.consul_server.role_name
    consul_client   = vault_kubernetes_auth_backend_role.consul_client.role_name
    consul_ca       = vault_kubernetes_auth_backend_role.consul_ca.role_name
    server_acl_init = vault_kubernetes_auth_backend_role.server_acl_init.role_name
  }
}

output "paths" {
  value = {
    kubernetes_auth_method = local.vault_kubernetes_auth_path
    consul_pki             = local.consul_pki_backend
    consul_static          = vault_mount.consul_static.path
    consul_connect_root    = var.vault_consul_connect_pki_root_backend
    consul_connect_int     = var.vault_consul_connect_pki_int_backend
  }
}

output "consul_datacenter" {
  value = var.consul_datacenter
}

output "vault_addr" {
  value = data.hcp_vault_cluster.cluster.vault_private_endpoint_url
}

output "vault_namespace" {
  value = data.hcp_vault_cluster.cluster.namespace
}