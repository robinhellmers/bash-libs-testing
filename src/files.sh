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
    local path

    echo -e "\n===== Test: is_windows_path() ====="

    linux_path='C:\'
    _test_is_windows_path "$linux_path" 'true'
    linux_path='/home/'
    _test_is_windows_path "$linux_path" 'false'
    linux_path='/abc/'
    _test_is_windows_path "$linux_path" 'false'
}

_test_is_windows_path()
{
    local path="$1"
    local expected_result="$2"

    local result
    echo -e "\nLets check if a valid Windows path: '$path'"
    if is_windows_path "$path"
    then
        echo_highlight "    is_windows_path(): Is a Linux path."
        result='true'
    else
        echo_highlight "    is_windows_path(): Is NOT a Linux path."
        result='false'
    fi

    if [[ "$result" == "$expected_result" ]]
    then
        echo_success "Expected result."
    else
        echo_error "Unexpected result."
    fi
}

test_is_linux_path()
{
    local path

    echo -e "\n===== Test: is_linux_path() ====="

    path='C:\'
    _test_is_linux_path "$path" 'false'
    path='/home/'
    _test_is_linux_path "$path" 'true'
    path='/abc/'
    _test_is_linux_path "$path" 'true'

    path='C:\'
    _test_is_linux_path "$path" 'false' 'exists'
    path='/home/'
    _test_is_linux_path "$path" 'true' 'exists'
    path='/abc/'
    _test_is_linux_path "$path" 'false' 'exists'
   
}

_test_is_linux_path()
{
    local linux_path="$1"
    local expected_result="$2"
    local extra_command="$3"

    local result='true'

    echo -e "\nLets check if a valid Linux directory path: '$linux_path'"
    if is_linux_path "$linux_path" --directory
    then
        echo_highlight "    is_linux_path(): Is a Linux directory."

        if [[ "$extra_command" == 'exists' ]]
        then
            echo -e "\nLets check if the Linux directory also exists: '$linux_path'"
            if is_linux_path "$linux_path" --directory --exists
            then
                echo_highlight "    is_linux_path(): The Linux directory exists."
            else
                echo_highlight "    is_linux_path(): The Linux directory does NOT exist."
                result='false'
            fi
        fi
    else
        echo_highlight "    is_linux_path(): Is NOT a Linux directory."
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
