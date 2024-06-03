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

    local -r THIS_SCRIPT_PATH="$(tmp_find_script_path)"

    if [[ -z "$LIB_PATH" ]]
    then
        LIB_PATH="$(realpath "$THIS_SCRIPT_PATH/../lib")"
        export LIB_PATH
    fi

    ### Source libraries ###
    source "$LIB_PATH/lib_core.bash" || exit 1
    source_lib "$LIB_PATH/lib_files.bash"
}

# Minimal version of find_path(). Should only be used within this script to source library defining find_path().
tmp_find_script_path() {
    unset -f tmp_find_script_path; local s="${BASH_SOURCE[0]}"; local d
    while [[ -L "$s" ]]; do d=$(cd -P "$(dirname "$s")" &>/dev/null && pwd); s=$(readlink "$s"); [[ $s != /* ]] && s=$d/$s; done
    echo "$(cd -P "$(dirname "$s")" &>/dev/null && pwd)"
}

library_sourcing

############
### MAIN ###
############
main()
{
    echo "===================="
    echo "===== files.sh ====="
    echo "===================="

    local this_script_path
    this_script_path="$(find_path 'this' "${#BASH_SOURCE[@]}" \
                                         "${BASH_SOURCE[@]}")"
    
    test_is_windows_path

    test_is_linux_path
}

################
### END MAIN ###
################


test_is_windows_path()
{
    local windows_path
    windows_path='C:\Users'

    echo -e "\nLets check a valid Windows path: '$windows_path'"
    if is_windows_path "$windows_path"
    then
        echo "    is_windows_path(): Is a Windows path."
    else
        echo "    is_windows_path(): Is NOT a Windows path."
    fi

    windows_path='/home/'
    echo -e "\nLets check an INVALID Windows path: '$windows_path'"
    if is_windows_path "$windows_path"
    then
        echo "    is_windows_path(): Is a Windows path."
    else
        echo "    is_windows_path(): Is NOT a Windows path."
    fi
}

test_is_linux_path()
{
    local linux_path

    linux_path='C:\'
    _test_is_linux_path "$linux_path" 'strict' 'false'
    linux_path='/home/'
    _test_is_linux_path "$linux_path" 'strict' 'true'
    linux_path='/abc/'
    _test_is_linux_path "$linux_path" 'strict' 'false'

    linux_path='C:\'
    _test_is_linux_path "$linux_path" 'loose' 'false'
    linux_path='/home/'
    _test_is_linux_path "$linux_path" 'loose' 'true'
    linux_path='/abc/'
    _test_is_linux_path "$linux_path" 'loose' 'true'
   
}

_test_is_linux_path()
{
    local linux_path="$1"
    local strictness="$2"
    local expected_result="$3"

    local result
    echo -e "\nLets check if a valid Linux path using '$strictness' strictness: '$linux_path'"
    if is_linux_path "$linux_path" --strictness "$strictness"
    then
        echo_highlight "    is_linux_path(): Is a Linux path."
        result='true'
    else
        echo_highlight "    is_linux_path(): Is NOT a Linux path."
        result='false'
    fi

    if [[ "$result" == "$expected_result" ]]
    then
        echo_success "Expected result."
    else
        echo_error "Unexpected result."
    fi
}

main_stderr_red()
{
    main "$@" 2> >(sed $'s|.*|\e[31m&\e[m|' >&2)
}

#################
### Call main ###
#################
main_stderr_red "$@"
#################
