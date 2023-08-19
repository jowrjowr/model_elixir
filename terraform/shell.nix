{ pkgs ? import <nixos-unstable> { } }:

with pkgs;

mkShell {
  buildInputs = [ terraform tflint jq ];
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

    if [ -f "$AUTH0_PATH" ]; then
      source "$AUTH0_PATH"
    fi
  '';

  TF_VAR_key_name = "";

}
