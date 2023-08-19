# NOTE: these are not comments. amazon-image.nix parses them and adds them as channels
# yes, that's variable substitution in a not-a-comment comment

### https://nixos.org/channels/nixos-23.05 nixos
### http://${s3_deployment_bucket}.s3-website-us-west-2.amazonaws.com model_elixir

{ config, pkgs, ... }:

let
  default_import_list =
    [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  import_list = if builtins.pathExists "/etc/nixos/system_install.nix" then
    [ "/etc/nixos/system_install.nix" ] ++ default_import_list
  else
    default_import_list;

  model_elixirInstallScript = ''
    #!$${pkgs.runtimeShell} -eu

    export HOME=/root
    export PATH=$${pkgs.lib.makeBinPath [ config.nix.package pkgs.systemd pkgs.gnugrep pkgs.coreutils pkgs.gnused config.system.build.nixos-rebuild]}:$$PATH
    export PATH=$$PATH:/run/current-system/sw/bin
    export NIX_PATH=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels

    # install system tooling

    aws s3 cp s3://${s3_binary_bucket}/system_install.nix /etc/nixos/system_install.nix
    rm -f /root/.ssh/authorized_keys
    aws s3 cp s3://${s3_binary_bucket}/ssh_keys /root/.ssh/authorized_keys
    sed -i s/ENVIRONMENT/"${environment}"/g /etc/nixos/system_install.nix

    nixos-rebuild switch
  '';
in {
  imports = import_list;
  ec2.hvm = true;

  nix.binaryCaches = [
    "https://cache.nixos.org/"
    "http://${s3_binary_bucket}.s3-us-west-2.amazonaws.com"
  ];

  nix.binaryCachePublicKeys = [ "${binary_cache_public_key}" ];
  nix.useSandbox = false;

  # firewalling is managed externally
  networking.firewall.enable = false;
  services.openssh.passwordAuthentication = false;

  environment.systemPackages = with pkgs; [
    coreutils
    psmisc
    tcpdump
    bash
    screen
    awscli
    jq
    python38
  ];

  # Garbage collection of nix profile older than 15days, run every night at 03:15 UTC
  nix.gc.automatic = true;
  nix.gc.dates = "03:15";
  nix.gc.options = "--delete-older-than 7d";

  # model_elixir user and service

  users.users.model_elixir = {
    isNormalUser = true;
    shell = "/bin/false";
    createHome = true;
  };

  users.users.teleport = {
    isNormalUser = true;
    shell = "/bin/false";
    createHome = false;
  };

  # limits for the model_elixir user

  security.pam.loginLimits = [{
    domain = "model_elixir";
    item = "nofile";
    type = "-";
    value = "1048576";
  }];

  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

  systemd.services.model_elixir-install = {
    script = model_elixirInstallScript;
    description = "Install model_elixir api";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    restartIfChanged = false;
    unitConfig.X-StopOnRemoval = false;
    serviceConfig = {
      User = "root";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
  systemd.services.model_elixir-install.enable = true;
}
