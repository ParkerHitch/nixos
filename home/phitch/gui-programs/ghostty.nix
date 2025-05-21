{ config, pkgs, lib, nix-colors, ... }:
let
  palette = config.colorScheme.palette;
in
{
  options = {
    modules.ghostty = {
      enable = lib.mkEnableOption "Whether or not to enable ghostty";
      useBase16 = lib.mkEnableOption "Whether to use base16 (nix-colors) for Ghostty's theme";
    };
  };
  config = lib.mkIf config.modules.ghostty.enable {

    programs.ghostty = {
      enable = true;

      enableFishIntegration = true;
      settings = {
        command = ''"/usr/bin/env fish"'';
        theme = if config.modules.ghostty.useBase16 then ''"base16"'' else ''"Ayu Mirage"'';
        font-family = ''"FiraCode Nerd Font"'';
      };

      themes.base16 = {
        background = palette.base00;
        foreground = palette.base05;
        selection-background = palette.base02;
        selection-foreground = palette.base05; # TODO: Check if default foreground is good
        cursor-color = palette.base0A;
        palette = [
          "0=${palette.base00}"
          "1=${palette.base08}"
          "2=${palette.base0B}"
          "3=${palette.base0A}"
          "4=${palette.base0D}"
          "5=${palette.base0E}"
          "6=${palette.base0C}"
          "7=${palette.base05}"

          " 8=${palette.base03}"
          " 9=${palette.base08}"
          "10=${palette.base0B}"
          "11=${palette.base0A}"
          "12=${palette.base0D}"
          "13=${palette.base0E}"
          "14=${palette.base0C}"
          "15=${palette.base07}"
          
          "16=${palette.base09}"
          "17=${palette.base0F}"
          "18=${palette.base01}"
          "19=${palette.base02}"
          "20=${palette.base04}"
          "21=${palette.base06}"
        ];
      };
    };
  };
}
