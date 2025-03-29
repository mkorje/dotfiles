{ pkgs, ... }:

{
  programs.librewolf = {
    enable = true;
    settings = {
      "privacy.resistFingerprinting.letterboxing" = true;
      "network.http.referer.XOriginPolicy" = 2;
      "media.autoplay.blocking_policy" = 2;
      "accessibility.force_disabled" = 1;
      "identity.fxaccounts.enabled" = true;
      "security.ssl.require_safe_negotiation" = false;
    };
  };

  home.packages = with pkgs; [
    tor-browser
    ungoogled-chromium
  ];
}
