# ~/.config/fish/config.fish  --  Veyra
# Standalone: does NOT source cachyos-fish-config.
# Optional tools (everything degrades gracefully without them):
#   eza fzf fd bat rg zoxide starship wl-copy paru

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

# Nothing below is needed for non-interactive shells
if not status is-interactive
    return
end

# ------------------------------------------------- syntax highlighting colors
# Catppuccin Mocha. fish highlights as you type (red = unknown command,
# underline = existing path) and shows history autosuggestions in grey.
set -g fish_color_normal cdd6f4
set -g fish_color_command 89b4fa
set -g fish_color_keyword cba6f7
set -g fish_color_quote a6e3a1
set -g fish_color_redirection f5c2e7
set -g fish_color_end fab387
set -g fish_color_error f38ba8
set -g fish_color_param f2cdcd
set -g fish_color_option f9e2af
set -g fish_color_comment 7f849c
set -g fish_color_operator f5c2e7
set -g fish_color_escape f2cdcd
set -g fish_color_autosuggestion 6c7086
set -g fish_color_cancel f38ba8
set -g fish_color_valid_path --underline
set -g fish_color_selection --background=313244
set -g fish_color_search_match --background=313244
set -g fish_color_cwd f9e2af
set -g fish_color_user 94e2d5
set -g fish_color_host 89b4fa
set -g fish_color_status f38ba8
set -g fish_pager_color_progress 6c7086
set -g fish_pager_color_prefix f5c2e7
set -g fish_pager_color_completion cdd6f4
set -g fish_pager_color_description 6c7086
set -g fish_pager_color_selected_background --background=313244

# ------------------------------------------------------------- fzf (optional)
# Gives fuzzy Ctrl+R (history), Ctrl+T (insert file), Alt+C (cd into dir).
if type -q fzf
    set -gx FZF_DEFAULT_OPTS '--height=40% --layout=reverse --border=rounded --info=inline --color=bg:-1,bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4,hl:#f38ba8,hl+:#f38ba8,info:#cba6f7,prompt:#cba6f7,pointer:#f5e0dc,marker:#b4befe,spinner:#f5e0dc,header:#f38ba8'
    if type -q fd
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
    end
    if type -q bat
        set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
    end
    fzf --fish | source
end

# ------------------------------------------------------ zoxide / prompt (optional)
type -q zoxide; and zoxide init fish | source

if type -q starship
    starship init fish | source
else
    set -g __fish_git_prompt_showdirtystate 1
    set -g __fish_git_prompt_showuntrackedfiles 1
    set -g __fish_git_prompt_showcolorhints 1
    set -g __fish_git_prompt_color_branch cba6f7
    set -g __fish_git_prompt_color_dirtystate fab387
    set -g __fish_git_prompt_color_stagedstate a6e3a1
    set -g __fish_git_prompt_color_untrackedfiles f38ba8

    function fish_prompt
        set -l last_status $status

        # Python virtualenv indicator
        if set -q VIRTUAL_ENV
            set_color 89b4fa
            echo -n "("(basename $VIRTUAL_ENV)") "
        end

        set_color $fish_color_cwd --bold
        echo -n (prompt_pwd --full-length-dirs 2)
        echo -n (fish_vcs_prompt ' (%s)')
        if test $CMD_DURATION -gt 2000
            set_color f9e2af
            echo -n " "(math --scale 1 $CMD_DURATION / 1000)s
        end
        if test $last_status -ne 0
            set_color f38ba8
            echo -n " [$last_status]"
        end
        echo
        if test $last_status -eq 0
            set_color a6e3a1
        else
            set_color f38ba8
        end
        echo -n '❯ '
        set_color normal
    end
end

# -------------------------------------------------------- listing shortcuts
# These are functions (not abbreviations), so Fish runs the name you typed and
# leaves the command line untouched. Arguments are forwarded to the listing tool.
function __veyra_list
    if type -q eza
        command eza --group-directories-first --icons=auto $argv
    else
        set -l ls_args
        set -l skip_ignore 0
        for arg in $argv
            switch $arg
                case --git --git-ignore -T
                    # eza-only display flags have no ls equivalent.
                case -I
                    # Ignore patterns are specific to eza/tree.
                    set skip_ignore 1
                case '*'
                    if test $skip_ignore -eq 1
                        set skip_ignore 0
                    else
                        set -a ls_args $arg
                    end
            end
        end
        command ls $ls_args
    end
end

function l; __veyra_list $argv; end
function tree
    if type -q eza; __veyra_list -T $argv; else if type -q tree; command tree $argv; else; __veyra_list $argv; end
