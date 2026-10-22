{ ... }:
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
      home.file.".gitignore".text = ''
        **/.claude/settings.local.json
        .devenv
        .direnv
        node_modules
      '';

      programs.gh.enable = true;

      programs.git = {
        enable = true;
        lfs.enable = true;

        signing = lib.mkIf signing {
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDohImxI6S0ieD8jmleD3IUj8ZrKFaAVbLBhGab7luu";
          # Only lazygit signs
          signByDefault = false;
          format = "ssh";
        };

        settings = {
          user = {
            name = userName;
            email = userEmail;
          };
          init.defaultBranch = "main";
          pull.rebase = true;
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
            ssh = {
              program =
                if pkgs.stdenv.hostPlatform.isDarwin then
                  "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
                else
                  lib.getExe' pkgs._1password-gui "op-ssh-sign";
              allowedSignersFile =
                let
                  allowedSigners = pkgs.writeText "git-ssh-allowed-signers" ''
                    manuel@strenge.ch ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBDohImxI6S0ieD8jmleD3IUj8ZrKFaAVbLBhGab7luu
                  '';
                in
                "${allowedSigners}";
            };
          };
        };
      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
      };

      programs.gpg = {
        enable = true;
        package = pkgs.gnupg;
      };

      programs.lazygit = {
        enable = true;
        package = lib.mkIf signing (
          pkgs.symlinkJoin {
            name = "lazygit-signed";
            paths = [ pkgs.lazygit ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/lazygit \
                --set GIT_CONFIG_COUNT 2 \
                --set GIT_CONFIG_KEY_0 commit.gpgSign \
                --set GIT_CONFIG_VALUE_0 true \
                --set GIT_CONFIG_KEY_1 tag.gpgSign \
                --set GIT_CONFIG_VALUE_1 true
            '';
          }
        );
        settings = {
          overrideGpg = true;
          gui.border = "single";
          os.editPreset = "nvim";
        };
      };

      home.shellAliases = {
        lg = "lazygit";
      };
    };
}
