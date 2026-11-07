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

