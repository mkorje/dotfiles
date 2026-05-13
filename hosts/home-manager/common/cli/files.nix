{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    wget

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
    svgo
    # mozjpeg
    scour
    libjxl

    # Videos
    ffmpeg
    gifsicle

    # PDF
    ghostscript
    pdftk
    poppler-utils
    verapdf

    # diffoscope

    # Cleaners
    czkawka
    identity
    rmlint

    # Fonts
    (fontforge.override {
      withSpiro = true;
      withGUI = true;
    })
    harfbuzz.dev
    python313Packages.fonttools
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
