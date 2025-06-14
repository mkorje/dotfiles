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
  };

  boot.initrd.systemd.services."persist-files" = {
    description = "Hard-link persisted files from /persist";
    wantedBy = [ "initrd.target" ];
    after = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /sysroot/etc/
      ln -snfT /persist/machine-id /sysroot/etc/machine-id
    '';
  };
}
