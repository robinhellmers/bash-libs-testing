#!/usr/bin/env bash

sourceable_script='false'

if [[ "$sourceable_script" != 'true' && ! "${BASH_SOURCE[0]}" -ef "$0" ]]
then
    echo "Do not source this script! Execute it with bash instead."
    return 1
fi
unset sourceable_script

########################
### Library sourcing ###
########################

library_sourcing()
{
    # Unset as only called once and most likely overwritten when sourcing libs
    unset -f library_sourcing

    if ! [[ -d "$LIB_PATH" ]]
    then
        local -r THIS_SCRIPT_PATH="$(tmp_find_script_path)"
        readonly LIB_PATH="$THIS_SCRIPT_PATH/../lib"
        export LIB_PATH
    fi

    ### Source libraries ###
    source "$LIB_PATH/lib_handle_input.bash"
}

# Minimal version of find_path(). Should only be used within this script to source library defining find_path().
tmp_find_script_path() {
    unset -f tmp_find_script_path; local s="${BASH_SOURCE[0]}"; local d
    while [ -L "$s" ]; do d=$(cd -P "$(dirname "$s")" &>/dev/null && pwd); s=$(readlink "$s"); [[ $s != /* ]] && s=$d/$s; done
    echo "$(cd -P "$(dirname "$s")" &>/dev/null && pwd)"
}

library_sourcing

############
### MAIN ###
############

main()
{
    echo "==========================="
    echo "===== handle_input.sh ====="
    echo "==========================="

    local this_file="$(find_path 'this_file' "${#BASH_SOURCE[@]}" "${BASH_SOURCE[@]}")"
    echo -e "\nthis_file: $this_file\n"

    myfunc

    echo

    myfunc -e 'Hello world!'

    echo

    mysecondfunc --echo 'Hello world again!' -v
}


myfunc()
{
    echo "*** myfunc() ***"
    _handle_args_myfunc "$@"

    if [[ "$myfunc_echo_flag" == 'true' ]]
    then
        echo "$myfunc_echo_flag_value"
    fi
}

register_function_flags 'myfunc' \
                        '-e' '--echo' 'true'

_handle_args_myfunc()
{
    _handle_args 'myfunc' "$@"

    if [[ "$echo_flag" == 'true' ]]
    then
        echo "The --echo flag for myfunc() was given."
        myfunc_echo_flag_value="$echo_flag_value"
        myfunc_echo_flag='true'
    fi
}

mysecondfunc()
{
    echo "*** mysecondfunc() ***"
    _handle_args_mysecondfunc "$@"

    if [[ "$mysecondfunc_echo_flag" == 'true' ]]
    then
        [[ "$mysecondfunc_v_flag" == 'true' ]] && echo "You input the echo:"
        echo "$mysecondfunc_echo_flag_value"
    fi
}

register_function_flags 'mysecondfunc' \
                        ''   '--echo' 'true' \
                        '-v' ''     'false'

_handle_args_mysecondfunc()
{
    _handle_args 'mysecondfunc' "$@"

    if [[ "$echo_flag" == 'true' ]]
    then
        echo "The --echo flag for mysecondfunc() was given."
        mysecondfunc_echo_flag_value="$echo_flag_value"
        mysecondfunc_echo_flag='true'
    fi

    if [[ "$v_flag" == 'true' ]]
    then
        echo "The -v flag for mysecondfunc() was given."
        mysecondfunc_v_flag='true'
    fi
}

###################
### END OF MAIN ###
###################

#################
### Call main ###
#################
main "$@"
#################
