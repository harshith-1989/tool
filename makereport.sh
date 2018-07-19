#!/usr/bin/env bash

usage="$(basename "$0") -installation_folder <installation folder location>"
error_string="command not found"

XCODE_COMMAND_LINE_TOOLS_CHECK_INSTALLATION_CMD='pkgutil --pkg-info=com.apple.pkg.CLTools_Executables'

HOMEBREW_CHECK_INSTALLATION_CMD='which -s brew'
HOMEBREW_INSTALLATION_CMD='ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
HOMEBREW_UPDATE_CMD='HOMEBREW_NO_AUTO_UPDATE=1; brew update'
SET_HOMEBREW_AUTO_UPDATE_FALSE='HOMEBREW_NO_AUTO_UPDATE=1 brew bundle'

PIP_CHECK_INSTALLATION_CMD='python3 -m pip -V'
PIP_INSTALLATION_CMD='python3 -m ensurepip'
PIP_UPDATE_CMD='python3 -m pip install --upgrade pip'

BASIC_PATH_SETTINGS_FOR_BASH_PROFILE='/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'

### error handling function
handle_error () {
    echo -e "$1"
    echo -e "Aborting..."
    exit 1
}

### Check for the xcode command line tools installed on the machine
check_for_xcode_command_line_tools_installed (){
    $XCODE_COMMAND_LINE_TOOLS_CHECK_INSTALLATION_CMD  &> /dev/null || ( xcode-select --install; handle_error "$2 \n Please install xcode command line tools before proceeding" )
    echo -e "XCode command line tools installed on system..."
}

### Check if homebrew is installed on the machine
check_for_homebrew_installed () {
    $HOMEBREW_CHECK_INSTALLATION_CMD  &> /dev/null
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        echo -e "Homebrew not installed, installing Homebrew..."
        $HOMEBREW_INSTALLATION_CMD  &> /dev/null || handle_error "$2\n Homebrew installation failed, please install homebrew manually and retry..."
        $SET_HOMEBREW_AUTO_UPDATE_FALSE
    else
        echo -e "Homebrew installed, trying to update Homebrew... This may take some time."
        $HOMEBREW_UPDATE_CMD  &> /dev/null  || echo -e "$2\n Homebrew update failed, please update homebrew manually and retry..."
    fi
}

######################################################################################
# function desc : check for java installation and the version, this function was wriite
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

### Check if homebrew is installed on the machine
check_for_pip_installed () {
    $PIP_CHECK_INSTALLATION_CMD  &> /dev/null
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        echo -e "Python3 pip not installed, installing..."
        $PIP_INSTALLATION_CMD  &> /dev/null || handle_error "$2\n Python3 pip installation failed, please install pip manually and retry..."
        $SET_HOMEBREW_AUTO_UPDATE_FALSE
    else
        echo -e "Python3 pip installed, trying to update pip... This may take some time."
        $PIP_UPDATE_CMD  &> /dev/null  || echo -e "$2\n Python3 pip update failed, please update pip manually and retry..."
    fi
}

check_for_xcode_command_line_tools_installed
check_for_homebrew_installed
check_if_java_installed
check_if_python_installed
check_for_pip_installed