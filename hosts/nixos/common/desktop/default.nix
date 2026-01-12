{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
    ./network.nix
    ./wayland.nix
  ];

  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  allowedUnfreePackages = [
    "steam"
    "steam-original"
    "steam-run"
    "steam-unwrapped"
    "fxlinuxprint"
  ];

  environment.systemPackages = with pkgs; [
    # dolphin-emu
    openrazer-daemon
    polychromatic
    pwvucontrol
    android-file-transfer
  ];

  programs.kdeconnect.enable = true;

  programs.steam.enable = true;

  sops.secrets = {
    "users/mkorje/hashedPassword" = {
      sopsFile = ./secrets.yaml;
      neededForUsers = true;
    };
  };

  programs.fish.enable = true;

  users = {
    users."mkorje" = {
      shell = pkgs.fish;
      isNormalUser = true;
      group = "mkorje";
      extraGroups = [
        "wheel"
        "audio"
        "openrazer"
        "scanner"
        "lp"
      ];
      hashedPasswordFile = config.sops.secrets."users/mkorje/hashedPassword".path;
    };
    groups."mkorje" = { };
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      epson-escpr2
      fxlinuxprint
    ];
  };

  services.samba = {
    enable = true;
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "EPSON30478C";
        description = "EPSON ET-3800 Series";
        location = "Home";
        deviceUri = "ipps://172.18.1.38/ipp/print";
        model = "epson-inkjet-printer-escpr2/Epson-ET-3800_Series-epson-escpr2-en.ppd";
        ppdOptions = {
          PageSize = "A4";
          Duplex = "DuplexNoTumble";
          MediaType = "PLAIN_HIGH";
          Ink = "COLOR";
        };
      }
      {
        name = "UniPrint";
        deviceUri = "smb://uniprint.unimelb.edu.au/UniPrint";
        model = "fxlinuxprint.ppd.gz";
        ppdOptions = {
          PageSize = "A4";
          auth-info-required = "username,password";
          FXColorMode = "Black";
        };
      }
    ];
    ensureDefaultPrinter = "EPSON30478C";
  };

  hardware.openrazer.enable = true;

  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  services.udisks2.enable = true;
}
