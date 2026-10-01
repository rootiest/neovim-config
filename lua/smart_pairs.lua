-- Context-aware auto-pairing on top of mini.pairs.
--
-- mini.pairs only looks at one character on each side of the cursor, so it
-- inserts a closing character even when you're going back to wrap existing
-- text. This module puts a gate in front of the opener keys: a pair is only
-- inserted when nothing but whitespace (or a closing bracket, i.e. we're nested
-- inside another pair) follows the cursor. Otherwise the plain character is
-- typed. Closers, <BS> and <CR> are still handled by mini.pairs.
--
-- In Markdown, a 3rd backtick (or tilde) on an otherwise blank line expands
-- into a fenced code block, but only when the cursor isn't already inside a
-- fence and the next line is blank (or the buffer ends there). Typing more of
-- the same character lengthens both fences together, and <BS> shrinks them.
-- Inside a block, fences pair as nested examples (```` around ```), and a pair
-- that grows long enough to close the enclosing block collapses into its closer.

local M = {}

local PAIRS = { ["("] = "()", ["["] = "[]", ["{"] = "{}", ['"'] = '""', ["'"] = "''", ["`"] = "``" }

-- Never-matching mini.pairs neighborhood pattern: makes MiniPairs.open() type
-- just the opening character.
local NO_PAIR = "^$"

local function is_disabled()
  return vim.g.minipairs_disable == true or vim.b.minipairs_disable == true
end

local function should_pair(pair, before, after)
  local open = pair:sub(1, 1)
  if before == "\\" then
    return false
  end
  if not (after:match("^%s*$") or after:match("^[%)%]}]")) then
    return false
  end
  -- Quotes: don't pair when closing a word (`don't`, `foo"`) or extending a
  -- run of the same quote (`""` -> `"""`).
  if open == pair:sub(2, 2) and (before:match("%w") or before == open) then
    return false
  end
  return true
end

-- Keys to type for an opener key, honoring the context gate.
local function open_keys(pair)
  local col = vim.fn.col(".") - 1
  local line = vim.api.nvim_get_current_line()
  local before, after = line:sub(col, col), line:sub(col + 1)
  local pattern = should_pair(pair, before, after) and ".." or NO_PAIR
  if pair:sub(1, 1) == pair:sub(2, 2) then
    -- Still steps over a matching quote right after the cursor.
    return MiniPairs.closeopen(pair, pattern)
  end
  return MiniPairs.open(pair, pattern)
end

-- Parse a fence line: returns its character, run length and whether the run
-- is bare (could close a block), or nil if `line` isn't a fence. Backtick
-- fences can't have backticks in their info string (that's inline code).
local function parse_fence(line)
  local run, info = line:match("^%s*(```+)(.*)$")
  if not run or info:find("`", 1, true) then
    run, info = line:match("^%s*(~~~+)(.*)$")
  end
  if run then
    return run:sub(1, 1), #run, not info:match("%S")
  end
end

-- Whether a fence line (`char`, `len`, `bare`) closes the open fence `f`.
local function closes(f, char, len, bare)
  return bare and char == f.char and len >= f.len
end

-- Whether a fence line closes the enclosing block or the innermost nested one.
local function closes_any(stack, char, len, bare)
  return (stack[1] and closes(stack[1], char, len, bare)) or (#stack > 1 and closes(stack[#stack], char, len, bare))
end

-- Fences open at `row` (1-based), outermost first. stack[1] is the real
-- Markdown block: only a long-enough bare fence closes it (and everything in
-- it). Fence lines inside it are plain text to Markdown, but we treat them as
-- nested examples: each closes the innermost nested fence or opens a new one.
local function fence_stack(row)
  local stack = {}
  for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, row - 1, false)) do
    local char, len, bare = parse_fence(l)
    if char then
      if stack[1] and closes(stack[1], char, len, bare) then
        stack = {}
      elseif #stack > 1 and closes(stack[#stack], char, len, bare) then
        table.remove(stack)
      else
        table.insert(stack, { char = char, len = len })
      end
    end
  end
  return stack
