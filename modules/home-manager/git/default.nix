{ pkgs, lib, ... }: {
  programs.gh.enable = true;

  programs.git = {
    enable = true;
    userName = "thebromo";
    userEmail = "manuel@strenge.ch";
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = "true";
      delta.enable = true;

      credential."https://github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
      credential."https://gist.github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
      credential."https://github.zhaw.ch".helper = "${lib.getExe pkgs.gh} auth git-credential";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git.paging = {
        colorArg = "always";
        pager = "${lib.getExe pkgs.delta} --dark --paging=never";
      };
      core.editor = "nvim";
    };
  };
}
