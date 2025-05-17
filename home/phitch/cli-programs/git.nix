{ pkgs, ... } :

{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
 
    userName = "Parker Hitchcock";
    userEmail = "parker.hitchcock@gmail.com";

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      credential = {
        helper = "manager";
        credentialStore = "secretservice";
      };
    };
  };
}
