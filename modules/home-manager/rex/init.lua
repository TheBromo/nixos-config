local terminal = "com.superlogical.terminal"

local function nvim_is_focused(ctx)
  local process = rex.block.call(terminal, "process", { block_id = ctx.block_id })
  local foreground = process and process.foreground
  return foreground ~= nil and foreground.name == "nvim"
end

-- Inside Neovim the key reaches Neovim, so it keeps moving between its own
-- windows. Everywhere else it moves focus to the neighbouring Rex pane.
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function(ctx)
    if nvim_is_focused(ctx) then
      return false
    end
    rex.session.focus_direction({ direction = direction })
    return true
  end)
end
