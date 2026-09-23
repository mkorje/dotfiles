{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
    ./gaming.nix
    ./network.nix
    ./wayland.nix
  ];

  catppuccin = {
    autoEnable = true;
    enable = true;
    accent = "mauve";
    flavor = "mocha";
  };

  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  allowedUnfreePackages = [
    "fxlinuxprint"
  ];

  environment.systemPackages = with pkgs; [
    openrazer-daemon
    polychromatic
    pwvucontrol
    android-file-transfer
    samba
  ];

  programs.kdeconnect.enable = true;

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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # scanimage -d "airscan:e0:EPSON ET-3800 Series" --resolution 600 -o FILE.pdf
  hardware.sane = {
    enable = true;
    extraBackends = [
      pkgs.sane-airscan
    ];
    disabledDefaultBackends = [ "escl" ];
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      fxlinuxprint
    ];
  };

  environment.etc."samba/smb.conf".text = "";

  hardware.printers = {
    ensurePrinters = [
      {
        name = "UniPrint";
        description = "UniPrint";
        location = "University";
        deviceUri = "smb://uniprint.unimelb.edu.au/UniPrint";
        model = "fxlinuxprint.ppd.gz";
        ppdOptions = {
          PageSize = "A4";
          Duplex = "DuplexNoTumble";
          FXStaple = "UpperLeftSingle";
          auth-info-required = "username,password";
        };
      }
      {
        name = "EPSON30478C";
        description = "EPSON ET-3800 Series";
        location = "Home";
        deviceUri = "ipps://172.18.1.38/ipp/print";
        model = "everywhere";
        ppdOptions = {
          PageSize = "A4";
          MediaType = "Stationery";
          cupsPrintQuality = "High";
          ColorModel = "RGB";
          Duplex = "DuplexNoTumble";
        };
      }
    ];
    ensureDefaultPrinter = "EPSON30478C";
  };

  hardware.openrazer.enable = true;

  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.sane-airscan
  ];

  services.pcscd.enable = true;

  services.udisks2.enable = true;
}
