local M = {}

local highlights = {
  -- Group bawaan Neovim untuk base statusline
  StatusLine      = { bg = "NONE" },
  StatusLineNC    = { bg = "NONE" },

  -- Separator luar (lengkungan  dan )
  -- fg = warna isi bubble (#171b24), bg = NONE agar tembus ke luar
  Separator       = { fg = "#171b24",     bg = "NONE" },

  -- Elemen di dalam bubble tetap memiliki background #171b24
  Separator2      = { fg = "#3a435a",     bg = "#171b24" },
  ModeText        = { fg = "#956dca",     bg = "#171b24" },
  PathText        = { fg = "#956dca",     bg = "#171b24" },
  FileText        = { fg = "#f4f3ee",     bg = "#171b24" },
  FileType        = { fg = "#e37e4f",     bg = "#171b24" },
  BranchName      = { fg = "#69bfce",     bg = "#171b24" },
  LineText        = { fg = "#e34f4f",     bg = "#171b24" },
  ColumnText      = { fg = "#5679e3",     bg = "#171b24" },
  PercentageText  = { fg = "#5599e2",     bg = "#171b24" },
  TotalLineText   = { fg = "#956dca",     bg = "#171b24" },

  -- Diagnostics (berada di luar bubble, jadi bg dibuat NONE)
  DiagError       = { fg = "#e06c75",     bg = "#171b24" },
  DiagWarn        = { fg = "#e5c07b",     bg = "#171b24" },
  DiagInfo        = { fg = "#61afef",     bg = "#171b24" },
  DiagHint        = { fg = "#98c379",     bg = "#171b24" },
  DiagnosticsText = { fg = "#98c379",     bg = "#171b24" },
}

for group, opts in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, opts)
end

-- Tabel pemetaan mode ke Highlight Group bawaan NvChad dan Icon yang unik
local mode_info = {
  ["n"]    = { hl = "St_NormalMode",   icon = " " }, -- Normal (Rumah / Normal)
  ["no"]   = { hl = "St_NormalMode",   icon = " " },
  ["i"]    = { hl = "St_InsertMode",   icon = " " }, -- Insert (Pensil / Tulis)
  ["ic"]   = { hl = "St_InsertMode",   icon = " " },
  ["v"]    = { hl = "St_VisualMode",   icon = "󰕢 " }, -- Visual (Seleksi kursor)
  ["V"]    = { hl = "St_VisualMode",   icon = "󰒅 " }, -- Visual Line
  ["\22"]  = { hl = "St_VisualMode",   icon = " " }, -- Visual Block (Ctrl-V)
  ["R"]    = { hl = "St_ReplaceMode",  icon = "󰛔 " }, -- Replace (Timpa teks)
  ["c"]    = { hl = "St_CommandMode",  icon = "󰘳 " }, -- Command (: command prompt)
  ["t"]    = { hl = "St_TerminalMode", icon = " " }, -- Terminal
}

-- Fallback jika mode tidak ada di daftar
local default_info = { hl = "St_NormalMode", icon = " " }

_G.RecolorMode = function()
  local mode = vim.api.nvim_get_mode().mode
  local current = mode_info[mode] or default_info

  -- Ambil warna dari grup highlight bawaan NvChad
  local hl = vim.api.nvim_get_hl(0, { name = current.hl, link = false })
  -- NvChad umumnya meletakkan warna aksen mode di properti 'bg' (atau 'fg')
  local color_val = hl.bg or hl.fg

  if color_val then
    vim.api.nvim_set_hl(0, "ModeText", {
      fg = string.format("#%06x", color_val),
      bg = "#171b24",
    })
  end

  return ""
end

_G.GetModeIcon = function()
  local mode = vim.api.nvim_get_mode().mode
  local current = mode_info[mode] or default_info
  return current.icon
end

