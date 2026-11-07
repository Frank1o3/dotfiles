# ----------------------------------------------------------- smart Enter key
function __veyra_run_python --argument-names script
    set -l dir (dirname -- $script)
    while true
        for env_dir in "$dir/.venv" "$dir/venv"
            set -l activate "$env_dir/bin/activate.fish"
            if test -f $activate
                if not set -q VIRTUAL_ENV; or test "$VIRTUAL_ENV" != (realpath -- $env_dir 2>/dev/null)
                    source $activate
                end
                set -l python_bin "$env_dir/bin/python"
                if test -x $python_bin
                    command $python_bin $script
                    return $status
                end
                break
            end
        end
        set -l parent (dirname -- $dir)
        if test "$parent" = "$dir"
            break
        end
        set dir $parent
    end

    if type -q python
        command python $script
    else
        command python3 $script
    end
end

function __veyra_handle_path --argument-names target
    if test -d $target
        cd -- $target
        return $status
    end
    if not test -f $target
        return 1
    end

    set -l extension (string lower -- (string replace -r '^.*\.' '' -- (basename -- $target)))
    if test "$extension" = py
        __veyra_run_python $target
        return $status
    end

    if test "$extension" = sh; and not test -x $target
        echo "'$target' is not executable. Review it, then run: chmod +x -- "(string escape -- $target)
        return 126
    end

    if test -x $target
        command $target
        return $status
    end

    if type -q file; and string match -q 'text/*' -- (file -b --mime-type -- $target)
        if type -q bat
            command bat --paging=always -- $target
        else
            $EDITOR -- $target
        end
    else if type -q xdg-open
        setsid -f xdg-open $target >/dev/null 2>&1
    else
        echo "No viewer available for '$target'" >&2
        return 127
    end
end

# A lone path is handled in-place: its text is cleared, then this function
# changes directory, displays, or runs the target without rewriting the line.
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
            if test -e $t
                commandline --current-buffer --replace -- ''
                commandline -f repaint
                __veyra_handle_path $t
                return $status
            end
        end
    end
    commandline -f execute
end

function __veyra_clear_all
    printf '\033[H\033[2J\033[3J'
    commandline -f repaint
end

