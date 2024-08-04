#!/usr/bin/env -S bash -i

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
    echo "=============================================="
    echo "===== override_interactive_shell_exit.sh ====="
    echo "=============================================="

    local this_script_path
    this_script_path="$(find_path 'this' "${#BASH_SOURCE[@]}" \
                                         "${BASH_SOURCE[@]}")"

    echo "In main"

    echo "type -t exit: '$(type -t exit)'"
    if [[ "$(type -t exit)" == "builtin" ]]
    then
        echo "Default builtin exit is used."
        echo "Should be overridden with an exit() function." >&2
        echo "Probably not running this test script as an interactive shell." >&2
        builtin exit 1
    else
        echo "Overridden exit function is used."
    fi

    func1
    echo "SHOULD NOT PRINT: Back in main 1st"
    echo "SHOULD NOT PRINT: Back in main 2nd"

    return_main
}

func1() {
    echo "In func1"
    func2
    echo "SHOULD NOT PRINT: Back in func1 1st"
    echo "SHOULD NOT PRINT: Back in func1 2nd"
}

func2() {
    echo "In func2"
    exit 5  # This will trigger the overridden exit function
    echo "SHOULD NOT PRINT: Back in func2 1st"
    echo "SHOULD NOT PRINT: Back in func2 2nd"
}


################
### END MAIN ###
################

main_stderr_red()
{
    main "$@" 2> >(sed $'s|.*|\e[31m&\e[m|' >&2)
}

#################
### Call main ###
#################
main_stderr_red "$@"
#################
