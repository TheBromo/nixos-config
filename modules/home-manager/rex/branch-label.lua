-- Labels each session after the directory its terminals are in: the git
-- branch inside ~/Development/Worktrees, the folder name everywhere else.
-- Run with `rex do branch-label.lua --all` so it hears every session.
local git = "@git@"
local worktrees = os.getenv("HOME") .. "/Development/Worktrees/"
local labels = {}

local function branch_of(dir)
  local r = rex.exec({ git, "branch", "--show-current" }, { cwd = dir, timeout = 2 })
  return r and r.code == 0 and r.stdout:gsub("%s+$", "") or ""
end

local function label_session(session_id, dir)
  if not dir or dir == "" then
    return
  end
  dir = dir:gsub("/+$", "")
  local label = ""
  if (dir .. "/"):sub(1, #worktrees) == worktrees then
    label = branch_of(dir)
  end
  -- A detached HEAD in a worktree falls back to the folder name too.
  if label == "" then
    label = dir:match("([^/]+)$") or "/"
  end
  if labels[session_id] == label then
    return
  end
  local _, err = rex.session.set_label({ session_id = session_id, label = label })
  if not err then
    labels[session_id] = label
  end
end

-- pwd is a URL such as file://host/Users/me/src%20dir.
local function url_path(url)
  local path = url:gsub("^file://[^/]*", "")
  return (path:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

rex.on("terminal.pwd_changed", function(ctx, ev)
  label_session(ctx.session_id, url_path(ev.pwd))
end)

-- Catches `git switch` and friends, which change the branch but not the
-- directory: the foreground process changes when the command starts and ends.
rex.on("terminal.process_changed", function(ctx, ev)
  label_session(ctx.session_id, ev.foreground and ev.foreground.cwd)
end)

rex.on("session_destroyed", function(_, ev)
  labels[ev.session_id] = nil
end)
