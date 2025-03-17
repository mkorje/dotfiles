{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    wget
    rsync

    # Archives
    zip
    unzip
    p7zip
    ouch

    # Images
    imagemagick
    exiftool
    libavif

    # Videos
    ffmpeg

    # PDF
    ghostscript
    pdftk
    poppler_utils

    # Cleaners
    czkawka
    identity
  ];

  programs = {
    yt-dlp.enable = true;
    mpv.enable = true;
    imv.enable = true;
    gallery-dl = {
      enable = true;
      settings = {
        extractor.base-directory = config.xdg.userDirs.download;
      };
    };
  };
}
