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

