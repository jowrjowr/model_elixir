#!/bin/bash

# shellcheck disable=SC2154,SC1091
source "$stdenv/setup"

### phases order in stdenv
### $prePhases unpackPhase patchPhase $preConfigurePhases configurePhase
### $preBuildPhases buildPhase checkPhase $preInstallPhases installPhase
### fixupPhase $preDistPhases distPhase $postPhases
### They all have "pre" and "post" hooks

preConfigure() {
  
  export build="$out/tmp"
  mkdir -p "$build"
}

postConfigure() {
  mkdir -p "$TMPDIR/home"
  export HOME="$TMPDIR/home"
}

installPhase() {

  # very simple setup since we build the release in an earlier step

  mkdir -p "$out/bin"
  cp -v bin/credentials "$out/bin/"
  chmod +x "$out/bin/credentials"
  tar xzvf /tmp/release.tar.gz -C "$out"
}

postInstall () {
  # remove all release artifacts
  rm -rf "$build"
}

genericBuild