resource "tfe_workspace" "boundary_config" {
  name                          = "boundary-config"
  organization                  = tfe_organization.demo.name
  project_id                    = tfe_project.platform.id
  description                   = "Register workers into Boundary"
  terraform_version             = var.terraform_version
  working_directory             = "boundary/config"
  trigger_prefixes              = ["boundary/config"]
  queue_all_runs                = false
  remote_state_consumer_ids     = []
  speculative_enabled           = false
  structured_run_output_enabled = false

  vcs_repo {
    identifier     = var.github_repository
    branch         = var.github_branch
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_workspace_variable_set" "boundary_config_common" {
  workspace_id    = tfe_workspace.boundary_config.id
  variable_set_id = tfe_variable_set.common.id
}