{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./network.nix
    ./wayland.nix
  ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/bluetooth"
      "/etc/mullvad-vpn"
    ];
  };

  allowedUnfreePackages = [
    "steam"
    "steam-original"
    "steam-run"
    "steam-unwrapped"
    "discord"
  ];

  environment.systemPackages = with pkgs; [
    dolphin-emu
    openrazer-daemon
    polychromatic
    discord
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  i18n.defaultLocale = "en_AU.UTF-8";

  time = {
    timeZone = "Australia/Melbourne";
    hardwareClockInLocalTime = false;
  };

  sops.secrets = {
    "users/mkorje/hashedPassword" = {
      sopsFile = ./secrets.yaml;
      neededForUsers = true;
    };
  };

  programs.fish.enable = true;
  documentation.man.generateCaches = false;

  users = {
    mutableUsers = false;
    users = {
      "root".hashedPassword = "!";
      "mkorje" = {
        shell = pkgs.fish;
        isNormalUser = true;
        group = "mkorje";
        extraGroups = [
          "wheel"
          "audio"
          "openrazer"
        ];
        hashedPasswordFile = config.sops.secrets."users/mkorje/hashedPassword".path;
      };
    };
    groups."mkorje" = { };
  };

  #needed for amberol (in home-manager config) daemon to work correctly
  programs.dconf.enable = true;

  # printing
  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr2 ];
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "EPSON30478C";
        description = "EPSON ET-3800 Series";
        location = "Home";
        deviceUri = "ipps://192.168.0.4/ipp/print";
        model = "epson-inkjet-printer-escpr2/Epson-ET-3800_Series-epson-escpr2-en.ppd";
        ppdOptions = {
          PageSize = "A4";
          Duplex = "DuplexNoTumble";
          MediaType = "PLAIN_HIGH";
          Ink = "COLOR";
        };
      }
    ];
    ensureDefaultPrinter = "EPSON30478C";
  };

  hardware.openrazer.enable = true;

  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  # services = {
  # upower.enable = true;
  # xserver.libinput.enable = true;
  # };
}
