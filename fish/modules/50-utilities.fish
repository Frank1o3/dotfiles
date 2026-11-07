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
    echo 'Enter on a lone path: directory -> cd; Python -> run and activate nearest project venv'
    echo '  executable file -> run; non-executable .sh -> explain chmod; other text -> bat or editor'
    echo '  fish-cheatsheet  print the full shortcut reference'
end

function fish-cheatsheet --description 'Print the Fish shortcut cheat sheet'
    set -l sheet "$__veyra_fish_config_dir/CHEATSHEET.md"
    if test -r $sheet
        command cat $sheet
    else
        echo 'CHEATSHEET.md is not installed beside config.fish; showing the built-in shortcut summary.'
        fhelp
    end
end

