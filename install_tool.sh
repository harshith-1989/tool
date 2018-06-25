#!/usr/bin/env bash

### Specify the folder structure & variables
## constants
     error_string="command not found"
     usage="$(basename "$0") -installation_folder <installation folder location>"

## input
    root_folder=""

## to get the scripts
    git_download_url='https://github.com/tool/archive/master.zip'
    internal_download_url='http://localhost/~digitalsecurity/downloads/tool-master.zip'
    proxy_address='proxy.tcs.com:8080'
    output_file='/tmp/tmp/tool.zip'
    curl_command="curl -k -L $download_url -o $output_file"

## folder structures
    folder_structure=( "RESOURCE_FOLDER:resources" "INPUT_IOS_FOLDER:input/iOS" "INPUT_ANDROID_FOLDER:input/Android" "OUTPUT_IOS_FOLDER:output/iOS" "OUTPUT_ANDROID_FOLDER:output/Android" "LOGS_IOS_FOLDER:logs/iOS" "LOGS_ANDROID_FOLDER:logs/Android" "TMP_FOLDER:tmp" "REPORT_FOLDER:report" )


### error handling function
handle_error () {
    echo "$1"
    echo "Aborting..."
    exit 1
}

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
            echo "Please enter an existent folder on the machine"
        fi
    else
        echo -e "Invalid Argument!!\nUsage: $usage"
    fi

}


#####################################################################################
# reachability_check : check for reachability of URLs
# arguments : URL
# return value : boolean
#####################################################################################
reachability_check () {
    server=$1
    if $( curl --output /dev/null --silent --head --fail "$server" )
    then
        echo "TRUE"
    else
        echo "FALSE"
    fi
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

#####################################################################################
# create_folder_structure : create folder structure by deleting the existing one if already present
# arguments : none
# return value : boolean, string
#####################################################################################
create_folder_structure () {
    for folder in "${@}"
    do
        KEY="${folder%%:*}"
        VALUE="${folder#*:}"
        mkdir -p "$root_folder""$VALUE"
        echo -e "$KEY = \"$root_folder$VALUE\"\n" >> /tmp/tmp.txt
    done
}


#####################################################################################
# download_scripts_and_tools : download tools and setup directories
# arguments : none
# return value : none
#####################################################################################
### download src scripts & other_tools
download_scripts_and_tools () {
#Check if servers are reachable
    download_url=""
    if [ "$( reachability_check $proxy_address )" == "TRUE" ]
    then
        if [ "$( reachability_check $internal_download_url )" == "TRUE" ]
        then
            download_url=$internal_download_url
        else
            handle_error "Error: Link $internal_download_url not reachable"
        fi
    else
        if [ "$( reachability_check $git_download_url )" == "TRUE" ]
        then
            download_url=$git_download_url
        else
            handle_error "Error: Link $git_download_url not reachable"
        fi
    fi
#Generate output folder
    mkdir -p $( dirname $output_file )
#Download the tool
    $( $curl_command ) || echo "cURL command failed with error : $error_msg"
#Check zip file structure
    if [ -e $output_file ]
    then
        if [[ $( zip -T $output_file ) =~ "Zip file structure invalid" ]]
        then
            echo -e "\nDownloaded zip file is corrupted... Retrying"
            $( $curl_command ) || echo "cURL command failed with error : $error_msg"
        else
            unzip $output_file -d /tmp/tmp
            rm -rf $output_file

            cp -rf /tmp/tmp/*/Scripts $root_folder
            rm -rf /tmp/tmp/*/Scripts

            unzip /tmp/tmp/*/*.zip -d /tmp/tmp/other_tools || handle_error "Error: Unzip failed for : /tmp/tmp/*/*.zip"
            cp -rf /tmp/tmp/other_tools $root_folder
            rm -rf /tmp/tmp
            break
        fi
    fi
}

usage $@
check_reachabiltiy_of_servers $proxy_address $git_download_url
check_if_python_installed
check_if_java_installed
create_folder_structure ${folder_structure[@]}