return {
    "Civitasv/cmake-tools.nvim",
    cmd = {
        "CMakeGenerate",
        "CMakeClean",
        "CMakeBuild",
        "CMakeQuickBuild",
        "CMakeInstall",
        "CMakeStopExecutor",
        "CMakeStopRunner",
        "CMakeOpenExecutor",
        "CMakeOpenRunner",
        "CMakeOpenCache",
        "CMakeRun",
        "CMakeQuickRun",
        "CMakeRunCurrentFile",
        "CMakeDebug",
        "CMakeDebugCurrentFile",
        "CMakeBuildCurrentFile",
        "CMakeLaunchArgs",
        "CMakeSelectBuildType",
        "CMakeSelectKit",
        "CMakeSelectConfigurePreset",
        "CMakeSelectBuildPreset",
        "CMakeSelectTestPreset",
        "CMakeSelectBuildTarget",
        "CMakeSelectLaunchTarget",
        "CMakeTargetSettings",
        "CMakeSettings",
        "CMakeSelectCwd",
        "CMakeSelectBuildDir",
        "CMakeRunTest",
        "CMakeQuickStart",
    },
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
        local project = require("config.project")
        local root = project.root(vim.api.nvim_buf_get_name(0)) or vim.uv.cwd()

        require("cmake-tools").setup({
            cmake_command = "cmake",
            ctest_command = "ctest",
            cmake_use_preset = true,
            cmake_regenerate_on_save = false,
            cmake_generate_options = {
                "-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
            },
            cmake_build_directory = function()
                return "build/$" .. "{variant:buildType}"
            end,
            cmake_compile_commands_options = {
                action = "soft_link",
                target = root,
            },
        })
    end,
}
