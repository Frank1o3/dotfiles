# ~/.config/fish/config.fish  --  Veyra
# Standalone: does NOT source cachyos-fish-config.
# Optional tools (everything degrades gracefully without them):
#   eza fzf fd bat zoxide starship

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

if not status is-interactive
    # nothing below is needed for scripts / non-interactive shells
else

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
    function fish_prompt
        set -l last_status $status
        set_color $fish_color_cwd --bold
        echo -n (prompt_pwd --full-length-dirs 2)
        set_color 6c7086
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

# ------------------------------------------------------------- ls / tree (eza)
# Abbreviations expand on Space/Enter so you see (and learn) the real command.
#   no suffix = show everything (ignores .gitignore)
#   g suffix  = hide what .gitignore hides
#
#   l    list            lg    list, gitignore applied
#   ll   long            llg   long, gitignore applied
#   la   list + hidden   lag   list + hidden, gitignore applied
#   lla  long + hidden   llag  long + hidden, gitignore applied
#   lt   tree            ltg   tree, gitignore applied
#   lta  tree + hidden   ltag  tree + hidden, gitignore applied
# Limit tree depth by appending -L 2, e.g.  lt -L 2
if type -q eza
    set -l e 'eza --group-directories-first --icons=auto'
    set -l ignore "-I '.git|node_modules'"
    abbr -a l    "$e"
    abbr -a ll   "$e -lh --git"
    abbr -a la   "$e -a"
    abbr -a lla  "$e -lah --git"
    abbr -a lg   "$e --git-ignore"
    abbr -a llg  "$e -lh --git --git-ignore"
    abbr -a lag  "$e -a --git-ignore"
    abbr -a llag "$e -lah --git --git-ignore"
    abbr -a lt   "$e -T"
    abbr -a lta  "$e -aT $ignore"
    abbr -a ltg  "$e -T --git-ignore"
    abbr -a ltag "$e -aT --git-ignore $ignore"
else
    abbr -a l    'ls'
    abbr -a ll   'ls -lh'
    abbr -a la   'ls -A'
    abbr -a lla  'ls -lAh'
    if type -q tree
        abbr -a lt   'tree'
        abbr -a lta  'tree -a -I .git'
        abbr -a ltg  'tree --gitignore'
        abbr -a ltag 'tree -a --gitignore -I .git'
    end
end

# ---------------------------------------------------------- other abbreviations
abbr -a v      $EDITOR
abbr -a reload 'exec fish'
abbr -a gs     'git status -sb'
abbr -a ga     'git add'
abbr -a gaa    'git add -A'
abbr -a gc     'git commit'
abbr -a gcm    'git commit -m'
abbr -a gp     'git push'
abbr -a gpl    'git pull'
abbr -a gd     'git diff'
abbr -a gsw    'git switch'
abbr -a gl     'git log --oneline --graph --decorate -20'

# ..  ...  ....  ->  cd ../  cd ../../  cd ../../../
function __veyra_multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add dotdot --regex '^\.\.+$' --function __veyra_multicd

# sudo !!  ->  sudo <previous command>
function __veyra_last_cmd
    echo $history[1]
end
abbr --add '!!' --position anywhere --function __veyra_last_cmd

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

function fhelp --description 'Show Veyra shell shortcuts'
    echo 'Keys'
    echo '  Ctrl+L        clear screen'
    echo '  Alt+L         clear screen + scrollback'
    echo '  Right / Ctrl+F  accept autosuggestion     Alt+Right  accept one word'
    echo '  Tab           completion pager            Shift+Tab  search completions'
    echo '  Ctrl+R        fuzzy history (fzf)         Ctrl+T  insert file   Alt+C  cd to dir'
    echo '  Alt+E         edit command line in $EDITOR'
    echo 'Commands'
    echo '  cls  hclear  hclear-session  mkcd DIR  z DIR (zoxide)'
    echo '  l ll la lla  lg llg lag llag  lt lta ltg ltag   (g = apply .gitignore)'
    echo 'Enter on a lone path: directory -> cd, text file -> $EDITOR, other file -> xdg-open'
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

end