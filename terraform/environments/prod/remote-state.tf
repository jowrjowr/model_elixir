terraform {
  backend "remote" {
    organization = "company"

    workspaces {
      name = "model_elixir_prod"
    }
  }
}

data "terraform_remote_state" "global" {
  backend = "remote"

  config = {
    organization = "company"
    workspaces = {
      name = "global"
    }
  }
}
