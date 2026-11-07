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

