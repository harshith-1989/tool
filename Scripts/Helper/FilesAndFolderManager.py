'''

Objectives of this file:
Create & manage directory structures as below
- input
    - iOS
        - <app_name>
            - ipa
            - source
    - Android
        - <app_name>
            - apk
            - source
- output
    - iOS
        - <app_name>
            - ipa_payload
            - classdump
    - Android
        - <app_name>
            - apktool
            - dextojar
- logs
    - <app_name>
        - <date_time>_log
            - <date_time_testname>.log
- src
    - Helper
    - Tests
    - Controller
- config //not sure if required
- other_tools
    - iOS
    - Android
- tmp

1. Create the skeletal structure if not already present, this includes
- input
    - iOS
    - Android
- output
    - iOS
    - Android
- logs
- src
    - Helper
    - Tests
    - Controller
- config //not sure if required
- other_tools
    - iOS
    - Android

2. Create sub-folders if not already present on accepting input, inside the following folders - input,output,tmp & logs
- accept the input
- create app-name folders if not already present
- place the input in the corresponding input folders
- unzip the input and place the output in corresponding folders

'''
