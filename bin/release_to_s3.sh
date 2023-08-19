#!/bin/sh

set -e

notify() {
  echo
  echo "====================================="
  echo "${1}"
  echo "====================================="
  echo
}

env=$1

if [ -z "$env" ]; then
  echo "Missing argument ENV, example: bin/release_to_s3.sh dev"
  exit 1
fi

aws_region="us-west-2"
s3_nix_channel="company-model_elixir-$env-nix-channel"
s3_nix_binary_cache="company-model_elixir-$env-nix-binary-cache"
nixos_cache_key="cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

notify "We will deploy to environment $env"

notify "Getting information about the git repo..."

ln -sf "$(pwd)" /tmp/model_elixir

git_url="file:///tmp/model_elixir"
git_json=$(nix-prefetch-git --url "$git_url" --rev "$(git rev-parse --verify HEAD)" --quiet)
git_rev=$(echo "$git_json" | jq '.rev' -r)
git_sha256=$(echo "$git_json" | jq '.sha256' -r)
channel_dir="model_elixir-$git_sha256"
notify "Building the Nix channel..."

rm -rf tmp

mkdir -p tmp/"$channel_dir"/nixexprs/nix

# We want the following files:
# nixexprs/default.nix (channel description, from nix/nixexprs/default.nix)
# nixexprs/nix/release.sh (from nix/release.sh)
# nixexprs/model_elixir.nix (the api derivation, from default.nix)

cp nix/nixexprs/default.nix "tmp/$channel_dir/nixexprs/default.nix"
cp nix/package_release.sh "tmp/$channel_dir/nixexprs/nix/package_release.sh"
cp nix/package_release.nix "tmp/$channel_dir/nixexprs/model_elixir.nix"
rm -f /tmp/release.tar.gz
cp -v release.tar.gz /tmp/release.tar.gz

sed -i "s|GIT_URL|$git_url|g" "tmp/$channel_dir/nixexprs/model_elixir.nix"
sed -i "s|GIT_REV|$git_rev|g" "tmp/$channel_dir/nixexprs/model_elixir.nix"
sed -i "s|GIT_SHA256|$git_sha256|g" "tmp/$channel_dir/nixexprs/model_elixir.nix"

tar -cJf tmp/channel.tar.xz -C "tmp/$channel_dir" nixexprs

notify "Building nix package..."

cd "tmp/$channel_dir"

nix-build nixexprs/default.nix --arg nixpkgs "import <nixpkgs> {}" --option sandbox false --option extra-substituters "s3://$s3_nix_binary_cache?region=$aws_region" --option trusted-public-keys "$nixos_cache_key $(cat ../../nix/keys/key.public)" | tail -n 1

notify "Signing packages"
nix store sign -k ../../nix/keys/key.secret --derivation --all --extra-experimental-features nix-command

notify "Uploading nix package to binary cache..."

deriver_result=$(nix-store --query --deriver result/)

# adding --requisites to nix-store includes EVERYTHING it takes to build that derivation
# that takes forever to upload, and is not necessary. do not do that.

nix_store_path=$(nix-store --query --include-outputs "$deriver_result")

# shellcheck disable=SC2086

nix copy --to "s3://$s3_nix_binary_cache?region=$aws_region" --option narinfo-cache-positive-ttl 0 $nix_store_path --extra-experimental-features nix-command

cd ../..
echo "http://$s3_nix_binary_cache.s3-$aws_region.amazonaws.com" > "tmp/$channel_dir/binary-cache-url"
notify "Uploading Nix channel to S3..."

touch tmp/empty_file # an empty file (will be a redirect)

# shellcheck disable=SC2045
for file in $(ls terraform/configuration); do
  aws s3 cp "terraform/configuration/$file" "s3://$s3_nix_binary_cache/$file"
done


aws s3 cp tmp/channel.tar.xz "s3://$s3_nix_channel/model_elixir-$git_rev/nixexprs.tar.xz"
aws s3 cp nix/nix-cache-info "s3://$s3_nix_channel/model_elixir-$git_rev/nix-cache-info"
aws s3 cp "tmp/$channel_dir/binary-cache-url" "s3://$s3_nix_channel/model_elixir-$git_rev/binary-cache-url"

aws s3 cp tmp/empty_file "s3://$s3_nix_channel/model_elixir-$git_rev"
aws s3 cp tmp/empty_file "s3://$s3_nix_channel/channel" --website-redirect "/model_elixir-$git_rev"

notify "Done!"
