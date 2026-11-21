-- Cozy: Neovim brings its own matugen-generated colorscheme.
-- The palette is written to ~/.config/nvim/colors/matugen.vim by matugen.

vim.opt.termguicolors = true

-- Fall back to the built-in scheme if matugen has not generated the palette yet.
if not pcall(vim.cmd.colorscheme, "matugen") then
  vim.cmd.colorscheme("default")
end

-- Re-apply the scheme when matugen regenerates it (post_hook sends SIGUSR1).
vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  command = "lua pcall(vim.cmd.colorscheme, 'matugen')",
})
