{ pkgs ? import <nixpkgs> { } }:
let
  stdenv = pkgs.stdenv;
  git_rev = "GIT_REV";

in stdenv.mkDerivation {
  name = "aloha";
  builder = ./nix/package_release.sh;

  nativeBuildInputs = [
    pkgs.coreutils
    pkgs.gnutar
    pkgs.glibcLocales
    pkgs.git
  ];

  src = pkgs.fetchgit {
    url = "GIT_URL";
    rev = git_rev;
    sha256 = "GIT_SHA256";
  };

  system = builtins.currentSystem;
  MIX_ENV = "prod";
  LANG = "en_US.UTF-8";
  dontUseCmakeConfigure = true;
  dontFixup = true;
}
