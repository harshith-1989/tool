import os
import subprocess
import zipfile
import tarfile
import logging
import shutil

import Constants
from xmltreeDict import *
import xml.etree.ElementTree as ET

#######################################################################################################################################################
#######################################################            Common Functions       #############################################################
#######################################################################################################################################################

#######################################################################################################################################################
############## Funtion to log_error_and_exit test execution 
############## input = error_string : String
############## output = -
def log_error_and_exit(error_string):
    if os.path.exists(Constants.LOGGING_FILE):
        logging.error(error_string)
        exit(5)
    else:
        print (error_string)
        exit(5)

#######################################################################################################################################################
############## Funtion to log_error_and_exit test execution
############## input = error_string : String
############## output = -
def clear_directory(directory):
    try:
        shutil.rmtree(directory)
        os.mkdir(directory)
    except Exception as e:
        log_error_and_exit("clearing directory failed, {}".format(str(e)))

############## test call:
# print (log_error_and_exit("errorstring:String")


#######################################################################################################################################################
############## Helper function to check if the process executed sucessfully using the return code passed as argument
def process_did_not_execute_successfully(execution_return_code):
    True if execution_return_code == 0 else False


#######################################################################################################################################################
############## Funtion to execute the unix shell commands
############## input = shell command : String
############## output = execution output : String
def execute_shell_command(command):
    try:
        logging.info("Executing : {}".format(command))
        command_execution = subprocess.run(command.split(), stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                           stderr=subprocess.PIPE)
        if process_did_not_execute_successfully(command_execution.returncode):
            raise Exception(command_execution.stderr)

        logging.info("INFO :{} \n OUTPUT:\n{}".format(command_execution.stderr.decode("utf-8").rstrip('\n'),command_execution.stdout.decode("utf-8").rstrip('\n')))
        return {"INFO":command_execution.stderr.decode("utf-8").rstrip('\n'), "OUTPUT":command_execution.stdout.decode("utf-8").rstrip('\n')}

    except Exception as error:
        log_error_and_exit("Command : {} ,failed with error : {}".format(command, error))
        return


############## test call:
# print (execute_shell_command(["ls","-l"]))

#######################################################################################################################################################
############## Funtion to unzip app into the output folder
############## input = app path : String
############## output = -
def unzip_to_folder(zip_path, dst_directory):
    if os.path.exists(zip_path) and zipfile.is_zipfile(zip_path):
        try:
            zip_reference = zipfile.ZipFile(zip_path,'r')
            zip_reference.extractall(dst_directory)
            zip_reference.close()
            return Constants.SUCCESS
        except Exception as e:
            logging.error(str(e))
            if Constants.ENCRYPTED in str(e):
                return Constants.ENCRYPTED
            if Constants.NOT_A_ZIP in str(e):
                return Constants.NOT_A_ZIP
    else:
        log_error_and_exit("File/Dir at {} not found for unzipping file".format(zipfile))


############## test call:

#######################################################################################################################################################
############## Funtion to unzip app into the output folder
############## input = app path : String
############## output = -
def unzip_app_and_move_contents_to_output_folder(app_path):
    ret = unzip_to_folder(app_path, Constants.OUTPUT_FOLDER)
    if ret is not None:
        print("File/Dir at {} is {}".format(app_path, ret))


############## test call:
#print (unzip_app_and_move_contents_to_output_folder("/Users/a391141/a.zip"))


#######################################################################################################################################################
############## Funtion to rename file
############## input = original filename:String, target filename: String
############## output = -
def rename_file(source_name, destination_name):
    if os.path.exists(source_name):
        os.rename(source_name, destination_name)
    else:
        log_error_and_exit("File/Dir at {} not found for renaming file".format(source_name))


############## test call:
# print (rename_file("src_path,dst_path")

#######################################################################################################################################################
############## Funtion to change_permissions 
############## input = filename: String, recursive: Bool
############## output = -
def change_permissions(path, recursive):
    if os.path.exists(path):
        if recursive and os.path.isdir(path):
            for item in os.walk(path):
                os.chmod(item, 755)
        else:
            os.chmod(path, 755)
    else:
        log_error_and_exit("File/Dir at {} not found for changing permissions".format(path))


############## test call:
# print (change_permissions("src_path:String,recursive:Bool")


#######################################################################################################################################################
############## Funtion to check if the keys are present in the output 
############## input = keys : arrayString, output : String
############## output = Bool
def keys_present_in_output(keys, output):
    for key in keys:
        if key in output:
            return False
    return True


############## test call:
# print (keys_present_in_output(["sdf","sdaw","asdadsf"],"asdf, asdfadfasdfasdasdc")

#######################################################################################################################################################
############## Funtion to write contents to a file 
############## input = filename: String, string: String
############## output = -
def write_to_file(file_name, string):
    if os.path.exists(file_name):
        try:
            file_handle = open(file_name, 'w')
            file_handle.write(string)  # python will convert \n to os.linesep
            file_handle.close()  # you can omit in most cases as the destructor will call it
        except Exception as e:
            log_error_and_exit("Error : {}".format(str(e)))
    else:
        log_error_and_exit("File/Dir at {} not found".format(file_name))


############## test call:
# print (keys_present_in_output(["sdf","sdaw","asdadsf"],"asdf, asdfadfasdfasdasdc")

#######################################################################################################################################################
############## Funtion to check if string exists in a file 
############## input = filename: String, string: String
############## output = -
def check_string_exists_in_file(file_name, string):
    if os.path.exists(file_name):
        try:
            with open(file_name) as file:
                return any(string in line.lower() for line in file)
        except Exception as e:
            log_error_and_exit("Error : {}".format(str(e)))
    else:
        log_error_and_exit("File/Dir at {} not found".format(file_name))


#######################################################################################################################################################
############## Funtion to delete lines in a file 
############## input = filename: String, string: String
############## output = -
def delete_line_containing_the_string(file_name, string):
    if os.path.exists(file_name):
        try:
            file_handle = open(file_name, "r+")
            file_contents = file_handle.readlines()
            file_handle.seek(0)
            for line in file_contents:
                if string not in line:
                    file_handle.write(line)
            file_handle.truncate()
            file_handle.close()
        except Exception as e:
            log_error_and_exit("Error : {}".format(str(e)))
    else:
        log_error_and_exit("File/Dir at {} not found".format(file_name))


############## test call:
# delete_line_containing_the_string("/Users/a391141/SecurityTestAutomation/pythonFiles/Constants.py","LOGGING_FOLDER")

#######################################################################################################################################################
############## Funtion to write contents to end of a file 
############## input = filename: String, string: String
############## output = -
def append_line_at_end_of_file(file_name, string):
    if os.path.exists(file_name):
        try:
            with open(file_name, "a") as myfile:
                myfile.write(string)
        except Exception as e:
            log_error_and_exit("Error : {}".format(str(e)))
    else:
        log_error_and_exit("File/Dir at {} not found".format(file_name))

def parse_xml_to_dict(xml_path):
    xmlTree = ET.parse(xml_path)
    root = xmlTree.getroot()
    return XmlDictConfig(root)


#######################################################################################################################################################
#######################################################            iOS Functions          #############################################################
#######################################################################################################################################################

#######################################################################################################################################################
#######################################################            iOS Functions          #############################################################
#######################################################################################################################################################

def get_value_from_plist_for_key(key, plistpath):
    return execute_shell_command("plistbuddy -c \"Print: {}\" {}".format(key, plistpath))
