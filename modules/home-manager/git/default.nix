{ self, inputs, ... }:
{
  flake.lib.gitModule =
    {
      userName ? "thebromo",
      userEmail ? "manuel@strenge.ch",
      signing ? true,
    }:
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.gh.enable = true;

      programs.git = {
        enable = true;
        lfs.enable = true;

        signing = lib.mkIf signing {
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDohImxI6S0ieD8jmleD3IUj8ZrKFaAVbLBhGab7luu";
          signByDefault = true;
          format = "openpgp";
        };

        settings = {
          user = {
            Name = userName;
            Email = userEmail;
          };
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

          gpg = lib.mkIf signing {
            format = "ssh";
            ssh = {
              program =
                if pkgs.stdenv.isDarwin then
                  "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
                else
                  lib.getExe' pkgs._1password-gui "op-ssh-sign";
              allowedSignersFile =
                let
                  allowedSigners = pkgs.writeText "git-ssh-allowed-signers" ''
                    manuel@strenge.ch ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDohImxI6S0ieD8jmleD3IUj8ZrKFaAVbLBhGab7luu
                    manuel.strenge-ext@hexagon.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDohImxI6S0ieD8jmleD3IUj8ZrKFaAVbLBhGab7luu
                  '';
                in
                "${allowedSigners}";
            };
          };
          credential."https://github.zhaw.ch".helper = "${lib.getExe pkgs.gh} auth git-credential";
          credential."https://gitlab.com/".helper =
            "!f() { test \"$1\" = get && echo \"password=$(op read \"$PARAGON_GITLAB_USER_PAT_OP\")\"; }; f";
        };
      };

      programs.gpg = {
        enable = true;
        package = pkgs.gnupg;
      };

      programs.lazygit = {
        enable = true;
        settings = {
          overrideGpg = true;
          gui.border = "single";
          os.editPreset = "nvim";
        };
      };

      programs.zsh.shellAliases = {
        lg = "lazygit";
      };
    };
}
