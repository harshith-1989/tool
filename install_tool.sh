#!/bin/sh

### Specify the folder structure & variables
## constants
     error_string="command not found"
     usage="$(basename "$0") -p <installation folder location>"

## input
    installation_folder=""

## to get the scripts
    git_download_url='https://github.com/harshith-1989/tool/archive/master.zip'
    internal_download_url='http://localhost/~digitalsecurity/downloads/tool-master.zip'
    proxy_address='proxy.tcs.com'

## File paths
    downloaded_tool_zip='.tmp/tool.zip'
    BASH_PROFILE_PATH="${HOME}/.bash_profile"
    BACKUP_BASH_PROFILE_PATH="${HOME}/.bash_profile_bak"
    TMP_FOLDER_LOCATION=".tmp"
    OTHER_TOOLS_LOCATION="resources/other_tools"
    CONSTANTS_FILE_LOCATION="Scripts/Constants.py"
## folder structures
    folder_structure=( "RESOURCE_FOLDER:resources" "INPUT_IOS_FOLDER:input/iOS" "INPUT_ANDROID_FOLDER:input/Android" "OUTPUT_IOS_FOLDER:output/iOS" "OUTPUT_ANDROID_FOLDER:output/Android" "LOGS_IOS_FOLDER:logs/iOS" "LOGS_ANDROID_FOLDER:logs/Android" "TMP_FOLDER:.tmp" "REPORT_FOLDER:report" )

