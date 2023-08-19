{ nixpkgs ? import <nixpkgs> {} }:
{
  model_elixir_api = nixpkgs.callPackage ./model_elixir.nix { 
    pkgs = nixpkgs;
  };
}
