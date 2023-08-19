data "terraform_remote_state" "global" {
  backend = "remote"

  config = {
    organization = "company"
    workspaces = {
      name = "global"
    }
  }
}
