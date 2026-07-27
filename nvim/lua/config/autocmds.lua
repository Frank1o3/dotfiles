local idle_time = 2 * 1000
local timers = {}

local function stop_timer(bufnr)
    local timer = timers[bufnr]

    if timer then
        timer:stop()
        timer:close()
        timers[bufnr] = nil
    end
end

local function format_python(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    if vim.bo[bufnr].filetype ~= "python" then
        return
    end

    if not vim.bo[bufnr].modified then
        return
    end

    local diagnostics = vim.diagnostic.get(bufnr, {
        severity = vim.diagnostic.severity.ERROR,
    })

    if #diagnostics > 0 then
        return
    end

    require("conform").format({
        bufnr = bufnr,
        async = true,
        lsp_fallback = false,
    })
end

local function reset_timer(bufnr)
    stop_timer(bufnr)

    local timer = vim.uv.new_timer()
    timers[bufnr] = timer

    timer:start(idle_time, 0, vim.schedule_wrap(function()
        stop_timer(bufnr)
        format_python(bufnr)
    end))
end

local python_group = vim.api.nvim_create_augroup("PythonAutoFormat", {
    clear = true,
})

vim.api.nvim_create_autocmd({
    "TextChanged",
    "TextChangedI",
}, {
    group = python_group,
    callback = function(args)
        if vim.bo[args.buf].filetype == "python" then
            reset_timer(args.buf)
        end
    end,
})

vim.api.nvim_create_autocmd("BufDelete", {
    group = python_group,
    callback = function(args)
        stop_timer(args.buf)
    end,
})