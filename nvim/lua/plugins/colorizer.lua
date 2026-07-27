return {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
        filetypes = { "css", "lua", "conf" },
        user_default_options = { css = true, mode = "background" },
    },
}
