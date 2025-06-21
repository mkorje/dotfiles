{
  services.openssh = {
    enable = true;
    allowSFTP = false;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
    settings.AllowUsers = [ "admin" ];
    settings.KbdInteractiveAuthentication = false;
    settings.LogLevel = "VERBOSE";
    hostKeys = [
      {
        path = "/persist/ssh/keys/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
