{ pkgs, ... }:

{
  imports = [ ./prompt.nix ];

  programs.fish = {
    enable = true;
    package = pkgs.fish;
    functions = {
      # Usage:
      # nix build --print-out-paths .#nixosConfigurations.<HOSTNAME>.config.system.build.toplevel | nixos-switch
      "nixos-switch" = ''
        if not count $argv > /dev/null
          read drv
        else
          set -f drv $argv[1]
        end
        doas nix-env -p /nix/var/nix/profiles/system --set $drv
        doas $drv/bin/switch-to-configuration switch
      '';
      "find_image_by_alt" = ''
        function find_image_by_alt
            set search_string $argv[1]
            set search_pile $argv[2..]

            for item in $search_pile
                if string match -q "*alt=\"$search_string\"*" $item
                    echo $item
                    return 0
                end
            end

            return 1
        end
      '';
      # Usage:
      # typst-changed-tests branch test1 test2 ..
      "typst-changed-tests" = ''
        set branch $argv[1]
        set tests $argv[2..]

        git checkout main
        testit --exact $tests --scale 20
        for test in $tests
            cp tests/store/render/$test.png $test-OLD.png
        end

        git checkout $branch
        testit --exact $tests --scale 20
        for test in $tests
            cp tests/store/render/$test.png $test-NEW.png
        end

        read -P "Copy image links uploaded: " -d \n -a -s images

        for test in $tests
            rm $test-OLD.png
            rm $test-NEW.png
        end

        echo """<details>

        <summary>Updated tests</summary>

        ---
        """ >details.txt

        for test in $tests
            for test_file in (find tests/suite -type f -name "*.typ")
                set -l content (sed -n '/^--- '"$test"' ---/,/^--- /{
                    /^--- '"$test"' ---/p
                    /^--- /!p
                }' $test_file)
                if test -n "$content"
                    set old (find_image_by_alt "$test-OLD" $images)
                    set new (find_image_by_alt "$test-NEW" $images)
                    echo """```typ
        $(string join -- \n $content)
        ```

        | Old | New |
        | - | - |
        | $old | $new |

        ---
        """ >>details.txt
                end
            end
        end

        echo """</details>""" >>details.txt
      '';
    };
    generateCompletions = true;
    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };

  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    exitShellOnExit = true;
    settings = {
      on_force_close = "quit";
      pane_frames = false;
      default_layout = "compact";
      ui.pane_frames.hide_session_name = true;
      show_startup_tips = false;
      show_release_notes = false;
    };
  };
}
