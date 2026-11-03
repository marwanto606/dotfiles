require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "basedpyright",     -- Contoh untuk Python
}
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 


-- Mengonfigurasi tampilan pop-up Diagnostik Neovim
vim.diagnostic.config({
  virtual_text = false, -- Matikan teks samar di ujung kanan agar layar tidak penuh/berantakan
  underline = true,    -- Tetap berikan garis bawah pada kode yang eror
  update_in_insert = false,
  severity_sort = true,
  
  -- Konfigurasi Jendela Melayang (Floating Window)
  float = {
    focused = false,
    style = "minimal",
    border = "rounded", -- Memberikan bingkai melengkung yang rapi
    source = "always",  -- Menampilkan sumber eror (misal: akan tertulis [basedpyright])
    header = "",
    prefix = "",
  },
})

-- Opsional: Menampilkan jendela melayang secara OTOMATIS saat kursor diam di baris eror
-- Hapus tanda komentar (-- ) di bawah ini jika Anda ingin fitur otomatis ini aktif:
vim.api.nvim_create_autocmd("CursorHold", {
  buffer = bufnr,
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})