return {
    "Bekaboo/dropbar.nvim",
    dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
    keys = {
        {
            "<leader>;",
            function() require("dropbar.api").pick() end,
            desc = "Jump via breadcrumb (keyboard)",
        },
    },
    opts = {},
}