end
function ll; __veyra_list -lh --git $argv; end
function la; __veyra_list -a $argv; end
function lla; __veyra_list -lah --git $argv; end
function lg; __veyra_list --git-ignore $argv; end
function llg; __veyra_list -lh --git --git-ignore $argv; end
function lag; __veyra_list -a --git-ignore $argv; end
function llag; __veyra_list -lah --git --git-ignore $argv; end
function lt
    if type -q eza; __veyra_list -T $argv; else if type -q tree; command tree $argv; else; __veyra_list $argv; end
end
function lta
    if type -q eza; __veyra_list -aT -I '.git|node_modules' $argv; else if type -q tree; command tree -a -I .git $argv; else; __veyra_list -a $argv; end
end
function ltg
    if type -q eza; __veyra_list -T --git-ignore $argv; else if type -q tree; command tree --gitignore $argv; else; __veyra_list $argv; end
end
function ltag
    if type -q eza; __veyra_list -aT --git-ignore -I '.git|node_modules' $argv; else if type -q tree; command tree -a --gitignore -I .git $argv; else; __veyra_list -a $argv; end
end

# ----------------------------------------------------------- git shortcuts
function gs; git status -sb $argv; end
function ga; git add $argv; end
function gaa; git add -A $argv; end
function gc; git commit $argv; end
function gcm; git commit -m $argv; end
function gp; git push $argv; end
function gpl; git pull $argv; end
function gd; git diff $argv; end
function gds; git diff --staged $argv; end
function gb; git branch $argv; end
function gsw; git switch $argv; end
function gco; git checkout $argv; end
function gst; git stash $argv; end
function gstp; git stash pop $argv; end
function gl; git log --oneline --graph --decorate -20 $argv; end
function glog; git log --oneline --graph --decorate $argv; end

# ------------------------------------------------------- package shortcuts
function __veyra_pkg
    if type -q paru
        paru $argv
    else if type -q pacman
        sudo pacman $argv
    else
        echo 'Neither paru nor pacman is installed' >&2
        return 127
    end
end
function p; __veyra_pkg $argv; end
function psyu; __veyra_pkg -Syu $argv; end
function pin; __veyra_pkg -S $argv; end
function prem; __veyra_pkg -Rns $argv; end
function pss
    if type -q paru; paru -Ss $argv; else; pacman -Ss $argv; end
end
function psi
    if type -q paru; paru -Si $argv; else; pacman -Si $argv; end
end
function pclean; __veyra_pkg -Sc $argv; end

# ------------------------------------------------------------ service tools
function sc; systemctl $argv; end
function scu; systemctl --user $argv; end
function jc; journalctl -xe $argv; end
function jcu; journalctl --user -xe $argv; end

# --------------------------------------------------------------- shortcuts
function v; $EDITOR $argv; end
function reload; exec fish; end
function md; mkdir -p $argv; end
function up
    set -l levels 1
    if test (count $argv) -gt 0
        set levels $argv[1]
    end
    if not string match -rq '^[1-9][0-9]*$' -- $levels
        echo 'Usage: up [positive-level-count]' >&2
        return 2
    end
    set -l path (string repeat -n $levels '../')
    cd -- $path
end

# ------------------------------------------------------------------ functions
function mkcd --description 'mkdir -p and cd into it'
    mkdir -p -- $argv[1]; and cd -- $argv[1]
end

# Clear screen AND scrollback.
function cls --description 'Clear screen and scrollback'
    printf '\033[H\033[2J\033[3J'
end

# Erase command history (fish asks for confirmation itself).
function hclear --description 'Erase ALL saved command history'
    history clear
end

function hclear-session --description 'Forget commands typed in this session'
    history clear-session
end

function venv --description 'Activate Python virtual environment in .venv or venv'
    if test -f .venv/bin/activate.fish
        source .venv/bin/activate.fish
    else if test -f venv/bin/activate.fish
        source venv/bin/activate.fish
    else
        echo "No .venv/bin/activate.fish or venv/bin/activate.fish found"
    end
end

function path --description 'Print each PATH entry on a separate line'
    string join \n $PATH
end

# Wayland clipboard helper
if type -q wl-copy
    function clip --description 'Copy input or file to Wayland clipboard'
        if test (count $argv) -eq 0
            wl-copy
        else if test -f $argv[1]
            wl-copy < $argv[1]
        else
            echo -n (string join ' ' $argv) | wl-copy
        end
    end
end

