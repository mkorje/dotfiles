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
    oxipng
    jpegoptim
    libwebp
    nodePackages_latest.svgo
    mozjpeg
    scour

    # Videos
    ffmpeg
    gifsicle

    # PDF
    ghostscript
    pdftk
    poppler_utils

    # Cleaners
    czkawka
    identity

    # Fonts
    (fontforge.override {
      withSpiro = true;
      withGUI = true;
    })
    harfbuzz.dev
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
