require "nvchad.mappings"

local map = vim.keymap.set

-------------------------------------------------------------------
-- 1. PINTASAN UMUM (VS CODE STYLE)
-------------------------------------------------------------------

-- COMMAND MODE & ESCAPE CEPAT
map("n", ";", ":", { desc = "Umum Enter command mode" })
map("i", "jk", "<ESC>", { desc = "Umum Escape insert mode" })

-- SELECT ALL (Ctrl + A)
map({ "n", "v" }, "<C-a>", "ggVG", { desc = "Umum Select all text" })
map("i", "<C-a>", "<Esc>ggVG", { desc = "Umum Select all text" })

-- SAVE FILE (Ctrl + S)
map({ "n", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "Umum Save file" })
map("i", "<C-s>", "<cmd>w<cr>", { desc = "Umum Save file" })

-- CLIPBOARD (Ctrl + C, Ctrl + X, & Ctrl + V)
map("v", "<C-c>", '"+y', { desc = "Umum Copy to system clipboard" })
map("v", "<C-x>", '"+d', { desc = "Umum Cut to system clipboard" })
map("n", "<C-x>", '"+dd', { desc = "Umum Cut line to system clipboard" })
map({ "n", "v" }, "<C-v>", '"+p', { desc = "Umum Paste from system clipboard" })
map("i", "<C-v>", '<C-r>+', { desc = "Umum Paste from system clipboard" })

-- TOGGLE COMMENT (Ctrl + /)
map("n", "<C-/>", "gcc", { remap = true, desc = "Umum Toggle comment line" })
map("v", "<C-/>", "gc", { remap = true, desc = "Umum Toggle comment selection" })

-- UNDO & REDO (Ctrl + Z & Ctrl + Y)
map({ "n", "i", "v" }, "<C-z>", "<cmd>undo<cr>", { desc = "Umum Undo change" })
map({ "n", "i", "v" }, "<C-y>", "<cmd>redo<cr>", { desc = "Umum Redo change" })

map("n", "ZQ", "<cmd>q!<cr>", { desc = "Umum Force quit window (ZQ)" })
map("n", "ZZ", "<cmd>wq<cr>", { desc = "Umum Save and quit window (ZZ)" })

-------------------------------------------------------------------
-- 2. EDITING & MANIPULASI TEKS (VS CODE STYLE)
-------------------------------------------------------------------

-- GESER BARIS KE ATAS / BAWAH (Alt + j/k)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Edit Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Edit Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Edit Move selected lines down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Edit Move selected lines up" })
map("i", "<A-j>", "<Esc><cmd>m .+1<cr>==gi", { desc = "Edit Move line down" })
map("i", "<A-k>", "<Esc><cmd>m .-2<cr>==gi", { desc = "Edit Move line up" })

-- DUPLIKASI BARIS (Alt + Shift + j) - Seperti Shift+Alt+Down di VS Code
map("n", "<A-J>", "<cmd>t.<cr>", { desc = "Edit Duplicate line down" })
map("v", "<A-J>", ":t'><cr>gv=gv", { desc = "Edit Duplicate selected lines" })

-- INDENTASI BERTAHAN DI VISUAL MODE (Tekan < atau > berulang kali tanpa lepas blok)
map("v", "<", "<gv", { desc = "Edit Indent left (keep selection)" })
map("v", ">", ">gv", { desc = "Edit Indent right (keep selection)" })

-------------------------------------------------------------------
-- SELEKSI TEKS DENGAN SHIFT + PANAH (VS CODE STYLE)
-------------------------------------------------------------------

-- Fungsi cerdas: Otomatis mendeteksi mode saat ini (Normal, Insert, atau Visual)
local function select_dir(key)
  local m = vim.api.nvim_get_mode().mode:sub(1, 1)
  if m == "i" then
    return "<Esc>v" .. key -- Jika di Insert, keluar dulu lalu mulai visual
  elseif m == "v" or m == "V" or m == "\22" then
    return key             -- Jika sudah di Visual, lanjutkan perluasan seleksi
  else
    return "v" .. key      -- Jika di Normal, langsung masuk mode visual
  end
end

-- Mappings 1 baris untuk semua mode (Normal, Insert, & Visual)
map({ "n", "i", "v" }, "<S-Up>", function() return select_dir "<Up>" end, { expr = true, desc = "Seleksi Blok baris ke atas" })
map({ "n", "i", "v" }, "<S-Down>", function() return select_dir "<Down>" end, { expr = true, desc = "Seleksi Blok baris ke bawah" })
map({ "n", "i", "v" }, "<S-Left>", function() return select_dir "<Left>" end, { expr = true, desc = "Seleksi Karakter ke kiri" })
map({ "n", "i", "v" }, "<S-Right>", function() return select_dir "<Right>" end, { expr = true, desc = "Seleksi Karakter ke kanan" })

-- Hapus blok teks yang terseleksi ala VS Code (hanya saat ada teks terseleksi)
map("v", "<BS>", '"_d', { desc = "Seleksi Hapus blok (Backspace)" })

