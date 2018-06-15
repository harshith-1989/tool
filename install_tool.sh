#!/usr/bin/env bash

### Specify the folder structure & variables
## input
    root_folder=""
## constants
     error_string="command not found"
     usage="$(basename "$0") -installation_folder <installation folder location>"

# to get the scripts
    git_download_url='https://github.com/tool/archive/master.zip'
    output_file='/tmp/tmp/tool.zip'
    curl_command_without_proxy="curl -k -L $git_download_url -o $output_file"

# folder structures
    folder_structure=( "RESOURCE_FOLDER:resources" "INPUT_IOS_FOLDER:input/iOS" "INPUT_ANDROID_FOLDER:input/Android" "OUTPUT_IOS_FOLDER:output/iOS" "OUTPUT_ANDROID_FOLDER:output/Android" "LOGS_IOS_FOLDER:logs/iOS" "LOGS_ANDROID_FOLDER:logs/Android" "TMP_FOLDER:tmp" "REPORT_FOLDER:report" )

### usage of the script
usage () {

    if [ "$1" == "-h" ]
    then
        echo -e "Usage: $usage"
        exit 0
    elif [ "$1" == "-installation_folder" ]
    then
        root_folder=$2
        if [ ! -d "$root_folder" ]
        then
            echo "Please enter an existant folder on the machine"
        fi
    else
        echo -e "Invalid Argument!!\nUsage: $usage"
    fi

}


### error handling function
handle_error () {
    echo "$1"
    echo "Aborting..."
    exit 1
}

#####################################################################################
# function desc : check for java installation and the version
# arguments : none
# return value : none
#####################################################################################
check_if_java_installed() {
   execution_output="$( java -version 2>&1 | head -n 1 )"
   if [[ "$execution_output" = *"$error_string"* ]]
   then
       echo "$execution_output" && handle_error "Java is not installed on the machine"
   else
       echo "$execution_output is installed on system"
       if [[ ( "$execution_output" = *"1.5"* ) || ( "$execution_output" = *"1.6"* ) || ( "$execution_output" = *"1.7"* ) ]]
       then
            handle_error "Please install java version greater than or equal to 1.8.*"
       fi
   fi
}

#####################################################################################
# function desc : check for python installation and the version
# arguments : none
# return value : boolean, string
#####################################################################################
check_if_python_installed() {
    generic_python_executables=( "python" "python3" )

    for python_executable in "${generic_python_executables[@]}"
    do
        execution_output="$( $python_executable -V 2>&1 )"
        if [[ "$execution_output" = *"$error_string"* ]]
        then
            handle_error "$execution_output"
        else
            echo "$execution_output version of python is installed on system"
        fi
    done
}

### create folder structure by deleting the existing one if already present
create_folder_structure () {
    for folder in "${@}"
    do
        KEY="${folder%%:*}"
        VALUE="${folder#*:}"
        mkdir -p "$root_folder""$VALUE"
        echo -e "$KEY = \"$root_folder$VALUE\"\n" >> /tmp/tmp.txt
    done
}

usage $@
check_if_python_installed
check_if_java_installed
create_folder_structure ${folder_structure[@]}