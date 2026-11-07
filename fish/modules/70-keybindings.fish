# ------------------------------------------------------------------ bindings
set -l __veyra_fish_major (string split . -- $version)[1]
if test $__veyra_fish_major -ge 4
    bind enter __veyra_enter
    bind alt-l __veyra_clear_all
else
    bind \r __veyra_enter
    bind \el __veyra_clear_all
end
