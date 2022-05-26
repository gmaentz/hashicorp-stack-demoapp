resource "vault_mount" "consul_connect_pki" {
  path                      = "consul_connect/pki"
  type                      = "pki"
  description               = "PKI engine hosting intermediate Connect CA1 v1 for Consul"
  default_lease_ttl_seconds = local.seconds_in_1_year
  max_lease_ttl_seconds     = local.seconds_in_3_years
}

resource "vault_pki_secret_backend_intermediate_cert_request" "consul_connect_pki" {
  depends_on   = [vault_mount.consul_connect_pki]
  backend      = vault_mount.consul_connect_pki.path
  type         = "internal"
  common_name  = "Consul Connect CA1 v1"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = "HashiConf Europe"
  organization = "HashiCorp"
  country      = "US"
  locality     = "San Francisco"
  province     = "California"
}

resource "local_file" "connect_csr" {
  filename = "../connect/intermediate/ca.csr"
  content  = vault_pki_secret_backend_intermediate_cert_request.consul_connect_pki.csr
}

resource "vault_pki_secret_backend_intermediate_set_signed" "consul_connect_pki" {
  count   = var.signed_cert ? 1 : 0
  backend = vault_mount.consul_connect_pki.path

  certificate = var.signed_cert ? format("%s\n%s", file("../connect/intermediate/ca.crt"), file("../connect/root/ca.crt")) : null
}

resource "vault_mount" "consul_connect_pki_int" {
  path                      = "consul_connect/pki_int"
  type                      = "pki"
  description               = "PKI engine hosting intermediate Connect CA2 v1 for Consul"
  default_lease_ttl_seconds = local.seconds_in_1_hour
  max_lease_ttl_seconds     = local.seconds_in_1_year
}

resource "vault_pki_secret_backend_intermediate_cert_request" "consul_connect_pki_int" {
  depends_on   = [vault_mount.consul_connect_pki_int]
  backend      = vault_mount.consul_connect_pki_int.path
  type         = "internal"
  common_name  = "Consul Connect CA2 v1"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = "HashiConf Europe"
  organization = "HashiCorp"
  country      = "US"
  locality     = "San Francisco"
  province     = "California"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "consul_connect_pki_int" {
  count = var.signed_cert ? 1 : 0
  depends_on = [
    vault_mount.consul_connect_pki,
    vault_pki_secret_backend_intermediate_cert_request.consul_connect_pki_int,
  ]
  backend              = vault_mount.consul_connect_pki.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.consul_connect_pki_int.csr
  common_name          = "Consul Connect CA2 v1.1"
  exclude_cn_from_sans = true
  ou                   = "HashiConf Europe"
  organization         = "HashiCorp"
  country              = "US"
  locality             = "San Francisco"
  province             = "California"
  max_path_length      = 1
  ttl                  = local.seconds_in_1_year
}

resource "vault_pki_secret_backend_intermediate_set_signed" "consul_connect_pki_int" {
  count       = var.signed_cert ? 1 : 0
  depends_on  = [vault_pki_secret_backend_root_sign_intermediate.consul_connect_pki_int]
  backend     = vault_mount.consul_connect_pki_int.path
  certificate = var.signed_cert ? format("%s\n%s\n%s", vault_pki_secret_backend_root_sign_intermediate.consul_connect_pki_int.0.certificate, file("../connect/intermediate/ca.crt"), file("../connect/root/ca.crt")) : null
}