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
    source "$LIB_PATH/lib_arrays.bash"
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
    echo "====================="
    echo "===== arrays.sh ====="
    echo "====================="
    
    local this_file
    this_file="$(find_path 'this_file' "${#BASH_SOURCE[@]}" \
                                       "${BASH_SOURCE[@]}")"
    echo -e "\nthis_file: $this_file\n"

    help_text_output

    test_find_array_index_by_value

}

help_text_output()
{
    echo -e "Call 'find_array_index_by_value -h'\n"

    echo "***********************************"
    echo "******* Start of help text ********"
    echo "***********************************"
    # Background as -h/--help will call 'exit 0'
    find_array_index_by_value -h &
    wait
    echo "***********************************"
    echo "******* End of help text **********"
    echo "***********************************"
    echo -e "\n"
}

test_find_array_index_by_value()
{
    local value_to_find='two'
    local array=('zero' 'one' "$value_to_find" 'three' 'four' 'two' 'one')

    local exit_code

    echo "Test find_array_index_by_value()"
    echo
    echo "Looking for value '$value_to_find' in the array:"
    for i in "${!array[@]}"
    do
        echo "array[$i]: '${array[i]}'"
    done

    local call
    call='find_array_index_by_value "$value_to_find" "${#array[@]}" '
    call+='"${array[@]}"'
    echo
    echo 'Call'
    echo "   $call"
    echo

    echo "********************************************"
    echo "*** Start of find_array_index_by_value() ***"
    echo "********************************************"
    echo

    find_array_index_by_value "$value_to_find" "${#array[@]}" "${array[@]}"
    exit_code=$?

    echo "******************************************"
    echo "*** End of find_array_index_by_value() ***"
    echo "******************************************"
    echo

    echo "Exit code: $exit_code"
    (( exit_code != 0 )) && exit 1

    echo "Found index: $index_found"
    echo

    if (( index_found == 2 ))
    then
        echo "Found correct index!"
    else
        echo "Incorrect index!"
        exit 1
    fi
    echo
}

#################
### Call main ###
#################
main "$@"
#################
