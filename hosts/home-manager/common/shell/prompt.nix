{ inputs, lib, ... }:

{
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      command_timeout = 1000;
    } // lib.importTOML inputs.starship-nerd-font-symbols;
  };
}
