import re

from RegexExpressions import *
from HelperFunctions import *
import Constants


def check_signing_info(verification_keys=None, original_folder_path=None):
    # execute the shell command to check the print the certificate contents
    # return boolean by checking if the signing key is debug key from the shell command execution output

    execution_output_from_shell_command = execute_shell_command(
        "keytool -printcert -file {}/META-INF/CERT.RSA".format(original_folder_path))

    if verification_keys in execution_output_from_shell_command['OUTPUT']:
        logging.info("App signed using a debug key")
        return "{} found in signing key. App signed using a debug keystore\n".format(verification_keys)
    else:
        logging.info("App signed using a debug key")
        return "{} not found in signing key. App not signed using a debug keystore\n".format(verification_keys)


def android_xml_content_verification(android_manifest_xml_path=None):
    # read the contents of the manifest xml into a variable
    # get the regex from the regex file
    # check for each regex expression
    # fill the execution_output variable with the result of the regex matches
    # return the value

    with open(android_manifest_xml_path, 'r') as file:
        # read android manifest xml file into string variable
        android_xml_file_contents = file.read()
    execution_output = ""
    verification_keys = get_manifest_xml_regex()

    for key in verification_keys.keys():
        regex_expression_variable = re.compile(verification_keys[key])

        if Constants.ANDROID_EXPORTED_KEY in key:
            component = 0
            component_name = 1
            for application_components in regex_expression_variable.findall(android_xml_file_contents):
                logging.info("{} with name {} has android:exported set to true".format(application_components[component],application_components[component_name]))
                execution_output = "{}\n{} with name {} has android:exported set to true".format(execution_output,application_components[component],application_components[component_name])

        elif Constants.ANDROID_PROTECTION_LEVEL_KEY in key:
            permission_name = 0
            protection_level = 1
            for permission in regex_expression_variable.findall(android_xml_file_contents):
                if permission[protection_level] != Constants.ANDROID_PROTECTION_VALUE_SIGNATURE:
                    logging.info("permission with name {} has android:protectionlevel set to {}".format(permission[permission_name],permission[protection_level]))
                    execution_output = "{}\npermission with name {} has android:protectionlevel set to {}".format(execution_output,permission[permission_name],permission[protection_level])

        else:
            for regex_matches in regex_expression_variable.findall(android_xml_file_contents):
                logging.info("{} set to true : {}".format(key, regex_matches))
                execution_output = "{}\n{} set to true : {}".format(execution_output,key, regex_matches)

    if len(execution_output) == 0:
        logging.info("No issues foung in {}".format(android_manifest_xml_path))
        execution_output = "No issues foung in {}".format(android_manifest_xml_path)

    return execution_output


def check_permissions(android_manifest_xml_path=None):
    standard_android_permission_file_path = "{}/{}".format(Constants.ROOT_FOLDER, "pythonFiles/Permissionsfile.txt")

    # construct regex to match the user features/permissions
    regex_string_for_matching_permissions_and_features_in_android_manifest_xml = get_permissions_regex()
    permissions_list_from_android_xml_path = re.compile(
        regex_string_for_matching_permissions_and_features_in_android_manifest_xml)

    execution_output = ""
    android_xml_file_contents = ""

    # Constants
    permission_or_feature_id = 0
    permission_or_feature_name = 1

    with open(android_manifest_xml_path, 'r') as file:
        # read android manifest xml file into string variable
        android_xml_file_contents = file.read()

    # iterate over every permissions and feature from android manifest xml
    for permission_or_feature in permissions_list_from_android_xml_path.findall(android_xml_file_contents):

        with open(standard_android_permission_file_path, 'r') as standard_android_permission_file:
            # open standard permissions file and iterate over every permission in it
            for standard_android_permission in standard_android_permission_file.read().split('::'):
                # if the permission matches any entry in the permissions file, log it
                if (standard_android_permission.split(':')[permission_or_feature_id] in
                        permission_or_feature[permission_or_feature_name]):

                    logging.info("{} name : {} present in android_manifest.xml file".format(
                        permission_or_feature[permission_or_feature_id],
                        permission_or_feature[permission_or_feature_name])
                    )

                    execution_output = "{}\n{} name : {} present in android_manifest.xml file".format(
                        execution_output,
                        permission_or_feature[permission_or_feature_id],
                        permission_or_feature[permission_or_feature_name]
                    )
                    # skip to next iteration if entry found
                    break
            if permission_or_feature[permission_or_feature_name] not in execution_output:
                # if no matches found, log the custom permission
                logging.info("{} name : {} is a custom-permission /feature present in android_manifest.xml file".format(
                    permission_or_feature[permission_or_feature_id],
                    permission_or_feature[permission_or_feature_name])
                )

                execution_output = "{}\n{} name : {} is custom-permission/feature present in android_manifest.xml file".format(
                    execution_output,
                    permission_or_feature[permission_or_feature_id],
                    permission_or_feature[permission_or_feature_name]
                )

    if len(execution_output) == 0:
        logging.info("No permissions entries found")
        execution_output = "No permissions entries found\n"

    return execution_output


