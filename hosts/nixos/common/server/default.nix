{ config, ... }:

{
  imports = [
    ./ssh.nix
  ];

  sops.secrets."users/admin/hashedPassword".neededForUsers = true;
  users.groups."admin" = { };
  users.users."admin" = {
    isSystemUser = true;
    group = "admin";
    extraGroups = [ "wheel" ];
    # $ tr -dc A-Za-z0-9 </dev/urandom | head -c 16; echo
    # $ mkpasswd -m sha-512 -S IlkR8cwWvP92yKzo -R 1000000
    hashedPasswordFile = config.sops.secrets."users/admin/hashedPassword".path;
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAy85V584V07OJ5VrT4sppXhOUguaUOtIvzw9GNw2J6XAAAACXNzaDpuaXhvcw== ssh:nixos"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL7Bw28cFjA5JWcwBEA/LT4ILIA0HikwTic+7agOAkhnAAAACXNzaDpuaXhvcw== ssh:nixos"
    ];
  };
}
