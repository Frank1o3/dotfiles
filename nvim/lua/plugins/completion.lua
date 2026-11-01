local Workspace = require("config.workspace")
local sources = { "lsp", "path", "snippets", "buffer" }
local has_javascript = Workspace.has("JavaScript") or Workspace.has("TypeScript")
if has_javascript then
    table.insert(sources, "npm")
end

return {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
        {
            "alexandre-abrioux/blink-cmp-npm.nvim",
            cond = function()
                return has_javascript
            end,
        },
    },

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
            default = sources,
            providers = has_javascript and {
                npm = {
                    name = "npm",
                    module = "blink-cmp-npm",
                    async = true,
                    score_offset = 100,
                    opts = {
                        only_semantic_versions = true,
                        only_latest_version = false,
                    },
                },
            } or {},
        },

        fuzzy = {
            implementation = "prefer_rust_with_warning",
        },
    },
}
