{
  inputs,
  ...
}:

{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/log/journal"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
