return {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
        keymap = {
            preset = "super-tab",
        },
        appearance = {
            nerd_font_variant = "mono",
        },
        completion = {
            documentation = {
                auto_show = true,
            },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "crates" },
        },
        fuzzy = {
            implementation = "prefer_rust_with_warning",
        },
    },
}
