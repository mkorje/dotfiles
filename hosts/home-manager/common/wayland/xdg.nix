{
  xdg = {
    enable = true;

    mime = {
      enable = true;
    };
    mimeApps = {
      enable = true;
      # associations.added = {
      #   "text/html" = "firefox.desktop";
      #   "text/xml" = "firefox.desktop";
      #   "application/xhtml_xml" = "firefox.desktop";
      #   "image/webp" = "firefox.desktop";
      #   "x-scheme-handler/https" = "firefox.desktop";
      #   "x-scheme-handler/ftp" = "firefox.desktop";
      # };
      defaultApplications = {
        #https://mimetype.io
        #https://devdoc.net/web/developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Complete_list_of_MIME_types.html
        "image/heic" = "imv.desktop";
        "image/png" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "image/avif" = "imv.desktop";
        "image/webp" = "imv.desktop";
        "image/svg+xml" = "imv.desktop";
        "image/tiff" = "imv.desktop";
        "image/gif" = "imv.desktop";
        "image/bmp" = "imv.desktop";
        "image/jxl" = "imv.desktop";

        "video/mp4" = "mpv.desktop";
        "video/x-m4v" = "mpv.desktop";

        "image/vnd.djvu" = "org.pwmt.zathura-djvu.desktop";
        "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
        "application/postscript" = "org.pwmt.zathura-ps.desktop";
        "application/epub+zip" = "calibre-ebook-viewer.desktop";

        "inode/directory" = "pcmanfm.desktop";

        "text/html" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/about" = "librewolf.desktop";
        "x-scheme-handler/unknown" = "librewolf.desktop";
        "text/xml" = "librewolf.desktop";
        "application/xhtml_xml" = "librewolf.desktop";
        "x-scheme-handler/ftp" = "librewolf.desktop";
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      pictures = null;
      publicShare = null;
      templates = null;
      videos = null;
    };
  };
}