def check_smali_files(smali_folder_path=None):
    # check for the extension of the files if any other file is present other than that with smali extension
    execution_output = ""

    for root, subdirs, files in os.walk(smali_folder_path):
        logging.info("Checking folder : {}".format(root))

        for file in files:

            if "smali" not in file:
                logging.info("{}/{} is not a smali file".format(root, file))
                execution_output = "{}\n{}/{} is not a smali file\n".format(execution_output, root, file)

    if len(execution_output) == 0:
        logging.info("No unencrypted files found")
        execution_output = "No unencrypted files found\n"

    return execution_output


def check_assets_folder(assets_folder_path=None):
    for assets_folder_content in os.listdir(assets_folder_path):
        absolute_path_of_assets_folder_content = "{}/{}".format(assets_folder_path,assets_folder_content)
        # check if any of them are directories

        if os.path.isdir(absolute_path_of_assets_folder_content):
            logging.info("{} is not a zip, listing contents...".format(absolute_path_of_assets_folder_content))
            sub_folder_contents = []
            # if they are walk through them and print the contents

            for root,subdirs,files in os.walk(absolute_path_of_assets_folder_content):
                if len(files) != 0:
                    if any(".js" in file or ".css" in file or ".html" in file for file in files):
                        sub_folder_contents.append("\nFiles present in directory : {}".format(root))
                        sub_folder_contents.append("{}".format('\n'.join(files)))
            logging.info("\n{}\n".format("\n".join(sub_folder_contents)))

        elif os.path.isfile(absolute_path_of_assets_folder_content):
            clear_directory(Constants.TMP_FOLDER)
            # if they are not, look for zip files

            if absolute_path_of_assets_folder_content.endswith(("zip","rar","tar.gz","tar.BZ2","tar.XZ","tar")):
                # unzip the files into tmp folder
                unzip_status = unzip_to_folder(absolute_path_of_assets_folder_content,Constants.TMP_FOLDER)

                if unzip_status == Constants.ENCRYPTED or unzip_status == Constants.CORRUPT or unzip_status == Constants.NOT_A_ZIP:
                    logging.info("{} is {}".format(absolute_path_of_assets_folder_content,unzip_status))
                else:
                    # if unzip successful, print the contents
                    logging.info("{} unzipped, listing contents...".format(absolute_path_of_assets_folder_content))
                    sub_folder_contents = []

                    for root, subdirs, files in os.walk(Constants.TMP_FOLDER):
                        if len(files) != 0:
                            if any(".js" in file or ".css" in file or ".html" in file for file in files):
                                sub_folder_contents.append("{}".format('\n'.join(files)))
                    logging.info("\n{}\n".format("\n".join(sub_folder_contents)))

        else:
            logging.info("{} is individual file".format(absolute_path_of_assets_folder_content))


def check_res_xml_config_file(res_config_file_path=None):
    # read the contents of the config.xml file into a variable
    # get the regex expressions from the regex expressions file
    # check for matches from the regex expressions file
    # return the match results
    execution_output = ""

    with open(res_config_file_path, 'r') as file:
        # read config xml file into string variable
        config_xml_file_contents = file.read()
    regex_expressions = res_config_xml_regex()

    for regex_expression_key in regex_expressions.keys():
            regex_expression = re.compile(regex_expressions[regex_expression_key])

            for regex_match in regex_expression.findall(config_xml_file_contents):

                if Constants.ACCESS_ORIGIN_KEY == regex_expression_key:
                    logging.info("{} is set for access origin".format(regex_match))
                    execution_output = "{}\n{} is set for access origin".format(execution_output,regex_match)

                elif Constants.ALLOW_INTENT_KEY == regex_expression_key:

                    if Constants.ALLOW_INTENT_HTTPS == regex_match:
                        logging.info("{} is set for allowing https access".format(regex_match))
                        execution_output = "{}\n{} is set for https access".format(execution_output,regex_match)

                    elif Constants.ALLOW_INTENT_HTTP == regex_match:
                        logging.info("{} is set for allowing http access".format(regex_match))
                        execution_output = "{}\n{} is set for http access".format(execution_output,regex_match)

                elif Constants.ALLOW_INTENT_NAVIGATION_KEY == regex_expression_key:
                    logging.info("{} is set for allowing navigation".format(regex_match))
                    execution_output = "{}\n{} is set for allowing navigation".format(execution_output,regex_match)

    return execution_output


