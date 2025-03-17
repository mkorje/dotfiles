{ inputs, ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableTransience = true;
    settings = {
      command_timeout = 1000;
    } // builtins.fromTOML (builtins.readFile inputs.starship-nerd-font-symbols);
  };
}
