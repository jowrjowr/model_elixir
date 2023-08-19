{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  inherit (lib) optional optionals;
  python = python37.withPackages(ps: with ps; [ boto3 ansible ]);
in
mkShell {
  buildInputs = [
    python
    openssh
  ]
    ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      # For file_system on macO.S
      CoreFoundation
      CoreServices
      clang
    ]);

  # Fix GLIBC Locale
  LOCALE_ARCHIVE = lib.optionalString stdenv.isLinux
    "${pkgs.glibcLocales}/lib/locale/locale-archive";
  LANG = "en_US.UTF-8";


  shellHook = ''
  function aws_mfa {

    # reset so old stuff isn't used
    AWS_ACCESS_KEY_ID=""
    AWS_SECRET_ACCESS_KEY=""
    AWS_SESSION_TOKEN=""

    # fetch credentials
    MFA_ARN=$(aws iam list-mfa-devices | jq -r '.MFADevices[0].SerialNumber' | tr -d '"')
    CREDENTIALS=$(aws sts get-session-token --duration-seconds 129600 --serial-number $MFA_ARN --token-code $1)

    # store
    export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')
    EXPIRES=$(echo $CREDENTIALS | jq '.Credentials.Expiration')

    echo "AWS Session Token expires at $EXPIRES"

  }
  '';

}
