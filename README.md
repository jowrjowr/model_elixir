# Model Elixir Project

## Installing developer tools required

* Install nix-shell on your local system (<https://nixos.org/download.html>)
* Add the appropriate nix channel. Current is 23.05 `nix-channel --add https://nixos.org/channels/nixos-23.05 nixos-23.05`
* Update with `nix-channel --update`
* Run `nix-shell` within the root of the project. This will change you into the nix-shell environment with all the necessary packages required, at the correct version level, to run the project.

Note: Nix will never override or otherwise conflict with local packages.

## Running

To start your Phoenix server:

* Run `nix-shell` within the root of the project.
* Install Docker on your local system (<https://docs.docker.com/desktop/install/mac-install/>)
* Run `docker-compose up -d` at the project root to have docker run Postgresql in the background. Usual container management caveats apply. The .gitignore filter won't let .PG_SQL be committed.
* Install dependencies with `mix deps.get`
* Setup the database with `mix db.setup`
* Have all the static assets setup with `mix assets.deploy`
* Start a Phoenix endpoint w/ iex console with `MIX_ENV="dev" iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deploying

Deployments are based on a specific commit being tagged, which fires off the CI deployment workflow.

Run `bin/deploy.sh _environment_` to deploy.

## Local Bootstrapping instructions

Documenting specific trickery here.
