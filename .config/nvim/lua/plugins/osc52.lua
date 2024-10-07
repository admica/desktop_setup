-- ~/.config/nvim/lua/plugins/osc52.lua
return {
  "ojroques/nvim-osc52",
  config = function()
    require('osc52').setup {
      max_length = 0, -- Maximum length of selection (0 for no limit)
      silent = false, -- Disable message on successful copy
      trim = false,   -- Trim surrounding whitespaces before copy
    }
    local function copy(lines, _)
      require('osc52').copy(table.concat(lines, '\n'))
    end
    local function paste()
      return {vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('')}
    end
    vim.g.clipboard = {
      name = 'osc52',
      copy = {['+'] = copy, ['*'] = copy},
      paste = {['+'] = paste, ['*'] = paste},
    }
    -- Use unnamedplus as the default register
    vim.opt.clipboard = "unnamedplus"

    -- Enable mouse support
    vim.opt.mouse = 'a'

    -- Enable middle-click paste
    vim.cmd([[
      noremap <silent> <MouseMiddle> "+p
      inoremap <silent> <MouseMiddle> <C-r>+
    ]])

    -- Auto-copy visual selection
    vim.api.nvim_create_autocmd({"TextYankPost"}, {
      callback = function()
        if vim.v.event.operator == 'y' and vim.v.event.regname == '+' then
          require('osc52').copy_register('+')
        end
      end,
    })
  end
}
