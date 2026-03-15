local M = {}

local DEBUG =  false

local function log(msg)
  if DEBUG then
    print("[sidebars] " .. msg)
  end
end

-------------------------------------------------
-- НАСТРОЙКИ
--------------------------------------------------

-- ВСЕ сайдбары (временные окна)
-- всё, что здесь — автозакрывается при уходе в код
M.sidebars = {
  ["neo-tree"] = true,
  dbui = true,
  aerial = true,
  trouble = true,
}

-- filetype'ы, которые считаются "рабочими"
-- при переходе в них сайдбары закрываются
M.main_filetypes = {
  lua = true,
  python = true,
  javascript = true,
  typescript = true,
  rust = true,
  go = true,
  php = true,
  c = true,
  cpp = true,
  markdown = true,
  toml = true,
  yml = true,
  html = true,
  text = true,
  sh = true
}

--------------------------------------------------
-- ВНУТРЕННЕЕ СОСТОЯНИЕ
--------------------------------------------------

-- текущее открытое сайдбар-окно
M._sidebar_win = nil

--------------------------------------------------
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
--------------------------------------------------

local function is_sidebar(ft)
  return M.sidebars[ft] == true
end

local function is_main_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  local bt = vim.bo[buf].buftype
  if bt ~= "" then
    return false
  end

  if not vim.bo[buf].buflisted then
    return false
  end

  local ft = vim.bo[buf].filetype
  if M.sidebars[ft] then
    return false
  end

  return true
end

--------------------------------------------------
-- ОСНОВНАЯ ЛОГИКА
--------------------------------------------------

-- запоминаем сайдбар при входе в него
function M.track_sidebar(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.bo[buf].filetype

  if is_sidebar(ft) then
    log("Track sidebar: ft=" .. ft .. " win=" .. win)
    M._sidebar_win = win
  end
end

-- закрываем сайдбар при уходе в основной буфер
function M.maybe_close_sidebar(new_win)
  local sidebar_win = M._sidebar_win
  if not sidebar_win then return end
  if not vim.api.nvim_win_is_valid(sidebar_win) then
    log("No active sidebar")
    M._sidebar_win = nil
    return
  end

  -- если всё ещё в сайдбаре — ничего не делаем
  if new_win == sidebar_win then
    log("Still in sidebar")
    return
  end

  local buf = vim.api.nvim_win_get_buf(new_win)
  local ft = vim.bo[buf].filetype

  log("Focus moved to ft=" .. ft)

  if is_main_buffer(buf) then
    log("Closing sidebar win=" .. M._sidebar_win)
    pcall(vim.api.nvim_win_close, sidebar_win, true)
    M._sidebar_win = nil
  end
end

--------------------------------------------------
-- AUTOCMD
--------------------------------------------------

vim.api.nvim_create_autocmd("WinNew", {
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype

    if M.sidebars[ft] then
      log("WinNew → track sidebar ft=" .. ft .. " win=" .. win)
      M._sidebar_win = win
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype

    log("WinEnter → win=" .. win .. " ft=" .. ft .. " bt=" .. bt)

    log("Is sidebar " .. tostring(M.sidebars[ft]))

    log("Is is_main_buffer " .. tostring(is_main_buffer(buf)))

    log("Sidebar " .. tostring(M._sidebar_win))

    if M.sidebars[ft] then
      log("Track sidebar ft=" .. ft .. " win=" .. win)
      M._sidebar_win = win
    elseif is_main_buffer(buf) then
      if M._sidebar_win then
        log("Closing sidebar win=" .. M._sidebar_win)
        pcall(vim.api.nvim_win_close, M._sidebar_win, true)
        M._sidebar_win = nil
      end
    end
  end,
})
-- vim.api.nvim_create_autocmd( "BufEnter", {
--   callback = function()
--     local win = vim.api.nvim_get_current_win()
--     local buf = vim.api.nvim_get_current_buf()
--     local ft = vim.bo[buf].filetype
--
--     log("WinEnter → win=" .. win .. " ft=" .. ft)
--
--     M.track_sidebar(win)
--     M.maybe_close_sidebar(win)
--   end,
-- })
--
return M

