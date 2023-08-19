with import <nixpkgs> { };

let
  inherit (lib) optional optionals;
  #elixir = beam.packages.erlangR25.elixir_1_13;
in

{
  coreutils = coreutils;
  nix-prefetch-git = nix-prefetch-git;
  xz = xz;
  jq = jq;
  awscli2 = awscli2;
  curl = curl;
  gnused = gnused;
  elixir = elixir_1_15;
  cacert = cacert;
  erlang = erlang;
  gnutar = gnutar;
  nodejs = nodejs;
  glibc = glibc;
  glibcLocales = glibcLocales;
  gnumake = gnumake;
  gcc = gcc;
  openssl = openssl; 
  gawk = gawk;

  LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
}