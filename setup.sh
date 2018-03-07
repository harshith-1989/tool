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
    output_file='/tmp/tmp/tool.zip'
    proxy_reachable=''
    curl_command_with_proxy="curl -x $proxy_address --proxy-user $user_name:$password -k -L $git_download_url -o $output_file"
    curl_command_without_proxy="curl -k -L $git_download_url -o $output_file"
# folder structures
    folder_structure=( "INPUT_IOS_FOLDER:/input/iOS" "INPUT_ANDROID_FOLDER:/input/Android" "OUTPUT_IOS_FOLDER:/output/iOS" "OUTPUT_ANDROID_FOLDER:/output/Android" "LOGS:" "OTHER_TOOLS:/other-tools" "TMP:/tmp" "REPORT_FOLDER:/report" )

### usage of the script
usage () {
    usage="$(basename "$0") -installation_folder <installation folder location> \nwhere:
    \t-installation_folder  installation folder location\nYou will be prompted for INDIA domain credentials if you are running this script inside TCS network"

echo $1
echo $2

if [ "$1" == "-h" ]
then
    echo -e "Usage: $usage"
    exit 0
elif [ "$1" == "-installation_folder" ]
then
    root_folder=$2
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

### create folder structure by deleting the existing one if already present
create_folder_structure () {
    for folder in "${@}"
    do
        KEY="${folder%%:*}"
        VALUE="${folder#*:}"
        mkdir -p "$root_folder""$VALUE"
        echo -e "$KEY = \"$VALUE\"\n" >> /tmp/tmp.txt
    done
}

### check for reachability
reachability_check () {
    server=$1
    if $( curl --output /dev/null --silent --head --fail "$server" )
    then
        echo "TRUE"
    else
        echo "FALSE"
    fi
}

### check for reachability of servers involved
check_reachabiltiy_of_servers () {
    for server in "${@}"
    do
        if [ $server == $proxy_address ]
        then
            proxy_reachable=$( reachability_check $proxy_address )
        elif [ $server == $git_download_url ]
        then
            if [ $( reachability_check $git_download_url ) == "FALSE" ]
            then
                handle_error "URL not found/Unable to reach URL: $git_download_url"
            fi
        else
            if [ $( reachability_check $server ) == "FALSE" ]
            then
                echo "Error : $server not reachable"
            fi
        fi
    done
}

### execute curl command
execute_curl_command () {
    error_msg=$($1 2>&1 1>/dev/null)

    if [ $? == 0 ]
    then
        echo "cURL command executed successfully"
    else
        handle_error "cURL command failed with error : $error_msg"
}


### download src scripts & other_tools
download_scripts_and_tools () {
    curl_command=""
    if [ $proxy_reachable == "TRUE" ]
    then
        curl_command=$curl_command_with_proxy
    else
        curl_command=$curl_command_without_proxy
    fi

    mkdir -p $( dirname $output_file )
    execute_curl_command $curl_command

    if [ -e $output_file ]
    then
        unzip $output_file -d /tmp/tmp || handle_error "Error: Unzip failed for : $output_file"
        rm -rf $output_file
        cp -rf /tmp/tmp/*/Scripts $root_folder
        rm -rf /tmp/tmp/*/Scripts
        unzip /tmp/tmp/*/*.zip -d /tmp/tmp || handle_error "Error: Unzip failed for : /tmp/tmp/*/*.zip"
        cp -rf /tmp/tmp/other_tools $root_folder
    fi

}

### write the folder structure to constants file
write_to_constants_file () {
    cat /tmp/tmp.txt >> $root_folder"/Scripts/Constants.py"
}

### set path variables
set_path_variable () {
    echo ""
}


usage $@
check_reachabiltiy_of_servers $proxy_address $git_download_url
create_folder_structure $folder_structure
download_scripts_and_tools
write_to_constants_file
set_path_variable
