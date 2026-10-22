# The stub skill that `rex skill setup` writes. It only points the agent at
# `rex __internal skill`, so the guide always matches the installed Rex CLI.
{ ... }:
{
  flake.lib.rexSkill =
    pkgs:
    pkgs.writeTextDir "rex/SKILL.md" ''
      ---
      name: rex
      description: Use the rex CLI to manage Rex sessions, open tabs, arrange panes, run commands, inspect terminal output, and control connected Rex apps.
      metadata:
        rex-stub: "2"
      ---

      Run `rex __internal skill` and follow the guide it prints. The guide comes from
      the installed Rex CLI, so it describes the commands available in that version.

      If the command fails, the installed Rex version predates the guide. Start with
      `rex whoami --json`, then use `rex --help` and `rex COMMAND --help`.
    '';
}
