{ config, pkgs, ... }:
let model_elixirChannel = import <model_elixir> { };

in {
  environment.systemPackages = [ model_elixirChannel.model_elixir_api ];

  systemd.services.model_elixir = {
    wantedBy = [ "model_elixir-install.service" ];
    after = [
      "network.target"
      "model_elixir-install.service"
      "model_elixir-credentials.service"
    ];
    requires = [ "model_elixir-credentials.service" ];
    description = "model_elixir elixir api";
    serviceConfig = {
      Type = "simple";
      User = "model_elixir";
      WorkingDirectory = "/home/model_elixir";
      ExecStart =
        "''${model_elixirChannel.model_elixir_api}/bin/model_elixir start";
      ExecStartPost = [
        "''${model_elixirChannel.model_elixir_api}/bin/model_elixir eval 'model_elixir.ReleaseTasks.migrate()'"
        "''${model_elixirChannel.model_elixir_api}/bin/model_elixir eval 'model_elixir.ReleaseTasks.register_load_balancer()'"
      ];

      ExecStop = [
        "''${model_elixirChannel.model_elixir_api}/bin/model_elixir eval 'model_elixir.ReleaseTasks.deregister_load_balancer()'"
        "''${model_elixirChannel.model_elixir_api}/bin/model_elixir stop"
      ];
      EnvironmentFile = "/home/model_elixir/envvar.env";
      Restart = "on-failure";
      RestartSec = "5";
      SyslogIdentifier = "model_elixir";
      RemainAfterExit = "no";
    };
  };

  systemd.services.model_elixir.enable = true;

  systemd.services.model_elixir-credentials = {
    wantedBy = [ "model_elixir-install.service" ];
    after = [ "network.target" "model_elixir-install.service" ];
    description = "elixir model_elixir api credentials";
    serviceConfig = {
      Type = "oneshot";
      User = "model_elixir";
      WorkingDirectory = "/home/model_elixir";
      ExecStart =
        "''${model_elixirChannel.model_elixir_api}/bin/credentials ENVIRONMENT /home/model_elixir/envvar.env";
      ExecStop = "''${pkgs.coreutils}/bin/rm /home/model_elixir/envvar.env";
      SyslogIdentifier = "model_elixir";
      RemainAfterExit = true;
    };
  };

  systemd.services.model_elixir-credentials.enable = true;
}
