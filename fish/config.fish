# Fish startup for Veyra. Feature code is split into ordered modules below.
set -g fish_greeting

# ---------------------------------------------------------------- environment
if type -q nvim
    set -gx EDITOR nvim
else if type -q vim
    set -gx EDITOR vim
else
    set -gx EDITOR vi
end
set -gx VISUAL $EDITOR

fish_add_path --global $HOME/.local/bin $HOME/.cargo/bin
fish_add_path --global --append $HOME/.local/share/nvim/mason/bin

if type -q bat
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end

# Keep environment setup above available to non-interactive Fish commands.
if not status is-interactive
    return
end

set -g __veyra_fish_config_dir (dirname -- (realpath -- (status --current-filename)))
for __veyra_module in 10-theme 20-integrations 30-listing 40-shortcuts 50-utilities 60-path-actions 70-keybindings
    source "$__veyra_fish_config_dir/modules/$__veyra_module.fish"
end
