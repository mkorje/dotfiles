{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    gnome-text-editor
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      editor = {
        text-width = 80;
        soft-wrap = {
          enable = true;
          #max-wrap = 25; # increase value to reduce forced mid-word wrapping
          #max-indent-retain = 0;
          wrap-indicator = ""; # set wrap-indicator to "" to hide it
        };
      };
    };
    package = inputs.helix.packages.${pkgs.system}.default;
    extraPackages = with pkgs; [
      bash-language-server
      clang-tools
      # cmake-language-server
      fish-lsp
      google-java-format
      harper
      jdt-language-server
      lldb
      marksman
      nil
      nixfmt
      nodePackages_latest.vscode-json-languageserver
      rust-analyzer
      swi-prolog
      taplo
      texlab
      tinymist
      typstyle
      vale
      vale-ls
      yaml-language-server

      # Python
      ruff
      ty

      # ltex-ls
      # typos-lsp
      # typst-languagetool
    ];
    languages = {
      language-server = {
        harper-ls = {
          command = "harper-ls";
          args = [ "--stdio" ];
          config.harper-ls = {
            dialect = "Australian";
          };
        };
        # tinymist.config = {
        #   projectResolution = "lockDatabase";
        #   outputPath = "$root/../target/$dir/$name";
        #   exportPdf = "onType";
        #   rootPath = "/src";
        #   formatterMode = "typstyle";
        # };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
        }
        {
          name = "python";
          file-types = [
            "py"
            "pyi"
            "py3"
            "pyw"
            "ptl"
            "rpy"
            "cpy"
            "ipy"
            "pyt"
            { glob = ".python_history"; }
            { glob = ".pythonstartup"; }
            { glob = ".pythonrc"; }
            { glob = "*SConstruct"; }
            { glob = "*SConscript"; }
            { glob = "*sconstruct"; }
            # Extras
            "sage"
            "spyx"
          ];
          auto-format = true;
        }
        {
          name = "java";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = true;
          formatter = {
            command = "google-java-format";
            args = [
              "--aosp"
              "-"
            ];
          };
        }
        {
          name = "toml";
          auto-format = true;
          formatter = {
            command = "taplo";
            args = [
              "fmt"
              "-"
            ];
          };
        }
        {
          name = "typst";
          auto-format = true;
          formatter.command = "typstyle";
        }
      ];
    };
  };
}
