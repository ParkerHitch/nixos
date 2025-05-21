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

    # Make a colorscheme based on nix-colors
    home.file.nvim-base16 = let palette = config.colorScheme.palette; in {
      target = "${config.xdg.dataHome}/nvim/site/colors/nix-base16.lua";
      # TODO: Can we make this reload nvim?
      onChange = 
      # need to delete this otherwise changing our colorscheme does nothing
        ''
        cd ${config.xdg.cacheHome}
        if [ -d nvim/luac ]; then
          run rm -rf nvim/luac
        fi
        '';
      text = 
        ''
        require('mini.base16').setup({
          palette = {
            base00 = '#${palette.base00}',
            base01 = '#${palette.base01}',
            base02 = '#${palette.base02}',
            base03 = '#${palette.base03}',
            base04 = '#${palette.base04}',
            base05 = '#${palette.base05}',
            base06 = '#${palette.base06}',
            base07 = '#${palette.base07}',
            base08 = '#${palette.base08}',
            base09 = '#${palette.base09}',
            base0A = '#${palette.base0A}',
            base0B = '#${palette.base0B}',
            base0C = '#${palette.base0C}',
            base0D = '#${palette.base0D}',
            base0E = '#${palette.base0E}',
            base0F = '#${palette.base0F}',
          }
        })
        vim.g.colors_name = "nix-base16"
        '';
    };


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
