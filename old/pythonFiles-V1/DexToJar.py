import os

def set_length_check(file_name):
    if len(set(file_name)) <= 2:
        print("obfuscations set_length_check")

        return 1

    else:
        return -1

def check_if_any_alphabet_repeated_continuosly_more_than_twice(file_name):
    check_value = 0
    for i in range(len(file_name) - 3):
        if file_name[i + 1] == file_name[i] == file_name[i + 2]:
            check_value += 1
    return check_value

def check_for_special_characters(file_name):
    spl_chars = "#$%^&*();:?<>,`~\\/{}|\""
    check_value = 0
    for character in spl_chars:
        if character in file_name:
            check_value += 1
    return check_value

def check_for_consecutive_triplets(file_name):
    lines = ["`1234567890-=", "uiop[]", "asdfghjkl;'\\", "<zxcvbnm,./", "abcdfgehijklmnopqrstvuwxyz",
             "aabbccddffgghhiieejjkkllmmnnooppqqrrssttuuvvwwxxyyzz","zzyyxxwwuuvvttssrrqqppnnmmllkkjjooiieehhggffddccbbaa"]
    check_value = 0
    triples = []
    for line in lines:
        for i in range(len(line)):
            if i+2 <= len(line):
                triples.append(line[i:i + 3])
    for triple in triples:
        if triple in file_name:
            print(file_name)
            print(triple)
            check_value += 1

    return check_value

def check_for_doublets(file_name):
    lines = ["hhjjqq uuvvwwxxyyzz"]
    check_value = 0
    triples = []
    for line in lines:
        for i in range(len(line)):
            if i+2 <= len(line):
                triples.append(line[i:i + 2])

    for triple in triples:
        if triple in file_name:
            print(file_name)
            print(triple)
            check_value += 1

    return check_value

def check_for_obfuscation(d2j_output_directory):
    for root,subdir,files in os.walk(d2j_output_directory):
        if len(files) != 0:
            for file in files:
                check_value = 0
#                print(file)
                check_value += set_length_check(file)
#                if check_value > 0: print(check_value)
                check_value += check_for_consecutive_triplets(file)
#                if check_value > 0: print(check_value)
                check_value += check_for_special_characters(file)
#                if check_value > 0: print(check_value)
                check_value += check_if_any_alphabet_repeated_continuosly_more_than_twice(file)
#                if check_value > 0: print(check_value)
                check_value += check_for_doublets(file)
#                if check_value > 0: print(check_value)



                if check_value > 1:
                    print(f"{file} - {check_value}")
                    pass

# check in names of files
# check for consecutive numbers, alphabets
# check for ascii ranges, only smallcase or only uppercase
# propERTy,bUTTon,cONNector, draWER, geSTUre, suPPOrt, EFFect
check_for_obfuscation("/Users/a391141/SecurityTestAutomation/output/d2j")


