{ config, pkgs, lib, ... }:

{

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "asahi";
	padding = {
          left = 1;
	  top = 1;
	  right = 2;
        };
      };
      modules = [
        "title"
        "separator"
	"os"
	"host"
	"kernel"
	"uptime"
	"packages"
	"shell"
	"wm"
	"terminal"
	"cpu"
	"memory"
	"swap"
	"disk"
	"battery"
	"break"
	"weather"
	"colors"
      ];
    };
  };

  programs.fish = {
    enable = true;

    interactiveShellInit = 
    ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';

    functions = {
      fish_greeting = "fastfetch";
    };

    shellAliases = lib.mkIf config.modules.nvim.enable {
      vim = "nvim";
    };
  };
}
