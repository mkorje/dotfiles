{
  config,
  pkgs,
  ...
}:

{
  imports = [ ./network.nix ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/bluetooth"
      "/etc/mullvad-vpn"
      "/var/cache/tuigreet"
    ];
  };

  allowedUnfreePackages = [
    "steam"
    "steam-original"
    "steam-run"
    "steam-unwrapped"
  ];

  environment.systemPackages = with pkgs; [
    dolphin-emu
    pavucontrol
    openrazer-daemon
    polychromatic
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

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # look at theming: https://github.com/apognu/tuigreet?tab=readme-ov-file#theming
  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --time --remember --remember-session";
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

  # systemd.services.greetd.serviceConfig = {
  #   StandardInput = "tty";
  #   StandardOutput = "tty";
  #   StandardError = "journal";  # without this errors will spam on screen
  #   # Without these bootlogs will spam on screen
  #   TTYReset = true;
  #   TTYVHangup = true;
  #   TTYVTDisallocate = true;
  # };

  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  # services = {
  # upower.enable = true;
  # xserver.libinput.enable = true;
  # };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

}
