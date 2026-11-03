return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- The current configuration uses the stable, configs-compatible API.
    -- Do not follow the rewritten `main` branch without migrating this file.
    branch = "master",
    main = "nvim-treesitter.configs",
    opts = {
      auto_install = true,
      -- Parse trees are installed in Neovim's data directory so nvim-treesitter
      -- and Neovim resolve the same parser files.
      parser_install_dir = vim.fn.stdpath("data") .. "/site",
      ensure_installed = { "c", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    },
    opts_extend = { "ensure_installed" },
  },
}
