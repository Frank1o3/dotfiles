return {
    "b0o/schemastore.nvim",
    cond = function()
        local workspace = require("config.workspace")
        return workspace.has("JSON") or workspace.has("YAML")
    end,
}
