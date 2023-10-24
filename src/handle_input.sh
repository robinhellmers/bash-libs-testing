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

    ### Source libraries ###
    source "$LIB_PATH/lib_handle_input.bash"
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
}

###################
### END OF MAIN ###
###################

#################
### Call main ###
#################
main "$@"
#################
