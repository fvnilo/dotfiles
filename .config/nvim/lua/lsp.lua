local ft_lsp = {
  go = "gopls",
  rust = "rust_analyzer",
  terraform = "terraformls"
}

local lsp_flags = {
  debounce_text_changes = 150,
}

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<C-f>', function() vim.lsp.buf.format { async = true } end, opts)
  vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', function() require 'telescope.builtin'.lsp_references { show_line = false } end, opts)
  vim.keymap.set('n', 'gi', function() require 'telescope.builtin'.lsp_implementations { show_line = false } end, opts)
  vim.keymap.set('n', 'gd', function() require 'telescope.builtin'.lsp_definitions { show_line = false } end, opts)
end

local M = {}

M.ftypes = function()
  local ftypes = {}
  for k, _ in pairs(ft_lsp) do
    table.insert(ftypes, k)
  end
  return ftypes
end

M.setup = function()
  local lc = require 'lspconfig'
  require 'neodev'.setup()
  for _, v in pairs(ft_lsp) do
    lc[v].setup {
      flags = lsp_flags,
      on_attach = on_attach,
    }
  end
  lc.lua_ls.setup {
    flags = lsp_flags,
    on_attach = on_attach,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {'vim'},
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  }
end

return M
