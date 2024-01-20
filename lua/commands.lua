-- auto save current buffer
local augroup = vim.api.nvim_create_augroup("user_commands", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    group = augroup,
    pattern = "*",
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local is_modifiable = function()
            return vim.fn.getbufvar(buf, "&modifiable") == 1
        end
        if is_modifiable() then
            vim.api.nvim_buf_call(buf, function()
                vim.cmd("silent! write")
            end)
            local bufname = vim.api.nvim_buf_get_name(buf)
            local msg = ("buffer %%%d: %s automatically saved at %s."):format(buf, bufname, vim.fn.strftime("%H:%M:%S"))
            vim.notify(msg, vim.log.levels.INFO)
        end
    end,
})
