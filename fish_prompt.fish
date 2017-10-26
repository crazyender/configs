function fish_prompt --description 'Write out the prompt'
    set last_status $status
    printf '%s%s@%s%s%s%s%s\n' (set_color green) (whoami) (set_color green) (hostname|cut -d . -f 1) (set_color yellow) (prompt_pwd) (__fish_git_prompt) 
    if test $last_status = 0
        set_color green
    else
        set_color red
    end
    printf '$ '
end

function ll
    ls -al $argv
end

function l
    ls -l $argv
end
