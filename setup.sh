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
    retry_count=3
# folder structures
    folder_structure=( "INPUT_IOS_FOLDER:/input/iOS" "INPUT_ANDROID_FOLDER:/input/Android" "OUTPUT_IOS_FOLDER:/output/iOS" "OUTPUT_ANDROID_FOLDER:/output/Android" "LOGS_IOS_FOLDER:/logs/iOS" "LOGS_ANDROID_FOLDER:/logs/Android" "TMP_FOLDER:/tmp" "REPORT_FOLDER:/report" )

### usage of the script
usage () {
    usage="$(basename "$0") -installation_folder <installation folder location> \nwhere:
    \t-installation_folder  installation folder location\nYou will be prompted for INDIA domain credentials if you are running this script inside TCS network"

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

### clear the tmp folder
clear_tmp_folder () {
    rm -rf /tmp/tmp
    rm -rf /tmp/tmp.txt
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
                echo "$git_download_url not reached"#handle_error "URL not found/Unable to reach URL: $git_download_url"
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
  local max_attempts=${ATTEMPTS-$retry_count}
  local timeout=${TIMEOUT-1}
  local attempt=0
  local exitCode=0

  while (( $attempt < $max_attempts ))
  do
    set +e
    "$@"
    exitCode=$?
    set -e

    if [[ $exitCode == 0 ]]
    then
      break
    fi

    echo "Failure! Retrying in $timeout.." 1>&2
    sleep $timeout
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
  done

  if [[ $exitCode != 0 ]]
  then
    echo "You've failed me for the last time! ($@)" 1>&2
  fi

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
    #$( $curl_command ) || echo "cURL command failed with error : $error_msg"
    execute_curl_command $curl_command
    echo "test"
    if [ -e $output_file ]
    then
        for i in {1..$retry_count}
        do
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
        done
    fi

}

### write the folder structure to constants file
write_to_constants_file () {
    cat /tmp/tmp.txt >> $root_folder"/Scripts/Constants.py"
}

### set path variables
set_path_variable () {
    cp -f ${HOME}/.bash_profile ${HOME}/.old_bash_profile
    . ${HOME}/.bash_profile
    echo "export PATH=$PATH:$root_folder/other_tools" > ${HOME}/.bash_profile
}


usage $@
clear_tmp_folder
check_reachabiltiy_of_servers $proxy_address $git_download_url
create_folder_structure ${folder_structure[@]}
download_scripts_and_tools
write_to_constants_file
set_path_variable
