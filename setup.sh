#!/usr/bin/env bash


### Specify the folder structure & variables
## input
    root_folder=""
    user_name=""
    password=""
## constants
# to get the scripts
    git_download_url='https://github.com/harshith-1989/tool/archive/master.zip'
    proxy_address='iproxy.tcs.com:8080'
    output_file='tool.zip'
    proxy_reachable=''
    curl_command="curl -x $proxy_address --proxy-user $user_name:$password -k -L $git_download_url -o $output_file"
# folder structures
    folder_structure=( "INPUT_IOS_FOLDER:/input/iOS" "INPUT_ANDROID_FOLDER:/input/Android" "OUTPUT_IOS_FOLDER:/output/iOS" "OUTPUT_ANDROID_FOLDER:/output/Android" "SRC_FOLDER:/src" "LOGS:" "OTHER_TOOLS_IOS:/other-tools/iOS" "OTHER_TOOLS_ANDROID:/other-tools/Android" "TMP:/tmp" "REPORT_FOLDER:/report" )

### usage of the script
usage () {
    usage="$(basename "$0") -installation_folder <installation folder location> \nwhere:
    \t-installation_folder  installation folder location\nYou will be prompted for INDIA domain credentials if you are running this script inside TCS network"

echo $1
echo $2

if [ "$1" == "-h" ]; then
    echo -e "Usage: $usage"
    exit 0
elif [ "$1" == "-installation_folder" ]; then
    root_folder=$2
else
    echo -e "Invalid Argument!!\nUsage: $usage"
fi

}

### error handling function
handle_error () {
    echo ""
}

### accept user input
accept_user_input () {
    echo ""
}

### check if latest java version installed
check_for_latest_java_version () {
    echo ""
}

### check if latest version of python exists
check_if_python_installed () {
    echo ""
}

### check if proxy reachable
proxy_reachability_check () {
    echo ""
}

### download src scripts & other_tools
download_scripts_and_tools () {
    echo ""
}

### create folder structure by deleting the existing one if already present
create_folder_structure () {
    echo ""
}

### write the folder structure to constants file
write_to_constants_file () {
    echo ""
}

### set path variables
set_path_variable () {
    echo ""
}


usage $@