-------------------------------------------------------------------
-- 3. TERMINAL NVCHAD
-------------------------------------------------------------------

-- Fungsi toggle terminal horizontal
local toggle_horizontal_term = function()
  require("nvchad.term").toggle { pos = "sp", id = "horizontalTerm" }
end

-- TOGGLE TERMINAL HORIZONTAL (Ctrl + \ & Space + h)
map({ "n", "t" }, "<leader>h", toggle_horizontal_term, { desc = "Terminal Toggle Horizontal" })
map({ "n", "t" }, "<C-\\>", toggle_horizontal_term, { desc = "Terminal Toggle Horizontal" })

-- TOGGLE TERMINAL FLOATING / MELAYANG (Space + t)
map({ "n", "t" }, "<leader>pt", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Terminal Toggle Floating" })

-- KELUAR MODE KETIK TERMINAL KE NORMAL MODE (Esc 2x berturut-turut)
-- Menghindari terminal tertutup tiba-tiba saat menjalankan perintah interaktif
map("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Terminal Enter normal mode" })

-- TUTUP TERMINAL SECARA PERMANEN / KILL (Ctrl + Q di dalam terminal)
map("t", "<C-q>", "<C-\\><C-n>:bd!<CR>", { desc = "Terminal Close Permanently" })

-- BUKA MENU POP-UP DENGAN KLIK KANAN MOUSE
map("n", "<RightMouse>", function()
  vim.cmd.exec '"normal! \\<RightMouse>"'

  -- Jika kursor berada di NvimTree, buka menu manajemen file (New, Delete, Rename)
  -- Jika di editor biasa, buka menu teks umum
  local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
  require("menu").open(options, { mouse = true })
end, { desc = "Umum Context Menu (Right Click)" })

-- BUAT TAB / FILE BARU (Ctrl + T ala browser atau Space + b)
map("n", "<C-t>", "<cmd>enew<cr>", { desc = "Umum Buat tab/file baru" })
map("n", "<leader>b", "<cmd>enew<cr>", { desc = "Umum Buat tab/file baru" })

-------------------------------------------------------------------
-- KUMPULAN SHORTCUT PALING SERING DIPAKAI (NVCHAD + NVIM)
-------------------------------------------------------------------

-- KATEGORI 1: NAVIGASI CEPAT (GERAK TANPA MOUSE)
map("n", "w", "w", { remap = false, desc = "Navigasi Lompat 1 kata ke depan" })
map("n", "b", "b", { remap = false, desc = "Navigasi Lompat 1 kata ke belakang" })
map("n", "0", "0", { remap = false, desc = "Navigasi Lompat ke paling awal baris" })
map("n", "$", "$", { remap = false, desc = "Navigasi Lompat ke paling akhir baris" })
map("n", "gg", "gg", { remap = false, desc = "Navigasi Lompat ke baris paling pertama file" })
map("n", "G", "G", { remap = false, desc = "Navigasi Lompat ke baris paling terakhir file" })
map("n", "%", "%", { remap = false, desc = "Navigasi Lompat ke pasangan kurung () / {}" })

-- KATEGORI 2: EDITING DASAR (MAGIC KEYS)
map("n", "o", "o", { remap = false, desc = "Edit Buat baris baru di bawah & langsung ketik" })
map("n", "O", "O", { remap = false, desc = "Edit Buat baris baru di atas & langsung ketik" })
map("n", "dd", "dd", { remap = false, desc = "Edit Hapus/Cut 1 baris penuh" })
map("n", "yy", "yy", { remap = false, desc = "Edit Salin/Copy 1 baris penuh" })
map("n", "p", "p", { remap = false, desc = "Edit Tempel/Paste setelah kursor" })
map("n", "x", "x", { remap = false, desc = "Edit Hapus 1 karakter (ala tombol Delete)" })

-- KATEGORI 3: TRIK EDIT KATA & KURUNG (SUPER BERGUNA UNTUK CODING)
map("n", "ciw", "ciw", { remap = false, desc = "Trik Ganti kata di kursor saat ini (Change inner word)" })
map("n", "diw", "diw", { remap = false, desc = "Trik Hapus kata di kursor saat ini (Delete inner word)" })
map('n', 'ci"', 'ci"', { remap = false, desc = 'Trik Ganti isi dalam tanda kutip ("")' })
map("n", "ci(", "ci(", { remap = false, desc = "Trik Ganti isi dalam tanda kurung ()" })

-- KATEGORI 4: FITUR UTAMA BAWAAN NVCHAD (DIDAFTARKAN ULANG UNTUK MEMPERJELAS CHEATSHEET)
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "NvChad Buka/Tutup Sidebar File Explorer" })
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "NvChad Cari file di proyek (Find File)" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "NvChad Cari teks/kata di seluruh file proyek" })
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "NvChad Tutup Tab/Buffer aktif saat ini" })
map("n", "<leader>/", "gcc", { remap = true, desc = "NvChad Komentar (Comment/Uncomment baris)" })