return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  { "nvchad/showkeys", cmd = "ShowkeysToggle", opts = { position = "top-center" } },
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.chunk"
    end
  },
  { "nvzone/volt",     lazy = true },
  { "nvzone/menu",     lazy = true },
  {
    "nvzone/floaterm",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = "FloatermToggle",
  },

  {
    "OXY2DEV/markview.nvim",
    lazy = false,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = {
        adaptive_size = true, -- sidebar otomatis melebar mengikuti panjang nama folder
      },
      renderer = {
        indent_markers = {
          enable = true, -- pastikan garis penunjuk folder aktif
        },
        icons = {
          padding = " ", -- beri ruang spasi agar ikon tidak menempel ke teks folder
        },
      },
    },
  },
}