# resources folder for tools
# input/iOS & android folder will have the app-name folder with 2 folders within, app folder & app-source-code folder
# output/iOS & android folder will have the app-name folder with 2 folders within, app folder & app-source-code folder
# logs/iOS & android folder will have the app-name folder with 2 folders within, app folder & app-source-code folder
# temp folder for the temp operations
# Report folder for the report operations

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
# function desc : check for java installation and the version
# arguments : none
# return value : none
#####################################################################################
check_if_java_installed() {
   execution_output="$( java -version 2>&1 | head -n 1 )"
   if [[ "$execution_output" = *"$error_string"* ]]
   then
       echo "Java is not installed on the machine or not configured to path" && handle_error "$execution_output"
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
        echo "Checking for ${python_executable}..."
        execution_output="$( $python_executable -V 2>&1 )"
        if [[ "$execution_output" = *"$error_string"* ]]
        then
            echo "${python_executable} is a pre-requisite. Its either not installed or not in path." && handle_error "$execution_output"
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
        echo "Creating folder : ${VALUE} at ${installation_folder}/${VALUE}"
        mkdir -p "$installation_folder/""$VALUE" || handle_error "Unable to create folder, please make sure you have appropriate permissions"
        echo -e "$KEY = \"$installation_folder/$VALUE\"\n" >> /tmp/tmp.txt
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
        echo "TCS Internal proxy server is reachable..."
        if [ "$( reachability_check $internal_download_url )" == "TRUE" ]
        then
            echo "TCS Internal tool-download-URL is reachable..."
            download_url=$internal_download_url
        else
            handle_error "Error: Link $internal_download_url not reachable"
        fi
    else
        echo "TCS Internal proxy server is not reachable..."
        echo "Trying git download link..."
        if [ "$( reachability_check $git_download_url )" == "TRUE" ]
        then
            echo "git tool-download-URL is reachable..."
            download_url=$git_download_url
        else
            handle_error "Error: Link $git_download_url not reachable"
        fi
    fi
#Generate output folder
    mkdir -p $( dirname $downloaded_tool_zip ) || handle_error "Unable to create folder, please make sure you have appropriate permissions"
#Download the tool
    curl_command="curl -k -L $download_url -o $downloaded_tool_zip"
    $( $curl_command ) || echo "cURL command failed with error"
#Check zip file structure
    if [ -e $downloaded_tool_zip ]
    then
        if [[ $( zip -T $downloaded_tool_zip ) =~ "Zip file structure invalid" ]]
        then
            echo -e "\nDownloaded zip file is corrupted... Retrying"
            $( $curl_command ) || echo "cURL command failed with error"
        else
        # transfer the contents to the created folder structure
            unzip $downloaded_tool_zip -d "$installation_folder"/"$TMP_FOLDER_LOCATION"
            rm -rf $downloaded_tool_zip

            cp -rf "$installation_folder"/"$TMP_FOLDER_LOCATION"/*/Scripts "$installation_folder/"
            rm -rf "$installation_folder"/"$TMP_FOLDER_LOCATION"/*/Scripts

            unzip "$installation_folder"/"$TMP_FOLDER_LOCATION"/*/*.zip -d "$installation_folder/resources" || handle_error "Error: Unzip failed for : "$installation_folder"/"$TMP_FOLDER_LOCATION"/*/*.zip"
            rm -rf "$installation_folder"/"$TMP_FOLDER_LOCATION"/*
        fi
    fi
}

#####################################################################################
# write_to_constants_file : write the path variable to the Constants.py file
# arguments : none
# return value : none
#####################################################################################
write_to_constants_file () {
    echo "Writing directoy paths to the Constants file..."
    cat /tmp/tmp.txt >> $installation_folder/"/${CONSTANTS_FILE_LOCATION}"
}

#####################################################################################
# set_path_variable : configure the path for the usage of the tools
# arguments : none
# return value : none
#####################################################################################
set_path_variable () {

    ## file paths
    APKTOOL_JAR_PATH="$installation_folder/${OTHER_TOOLS_LOCATION}/apktool.jar"
    SQLMAP_PATH="$installation_folder/${OTHER_TOOLS_LOCATION}/sqlmap-dev/sqlmap.py"
    NIKTO_PATH="$installation_folder/${OTHER_TOOLS_LOCATION}/nikto-master/program/nikto.pl"
    ENJARIFY_PATH="$installation_folder/${OTHER_TOOLS_LOCATION}/enjarify-master/enjarify.sh"
    JDGUI_PATH="$installation_folder/${OTHER_TOOLS_LOCATION}/jd-core.jar"

    ##  Write tool's paths to the bash profile
    cp -f ${BASH_PROFILE_PATH} ${BACKUP_BASH_PROFILE_PATH}
    echo "######## Added by security tool on $( date )" >> ${BASH_PROFILE_PATH}
    echo "######## Old bash_profile is at : ${BACKUP_BASH_PROFILE_PATH}" >> ${BASH_PROFILE_PATH}
    echo "export PATH=$PATH:$installation_folder/${OTHER_TOOLS_LOCATION}:$installation_folder/${OTHER_TOOLS_LOCATION}\n" >> ${BASH_PROFILE_PATH}
    echo "alias apktool=\"java -jar ${APKTOOL_JAR_PATH}\"" >> ${BASH_PROFILE_PATH}
    echo "alias sqlmap=\"python ${SQLMAP_PATH}\"" >> ${BASH_PROFILE_PATH}
    echo "alias nikto=\"perl ${NIKTO_PATH}\"" >> ${BASH_PROFILE_PATH}
    echo "alias enjarify=\"$installation_folder/${OTHER_TOOLS_LOCATION}/enjarify-master/enjarify.sh\"" >> ${BASH_PROFILE_PATH}
    echo "alias jdgui=\"java -jar ${JDGUI_PATH}\"" >> ${BASH_PROFILE_PATH}
    . ${BASH_PROFILE_PATH}
    echo "Please restart the terminal for the changes to take effect"
}

############## Main()
while getopts h:p: option
do
case "${option}"
in
h)
    echo -e "Usage: $usage"
    exit 0
    ;;
p)
    installation_folder=${OPTARG}
        if [ ! -d "installation_folder/" ]
        then
            echo "Please enter an existent folder on the machine"
        fi
        echo "${installation_folder} exists, proceeding with installation..."
     ;;
*)
    handle_error "Invalid Argument!!\nUsage: $usage"
    ;;
esac
done

check_if_python_installed
check_if_java_installed
create_folder_structure "${folder_structure[@]}"
download_scripts_and_tools
#configure_the_tool
write_to_constants_file
set_path_variable