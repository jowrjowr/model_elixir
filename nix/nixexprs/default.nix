{ nixpkgs ? import <nixpkgs> {} }:
{
  aloha_api = nixpkgs.callPackage ./aloha.nix { 
    pkgs = nixpkgs;
  };
}
