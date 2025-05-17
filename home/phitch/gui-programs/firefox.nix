{ config, pkgs, lib, ... }:

{
  options = {
    modules.firefox = {
      enable = lib.mkEnableOption "whether or not to enable firefox";
    };
  };
  config = lib.mkIf config.modules.firefox.enable {
    programs.firefox = {
      enable = true;
      profiles = {
        main = {
          id = 0;
          name = "main";
          isDefault = true;
        };
        purdue = {
          id = 1;
          name = "Purdue";
          isDefault = false;
        };
      };
    };
  };
}
