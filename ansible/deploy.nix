with import <nixpkgs> {};

{
  openssh = openssh;
  curl = curl;
  python-ansible = pkgs.python39.withPackages (p: with p; [
    boto3
    botocore
  ]);
  ansible = ansible;
}
