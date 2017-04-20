define qquit
    set confirm off
    quit
end
document qquit
Quit without asking for confirmation
end

define nextandinfo
    next
    echo ============== args =============\n
    info args
    echo ============= locals ============\n
    info locals
    echo =============================\n
