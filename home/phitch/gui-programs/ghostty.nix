{ config, pkgs, lib, ... }:

{
  options = {
    modules.ghostty = {
      enable = lib.mkEnableOption "Whether or not to enable ghostty`";
    };
  };
  config = lib.mkIf config.modules.ghostty.enable {
    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        command = ''"/usr/bin/env fish"'';
        theme = ''"Ayu Mirage"'';
        font-family = ''"FiraCode Nerd Font"'';
      };
    };
  };
}
