from HelperFunctions import *
import time

def search_keywords_in_all_files_in_entire_folder(key_list, directory_path):
    for root, subdirs, files in os.walk(directory_path):
        for file in files:
            for key in key_list:
                if check_string_exists_in_file(f"{root}/{file}",key):
                    print(f"{root}/{file} has {key}")



start_time = time.time()
search_keywords_in_all_files_in_entire_folder(["checker"],"/Users/a391141/Downloads/Tool/Tool/testdata/2.2LandingGear/smali")
print(time.time()-start_time)