# Interactive fuzzy search inside files using ripgrep and fzf
if type -q rg; and type -q fzf
    function fif --description 'Fuzzy search inside files with ripgrep and fzf'
        set -l query (test (count $argv) -gt 0; and echo "$argv"; or echo "")
        rg --color=always --line-number --no-heading --smart-case "$query" 2>/dev/null | \
            fzf --ansi \
                --delimiter : \
                --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                --bind 'enter:become('$EDITOR' +{2} {1})'
    end
end

# Universal archive extractor
function extract --description 'Extract any archive automatically'
    for file in $argv
        if test -f $file
            switch $file
                case '*.tar.bz2' '*.tbz2'
                    tar xjf $file
                case '*.tar.gz' '*.tgz'
                    tar xzf $file
                case '*.tar.xz' '*.txz'
                    tar xJf $file
                case '*.tar.zst'
                    tar --zstd -xf $file
                case '*.bz2'
                    bunzip2 $file
                case '*.rar'
                    unrar x $file
                case '*.gz'
                    gunzip $file
                case '*.tar'
                    tar xf $file
                case '*.zip'
                    unzip $file
                case '*.Z'
                    uncompress $file
                case '*.7z'
                    7z x $file
                case '*.zst'
                    zstd -d $file
                case '*'
                    echo "'$file' cannot be extracted via extract"
            end
        else
            echo "'$file' is not a valid file"
        end
    end
end

function fhelp --description 'Show Veyra shell shortcuts'
    echo 'Keys'
    echo '  Ctrl+L          clear screen'
    echo '  Alt+L           clear screen + scrollback'
    echo '  Right / Ctrl+F  accept autosuggestion     Alt+Right  accept one word'
    echo '  Tab             completion pager          Shift+Tab  search completions'
    echo '  Ctrl+R          fuzzy history (fzf)       Ctrl+T     insert file   Alt+C  cd to dir'
    echo '  Alt+E           edit command line in $EDITOR'
    echo 'Commands & Functions'
    echo '  cls    hclear    hclear-session    mkcd DIR    venv    path'
    echo '  fif [QUERY]    fuzzy search in files with preview and jump to $EDITOR'
    echo '  clip [FILE]    copy stdin or file to clipboard (Wayland)'
    echo '  extract FILE   extract any archive (.tar.*, .zip, .7z, .zst, etc.)'
    echo '  p / psyu / pin / prem / pss         paru / pacman package shortcuts'
    echo '  gs / ga / gc / gp / gpl / gd / gb   git shortcuts'
    echo '  l ll la lla    lg llg lag llag      lt lta ltg ltag   (g = apply .gitignore)'
    echo 'Enter on a lone path: directory -> cd, text file -> $EDITOR, other file -> xdg-open'
end

function fish-cheatsheet --description 'Print the Fish shortcut cheat sheet'
    set -l sheet (path dirname (status filename))/CHEATSHEET.md
    if test -r $sheet
        command cat $sheet
    else
        echo 'CHEATSHEET.md is not installed beside config.fish; showing the built-in shortcut summary.'
        fhelp
    end
end

# ----------------------------------------------------------- smart Enter key
function __veyra_is_text --argument-names f
    test -s $f; or return 0
    type -q file; or return 0
    not string match -q binary -- (file -b --mime-encoding -- $f)
end

# If the whole command line is one word that is not a command but IS a path:
#   directory  -> cd into it
#   text file  -> open in $EDITOR
#   other file -> xdg-open
# The rewritten command is what gets executed and saved in history.
function __veyra_enter
    if commandline --paging-mode
        commandline -f execute
        return
    end
    set -l buf (commandline --current-buffer)
    if not string match -qr '[;&|\n]' -- $buf
        set -l tokens (commandline --tokens-expanded)
        if test (count $tokens) -eq 1
            set -l t $tokens[1]
            if not type -q -- $t
                if test -d $t
                    commandline --current-buffer --replace -- "cd -- "(string escape -- $t)
                else if test -f $t
                    if __veyra_is_text $t
                        commandline --current-buffer --replace -- "$EDITOR -- "(string escape -- $t)
                    else
                        commandline --current-buffer --replace -- "setsid -f xdg-open "(string escape -- $t)" >/dev/null 2>&1"
                    end
                end
            end
        end
    end
    commandline -f execute
end

function __veyra_clear_all
    printf '\033[H\033[2J\033[3J'
    commandline -f repaint
end

# ------------------------------------------------------------------ bindings
set -l __veyra_fish_major (string split . -- $version)[1]
if test $__veyra_fish_major -ge 4
    bind enter __veyra_enter
    bind alt-l __veyra_clear_all
else
    bind \r __veyra_enter
    bind \el __veyra_clear_all
end
