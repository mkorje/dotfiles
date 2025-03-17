{ pkgs, ... }:

{
  # accounts.email = {
  #   maildirBasePath = "email";
  #   accounts = {
  #     personal = {

  #     };
  #     university = {
  #       address = "";
  #       aliases = [
  #         ""
  #       ];
  #       realName = "";
  #       passwordCommand = ""; # need to fix
  #       signature = {
  #         command = null;
  #         delimiter = ''
  #           --
  #         '';
  #         showSignature = "none";
  #         text = "";
  #       };
  #       flavor = "gmail.com";
  #       thunderbird = {
  #         enable = true;
  #       };
  #       primary = true;
  #     };
  #   };
  # };

  programs.thunderbird = {
    # enable = true;
    profiles.mkorje = {
      isDefault = true;
    };
    settings = {

    };
  };

  home.packages = with pkgs; [ protonmail-bridge ];
}
