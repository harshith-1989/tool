#!/usr/bin/env bash



######Constants
error_string="command not found"

## to get the scripts
    git_download_url='https://github.com/tool/archive/master.zip'
    internal_download_url='http://localhost/~digitalsecurity/downloads/tool-master.zip'
    proxy_address='proxy.tcs.com:8080'
    output_file='/tmp/tmp/tool.zip'
    curl_command="curl -k -L $download_url -o $output_file"
    output_file='/tmp/tmp/tool.zip'


### error handling function
handle_error () {
    echo "$1"
    echo "Aborting..."
    exit 1
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
