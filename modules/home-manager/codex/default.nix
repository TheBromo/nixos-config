{ self, ... }:
{
  flake.homeModules.codex =
    { pkgs, lib, ... }:
    let
      configFile = builtins.toFile "codex-config.toml" ''
        model = "gpt-5.6-sol"
        model_reasoning_effort = "medium"
        approval_policy = "never"
        sandbox_mode = "danger-full-access"

        tool_output_token_limit = 25000
        # Leave room for native compaction near the 272–273k context window.
        # Formula: 273000 - (tool_output_token_limit + 15000)
        # With tool_output_token_limit=25000 ⇒ 273000 - (25000 + 15000) = 233000
        model_auto_compact_token_limit = 233000

        [features]
        ghost_commit = false
        hooks = true
        unified_exec = true
        plugins = true
        # apply_patch_freeform = true
        skills = true
        shell_snapshot = true

        [marketplaces.caveman-repo]
        last_updated = "2026-04-24T14:28:50Z"
        last_revision = "84cc3c14fa1e10182adaced856e003406ccd250d"
        source_type = "git"
        source = "https://github.com/JuliusBrussee/caveman.git"

        [marketplaces.openai-bundled]
        last_updated = "2026-04-24T14:32:32Z"
        source_type = "local"
        source = "/Users/manuel/.codex/.tmp/bundled-marketplaces/openai-bundled"

        [projects."/home/strenge/Development"]
        trust_level = "trusted"
        [projects."/home/strenge/.config/nvim"]
        trust_level = "trusted"
        [projects."/Users/manuel/Development"]
        trust_level = "trusted"

        [projects."/Users/manuel/Development/nixos-config"]
        trust_level = "trusted"

        [projects."/Users/manuel/Development/caveman"]
        trust_level = "trusted"

        [hooks.state]

        [hooks.state."/home/strenge/.codex/hooks.json:session_start:0:0"]
        trusted_hash = "sha256:bcf9397a6a66095da2fd157b8bf4949f51db7169f205a9b854c1fa9e27efcf92"

        [hooks.state."/Users/manuel/.codex/hooks.json:session_start:0:0"]
        trusted_hash = "sha256:eddb0845a0762a0214ac8b2039f6636d3ced0654966a4586511e031cf1278509"

        [mcp_servers.swiss_caselaw]
        enabled = true
        url = "https://mcp.opencaselaw.ch/sse"

        [plugins."caveman@caveman-repo"]
        enabled = true

        [plugins."browser-use@openai-bundled"]
        enabled = true
      '';
    in
    {
      home.activation.installCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        install -D -m 644 ${configFile} "$HOME/.codex/config.toml"
      '';

      home.activation.installCodexSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.codex/skills"
        cp -rf --no-preserve=mode ${self.lib.mattpocockSkills pkgs}/. "$HOME/.codex/skills/"
        cp -rf --no-preserve=mode ${self.lib.dotagentsSkills pkgs}/. "$HOME/.codex/skills/"
      '';
    };
}