_G.GetFileIcon = function()
  -- Cek apakah nvim-web-devicons terpasang
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return "󰈔" -- Icon default jika plugin tidak ditemukan
  end

  local fname = vim.fn.expand("%:t")
  local ext = vim.fn.expand("%:e")
  local ft = vim.bo.filetype

  -- 1. Cari icon berdasarkan nama file & ekstensi (contoh: Dockerfile, .lua, dll)
  local icon = devicons.get_icon(fname, ext, { default = false })

  -- 2. Jika tidak ketemu, cari berdasarkan filetype buffer
  if not icon and ft ~= "" then
    icon = devicons.get_icon_by_filetype(ft, { default = false })
  end

  -- Kembalikan icon yang ditemukan, atau icon fallback jika file tidak dikenal
  return (icon and icon ~= "") and icon or "󰈔"
end

_G.GetBranchName = function()
  -- 1. Ambil bufnr dari window yang sedang dirender oleh statusline
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)

  -- 2. Cek apakah gitsigns sudah mendeteksi branch di buffer ini
  local gitsigns_head = vim.b[bufnr].gitsigns_head
  if gitsigns_head and gitsigns_head ~= "" then
    return gitsigns_head
  end

  local gs_dict = vim.b[bufnr].gitsigns_status_dict
  if gs_dict and gs_dict.head and gs_dict.head ~= "" then
    return gs_dict.head
  end

  -- Cek variable global gitsigns jika buffer belum ter-attach
  if vim.g.gitsigns_head and vim.g.gitsigns_head ~= "" then
    return vim.g.gitsigns_head
  end

  -- 3. Fallback: Jika gitsigns belum aktif (misal buffer kosong), cek git lewat CLI
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end

  if vim.fn.finddir(".git", dir .. ";") ~= "" then
    local handle = io.popen("git -C " .. vim.fn.shellescape(dir) .. " branch --show-current 2>/dev/null")
    local result = handle and handle:read("*a") or ""
    if handle then handle:close() end

    result = vim.trim(result)
    if result ~= "" then
      return result
    end
  end

  return "no-git"
end

_G.HandleColumnGap = function()
  local col = vim.fn.col(".")
  return col > 9 and "✖ " or "✖"
end

_G.diagnostics_color = function()
  if not rawget(vim, "lsp") then
    return "%#DiagnosticsText# %*"
  end

  -- Mendapatkan bufnr window yang sedang dirender statusline-nya
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)

  local err = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
  local warn = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
  local info = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO })
  local hints = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT })

  local parts = {}
  if err > 0 then
    table.insert(parts, "%#DiagError# " .. err .. " %*")
  end
  if warn > 0 then
    table.insert(parts, "%#DiagWarn# " .. warn .. " %*")
  end
  if info > 0 then
    table.insert(parts, "%#DiagInfo#󰋼 " .. info .. " %*")
  end
  if hints > 0 then
    table.insert(parts, "%#DiagHint#󰛩 " .. hints .. " %*")
  end

  if #parts == 0 then
    return "%#DiagnosticsText# %*"
  else
    return table.concat(parts, "")
  end
end

-- Buat fungsi yang me-return string statusline kamu:
M.run = function()
  return table.concat({
  "%{%v:lua.RecolorMode()%}",

  "%#Separator#",
  "%#ModeText#%{v:lua.GetModeIcon()}",
  "%#Separator#█",

  "%#PathText#%{expand('%:p:h:t')}",
  "%#Separator#██",
  "%#FileText#%t",
  "%#Separator#",

  "%=",

  "%#Separator#",
  "%#FileType#%{v:lua.GetFileIcon()} ",
  "%#Separator#█",
  "%{%v:lua.diagnostics_color()%}",
  "%#Separator#",

  "%#Separator# ",
  "%#BranchName#%{v:lua.GetBranchName()}",
  "%#Separator# ",

  "%#Separator#",
  "%#LineText#%2l",
  "%#Separator#█",
  "%#Separator2#%{v:lua.HandleColumnGap()}",
  "%#ColumnText#%2c",

  "%#Separator2#",
  "%#Separator#██",
  "%#PercentageText#%p%%",
  "%#Separator#█",
  "%#Separator2# ",
  "%#TotalLineText#%L",
  "%#Separator#",
  
})
end

return M