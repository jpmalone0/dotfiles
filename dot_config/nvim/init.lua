vim.opt.clipboard = 'unnamedplus'

-- Auto-reload files when changed externally
vim.o.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  command = 'checktime',
})