end

-- Whether a new fence pair may be opened above `next_line`: it must be blank,
-- the end of the buffer, or the closer of a block we're inside.
local function room_below(stack, next_line)
  if next_line == nil or next_line:match("^%s*$") then
    return true
  end
  local char, len, bare = parse_fence(next_line)
  return char ~= nil and closes_any(stack, char, len, bare)
end

-- The current line as indent + a run of one fence character ending at the
-- cursor, or nil if it's anything else.
local function fence_run(line, col)
  local indent, run = line:sub(1, col):match("^(%s*)([`~]+)$")
  if run and run == run:sub(1, 1):rep(#run) then
    return indent, run
  end
end

-- Fence key for `ch` ("`" or "~"). The 3rd `ch` on a blank line opens a fence
-- pair; each further `ch` lengthens both fences while the closer is untouched,
-- until the run would close the enclosing block, at which point the pair
-- collapses into that closer. Anything else types `fallback()`.
local function fence_key(ch, fallback)
  return function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local indent, run = fence_run(line, col)
    local next_line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]

    if not is_disabled() and indent and run:sub(1, 1) == ch then
      local fence = indent .. run .. ch
      local opening = #run == 2 and line:sub(col + 1):match("^%s*$")
      local twin = #run >= 3 and col == #line and next_line == line
      local new_lines, replace_to
      if opening or twin then
        local stack = fence_stack(row)
        local closing = closes_any(stack, ch, #run + 1, true)
        if opening and not closing and room_below(stack, next_line) then
          new_lines, replace_to = { fence, fence }, row
        elseif twin and not closes_any(stack, ch, #run, true) then
          new_lines, replace_to = closing and { fence } or { fence, fence }, row + 1
        end
      end
      if new_lines then
        vim.api.nvim_buf_set_lines(0, row - 1, replace_to, false, new_lines)
        vim.api.nvim_win_set_cursor(0, { row, #fence })
        return
      end
    end

    vim.api.nvim_feedkeys(fallback(), "in", false)
  end
end

local function attach_markdown(buf)
  vim.keymap.set("i", "`", fence_key("`", function()
    return open_keys("``")
  end), { buffer = buf, desc = "Smart Markdown backtick / code fence" })

  vim.keymap.set("i", "~", fence_key("~", function()
    return "~"
  end), { buffer = buf, desc = "Smart Markdown tilde code fence" })

  -- Backspacing a fence whose closer is still untouched shrinks both fences
  -- together; once the opener drops below 3 characters the closer goes away.
  vim.keymap.set("i", "<BS>", function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local indent, run = fence_run(line, col)
    local next_line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]

    if
      not is_disabled()
      and indent
      and #run >= 3
      and col == #line
      and next_line == line
      and not closes_any(fence_stack(row), run:sub(1, 1), #run, true)
    then
      local fence = line:sub(1, -2)
      vim.api.nvim_buf_set_lines(0, row - 1, row + 1, false, #run > 3 and { fence, fence } or { fence })
      vim.api.nvim_win_set_cursor(0, { row, #fence })
      return
    end

    vim.api.nvim_feedkeys(MiniPairs.bs(), "in", false)
  end, { buffer = buf, desc = "Smart Markdown fence backspace" })
end

function M.setup()
  for key, pair in pairs(PAIRS) do
    vim.keymap.set("i", key, function()
      return open_keys(pair)
    end, { expr = true, replace_keycodes = false, desc = "Smart pair " .. pair })
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("markdown_smart_backtick", { clear = true }),
    pattern = "markdown",
    desc = "Smart Markdown code fences (``` and ~~~)",
    callback = function(args)
      attach_markdown(args.buf)
    end,
  })

  -- Catch buffers that already had their FileType event fire before this
  -- deferred setup ran (e.g. `nvim file.md` opened directly at startup).
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == "markdown" then
      attach_markdown(buf)
    end
  end
end

return M
