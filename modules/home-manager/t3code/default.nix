# To update:
#   1. Change `version` below
#   2. Set hash to empty string: hash = "";
#   3. Run: nix build .#homeConfigurations.<host>.activationPackage
#   4. Copy the correct hash from the error message
{ ... }:
{
  flake.homeModules.t3code =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # Server settings (git, worktrees, models) and UI preferences. T3 Code
      # owns both files and writes its own state into them, so activation
      # merges these keys in instead of linking read-only files.
      settings = {
        branchNamePrefix = "feat";
        branchNamingMode = "semantic";
        defaultModelSelection = {
          instanceId = "codex";
          model = "gpt-6.1-sol";
          options = [
            {
              id = "reasoningEffort";
              value = "medium";
            }
            {
              id = "serviceTier";
              value = "priority";
            }
          ];
        };
        projectSettingsFolded = true;
        sourceControlWriterModelSelection = {
          instanceId = "codex";
          model = "gpt-6-luna";
          options = [
            {
              id = "reasoningEffort";
              value = "low";
            }
          ];
        };
        sourceControlWritingStyle = {
          mode = "conventional_commits";
        };
        storageCleanup = {
          worktreeOnMerge = true;
        };
        worktreesDirectory = "~/Development/Worktrees";
      };

      clientSettings = {
        appearanceContrast = 100;
        browserAutoShowFloatingPreview = true;
        browserCustomSearchUrl = "";
        browserDefaultAppearance = "system";
        browserDefaultProfileId = "default";
        browserDefaultViewport = {
          _tag = "fill";
        };
        browserDefaultZoomFactor = 1;
        browserLinkTarget = "system";
        browserRecordingFrameRate = 30;
        browserRecordingShowKeyPresses = false;
        browserRecordingShowMousePresses = false;
        browserSearchEngine = "duckduckgo";
        chatWidth = "comfortable";
        composerCollapseOnScroll = true;
        composerRichTextEnabled = true;
        confirmQuit = "hold";
        confirmThreadArchive = false;
        confirmThreadDelete = true;
        confirmThreadUnpin = false;
        contextWindowMeterEnabled = false;
        diffColorScheme = "red-green";
        diffFilesCollapsed = true;
        diffIgnoreWhitespace = true;
        diffLayout = "split";
        environmentIdentificationMode = "artwork";
        followUpBehavior = "queue";
        fontFamilyCode = "";
        fontFamilyComposer = "";
        fontFamilySans = "";
        fontFamilyTerminal = "";
        fontSizeCode = 13;
        fontSizeInterface = 16;
        fontSizePrompt = 14;
        fontSizeTerminal = 12;
        fontSmoothing = true;
        glassOpacity = 80;
        inAppNotificationsEnabled = false;
        legacySidebarEnabled = false;
        loadBalancingEnabled = false;
        mathRenderingEnabled = false;
        notificationMode = "notifications";
        onboardingCompletedAt = "2026-09-10T13:09:10.785Z";
        panelAnimationDurationMs = 0;
        persistComposerContextStrip = false;
        planModeEnabled = false;
        proactivePanelsEnabled = false;
        pullRequestLinksOpenInApp = true;
        sendShortcut = "enter";
        showSkillsInSlashMenu = true;
        sidebarProjectGroupingMode = "repository";
        sidebarProjectSortOrder = "updated_at";
        sidebarThreadPreviewCount = 6;
        sidebarThreadSortOrder = "updated_at";
        sidebarWorkingShelfEnabled = false;
        snapShotAnimations = true;
        snapShotEnabled = false;
        snapShotFlash = true;
        snapShotIncludeAccessibility = true;
        snapShotPlaySound = true;
        snapShotShortcut = {
          kind = "both-shift-keys";
        };
        snapShotSound = "soft-pop";
        timestampFormat = "locale";
        wordWrap = true;
      };

      json = pkgs.formats.json { };
      installT3codeSettings = pkgs.writeShellApplication {
        name = "install-t3code-settings";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.jq
        ];
        text = ''
          userdata="$HOME/.t3/userdata"
          mkdir -p "$userdata"

          merge() {
            local path="$userdata/$1"
            local desired=$2
            local temporary_file

            temporary_file=$(mktemp "$path.XXXXXX")
            if [[ -e "$path" ]]; then
              jq -s '.[0] * .[1]' "$path" "$desired" > "$temporary_file"
            else
              cp "$desired" "$temporary_file"
            fi
            chmod 644 "$temporary_file"
            mv -f "$temporary_file" "$path"
          }

          merge settings.json ${json.generate "t3code-settings.json" settings}
          merge client-settings.json ${json.generate "t3code-client-settings.json" clientSettings}
        '';
      };

      version = "0.0.45";
      src = pkgs.fetchurl {
        url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
        hash = "sha256-q3sKhtHqZXzMFitgt3LGH3C8fIueJZtGk51Tuzj6oCo=";
      };
      t3code-unwrapped = pkgs.appimageTools.wrapType2 {
        pname = "t3code";
        inherit version src;
        extraPkgs = _: [ ];
      };
      t3code = config.lib.nixGL.wrap t3code-unwrapped;
      icon = pkgs.fetchurl {
        url = "https://media.brand.dev/64c8e868-1600-4dbb-aa50-d4654494a909.png";
        hash = "sha256-YKVruRilE0x45yTSenJ1eLcedTF2Px1/o0V0Clws0dY=";
      };
    in
    lib.mkMerge [
      {
        home.activation.installT3codeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${lib.getExe installT3codeSettings}
        '';
      }

      # The macOS app is installed from the release DMG and updates itself.
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = [ t3code ];

        home.file.".local/share/icons/hicolor/512x512/apps/t3code.png".source = icon;

        xdg.desktopEntries.t3code = {
          name = "T3 Code";
          genericName = "Code Editor";
          exec = "${t3code}/bin/t3code %U";
          icon = "t3code";
          terminal = false;
          type = "Application";
          categories = [
            "Development"
            "IDE"
            "TextEditor"
          ];
          mimeType = [
            "text/plain"
          ];
        };
      })
    ];
}
