resource "boundary_user" "operations" {
  for_each    = var.operations_team
  name        = each.key
  description = "Operations user: ${each.key}"
  account_ids = [boundary_account_password.operations_user_acct[each.value].id]
  scope_id    = boundary_scope.org.id
}

resource "boundary_user" "leadership" {
  for_each    = var.leadership_team
  name        = each.key
  description = "WARNING: Managers should be read-only"
  account_ids = [boundary_account_password.leadership_user_acct[each.value].id]
  scope_id    = boundary_scope.org.id
}

resource "random_password" "operations_team" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "boundary_account_password" "operations_user_acct" {
  for_each       = var.operations_team
  name           = each.key
  description    = "User account for ${each.key}"
  login_name     = lower(each.key)
  password       = random_password.operations_team.result
  auth_method_id = boundary_auth_method.password.id
}

resource "random_password" "leadership_team" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "boundary_account_password" "leadership_user_acct" {
  for_each       = var.leadership_team
  name           = each.key
  description    = "User account for ${each.key}"
  login_name     = lower(each.key)
  password       = random_password.leadership_team.result
  auth_method_id = boundary_auth_method.password.id
}

// organiation level group for the leadership team
resource "boundary_group" "leadership" {
  name        = "leadership_team"
  description = "Organization group for leadership team"
  member_ids  = [for user in boundary_user.leadership : user.id]
  scope_id    = boundary_scope.org.id
}

// project level group for operations management of core infra
resource "boundary_group" "operations_team" {
  name        = "operations"
  description = "Operations team group"
  member_ids  = [for user in boundary_user.operations : user.id]
  scope_id    = boundary_scope.core_infra.id
}

