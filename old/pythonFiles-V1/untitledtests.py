'''
import commands

isexecutable = commands.getoutput("if [ -x /Users/a391141/Downloads/Tool/tool-23rdNov/SecurityTestAutomation/testdata/2.2LandingGear/lib/arm64-v8a/libsqlc-native-driver.so  ]\nthen echo true\nfi")

if "true" in isexecutable:
    return True
else:
    return False
'''

file = "aassdfsadfasdffffabc;$"
spl_chars = "#$%^&*();:?<>,`~"
stri = "MainActivityIndicator"

if len(set(stri)) < len(stri)-4:
    print("something wrong")

for i in range(len(file)-3):
    if file[i+1] == file[i] == file[i+2]:
        print(f"{file[i]} is repeated more than twice")
        break


for character in spl_chars:
    if character in file:
        print(f"{character} in string")


lines = ["`1234567890-=", "qwertyuiop[]", "asdfghjkl;'\\", "<zxcvbnm,./","abcdefghijklmnopqrstuvwxyz","aabbccddeeffgghhiijjkkllmmnnooppqqrrssttuuvvwwxxyyzz"]
triples = []
for line in lines:
    for i in range(len(line)-2):
        triples.append(line[i:i+3])

for triple in triples:
    if triple in file:
        print(f"{triple} found")