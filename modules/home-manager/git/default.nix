{
  pkgs,
  lib,
  ...
}: {
  programs.gh.enable = true;

  programs.git = {
    enable = true;
    userName = "thebromo";
    userEmail = "manuel@strenge.ch";
    lfs.enable = true;

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDohImxI6S0ieD8jmleD3IUj8ZrKFaAVbLBhGab7luu";
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = "true";
      delta.enable = "true";
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      help.autocorrect = "prompt";
      commit.verbose = true;
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      core = {
        excludesfile = "~/.gitignore";
        fsmonitor = true;
        untrackedCache = true;
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      merge = {
        conflictstyle = "zdiff3";
      };

      gpg = {
        format = "ssh";
        ssh = {
          program =
            if pkgs.stdenv.isDarwin
            then "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
            else lib.getExe' pkgs._1password-gui "op-ssh-sign";
          allowedSignersFile = let
            allowedSigners = pkgs.writeText "git-ssh-allowed-signers" ''
              manuel@strenge.ch ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDohImxI6S0ieD8jmleD3IUj8ZrKFaAVbLBhGab7luu
            '';
          in "${allowedSigners}";
        };
      };
      credential."https://github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
      credential."https://gist.github.com".helper = "${lib.getExe pkgs.gh} auth git-credential";
      credential."https://github.zhaw.ch".helper = "${lib.getExe pkgs.gh} auth git-credential";
    };
  };

  programs.gpg = {
    enable = true;
    package = pkgs.gnupg;
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