def check_res_folder(res_folder_path=None):
    # if config.xml file is present call the corresponding function
    # if network_security.xml file is present call the corresponding function
    execution_output = []

    res_config_file_path = "{}/xml/config.xml".format(res_folder_path)
    res_network_security_config_file_path = "{}/xml/network_security_config.xml".format(res_folder_path)

    if os.path.exists(res_config_file_path):
        execution_output.append(check_res_xml_config_file(res_config_file_path))
    else:
        logging.info("{} not found".format(res_config_file_path))
        execution_output.append("{}\n{} is not found".format(execution_output, res_config_file_path))

    if os.path.exists(res_network_security_config_file_path):
        pass
    else:
        logging.info("{} not found".format(res_network_security_config_file_path))
        execution_output.append("{}\n{} is not found".format(execution_output, res_network_security_config_file_path))

    return "\n".join(execution_output)


def check_lib_folder(lib_folder_path=None):
    print(lib_folder_path)
    pass
    # iterate over the contents and check if they can be decompiled


def execute_tests(test_dictionary):
    # iterate over the folder structure in the output folder
    # match the name of the folder from the test dictionary and execute tests if the test-folder is present
    # add the result to the test dictionary with result as the key
    # return the dictionary
    folders_array = test_dictionary['Folder']
    execution_result = ""
    for folder in folders_array:

        if folder['FolderName'] in Constants.ORIGINAL_FOLDER:
            logging.info("*********\n******** original Folder Check *************\n\n")
            original_folder_path = "{}/{}".format(Constants.APKTOOL_OUTPUT_FOLDER, Constants.ORIGINAL_FOLDER)

            if os.path.exists(original_folder_path):
                execution_result = check_signing_info(folder['verification_keys'], original_folder_path)
            else:
                logging.info("{} folder not found".format(Constants.ORIGINAL_FOLDER))
                execution_result = "{} folder not found".format(Constants.ORIGINAL_FOLDER)

        elif folder['FolderName'] in Constants.ANDROID_MANIFEST:
            logging.info("*********\n******** AndroidManifest xml Check *************\n\n")
            android_manifest_xml_path = "{}/{}".format(Constants.APKTOOL_OUTPUT_FOLDER, "AndroidManifest.xml")

            if os.path.exists(android_manifest_xml_path):
                execution_result = android_xml_content_verification(android_manifest_xml_path)
            else:
                log_error_and_exit("{} not found to verify the manifest xml contents".format(android_manifest_xml_path))

        elif folder['FolderName'] in Constants.PERMISSIONS_ANDROID_MANIFEST:
            logging.info("*********\n******** permissions Check *************\n\n")
            android_manifest_xml_path = "{}/{}".format(Constants.APKTOOL_OUTPUT_FOLDER, "AndroidManifest.xml")

            if os.path.exists(android_manifest_xml_path):
                execution_result = check_permissions(android_manifest_xml_path)
            else:
                log_error_and_exit("{} not found to verify the manifest xml permissions".format(android_manifest_xml_path))

        elif folder['FolderName'] in Constants.SMALI_FOLDER:
            logging.info("*********\n******** smali Folder Check *************\n\n")
            smali_folder_path = "{}/{}".format(Constants.APKTOOL_OUTPUT_FOLDER, Constants.SMALI_FOLDER)
            if os.path.exists(smali_folder_path):
                execution_result = check_smali_files(smali_folder_path)
            else:
                logging.info("{} folder not found".format(Constants.SMALI_FOLDER))
                execution_result = "{} folder not found".format(Constants.SMALI_FOLDER)

        elif folder['FolderName'] in Constants.ASSETS_FOLDER:
            logging.info("*********\n******** Assets Folder Check *************\n\n")
            assets_folder_path = "{}/{}".format(Constants.APKTOOL_OUTPUT_FOLDER,Constants.ASSETS_FOLDER)

            if os.path.exists(assets_folder_path):
                execution_result = check_assets_folder(assets_folder_path)
            else:
                logging.info("{} folder not found".format(Constants.ASSETS_FOLDER))
                execution_result = "{} folder not found".format(Constants.ASSETS_FOLDER)

        elif folder['FolderName'] in Constants.RES_FOLDER:
            logging.info("*********\n******** res Folder Check *************\n\n")
            res_folder_path = "{}/{}".format(Constants.APKTOOL_OUTPUT_FOLDER, Constants.RES_FOLDER)

            if os.path.exists(res_folder_path):
                execution_result = check_res_folder(res_folder_path)
            else:
                logging.info("{} folder not found".format(Constants.RES_FOLDER))
                execution_result = "{} folder not found".format(Constants.RES_FOLDER)

        elif folder['FolderName'] in Constants.LIB_FOLDER:
            logging.info("*********\n******** lib Folder Check *************\n\n")
            lib_folder_path = "{}/{}".format(Constants.APKTOOL_OUTPUT_FOLDER,Constants.LIB_FOLDER)

            if os.path.exists(lib_folder_path):
                execution_result = check_lib_folder(lib_folder_path)
            else:
                logging.info("{} folder not found".format(Constants.LIB_FOLDER))
                execution_result = "{} folder not found".format(Constants.LIB_FOLDER)



        folder['execution_result'] = execution_result
