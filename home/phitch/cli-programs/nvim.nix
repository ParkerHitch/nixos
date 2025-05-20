{pkgs, lib, config, ... } :
{
  options = {
    modules.nvim = {
      enable = lib.mkEnableOption "Whether or not to enable nvim";
      dotfileRepo = lib.mkOption {
        default = null;
        description = "The url of the repo to `git clone` into place";
      };
    };
  };
  config = lib.mkIf (config.modules.nvim.enable) {

    programs.neovim = {
      enable = true;
      withNodeJs = true;
    };

    # Link in clangd
    home.file.masonClangd = {
      enable = true;
      executable = true;
      source = "${pkgs.clang-tools}/bin/clangd";
      target = "${config.xdg.dataHome}/nvim/mason/bin/clangd";
    };
    # And make a random dir for it
    home.activation.masonClangdDir = 
      lib.hm.dag.entryAfter [ "writeBoundary" ]
      ''
        run mkdir -p ${config.xdg.dataHome}/nvim/mason/packages/clangd
      '';

    # Clone nvim
    home.activation.cloneNvim = 
      lib.mkIf (config.modules.nvim.dotfileRepo != null) (
        lib.hm.dag.entryAfter [ "writeBoundary" ]
        ''
          PATH="${config.home.path}/bin:$PATH"
          cd ${config.xdg.configHome}
          if [ ! -d nvim ]; then
            run ${pkgs.git}/bin/git clone ${config.modules.nvim.dotfileRepo} nvim
          fi
        ''
      );
  };
}
