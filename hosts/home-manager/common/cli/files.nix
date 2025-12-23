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
    # mozjpeg
    scour

    # Videos
    ffmpeg
    gifsicle

    # PDF
    ghostscript
    pdftk
    poppler-utils

    # Cleaners
    (pkgs.czkawka.overrideAttrs (_: rec {
      version = "unstable-2025-12-03";
      src = pkgs.fetchFromGitHub {
        owner = "qarmin";
        repo = "czkawka";
        rev = "6296b06f3a6798f07f78cd771ed95d75639f7bbb";
        hash = "sha256-legzp0mmNgKz9dw7rpnkAXXYjW3BFur8e+W7289bHI8=";
      };
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit src;
        hash = "sha256-16swKsTutg4/T24zpj0BwjYBKbeGdf8BGNDZPgE5PwU=";
      };
      checkPhase = ''
        runHook preCheck
        xvfb-run cargo test -- \
          --skip common::cache::tests::test_save_and_load_cache_by_path \
          --skip common::cache::tests::test_save_and_load_cache_by_size \
          --skip common::cache::tests::test_save_cache_with_json \
          --skip common::cache::tests::test_save_cache_with_minimum_file_size
        runHook postCheck
      '';
      doInstallCheck = false;
    }))
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
