import Constants

#REGEX EXPRESSIONS
#MANIFEST FILE
PERMISSIONS_REGEX = 'uses-(.*) android:name=(.*)/'
PERMISSIONS_PROTECTION_LEVEL = 'permission android:name="(.*)" android:protectionLevel="(.*)"'
ANDROID_DEBUGGABLE = 'android:*debuggable\s*=\s*"*true"*'
ANDROID_ALLOW_BACKUP = 'allowBackup\s*=\s*"*true"*'
ANDROID_FULL_BACKUP_CONTENT = 'android:*fullBackupContent\s*=\s*"true"*'
ANDROID_EXPORTED = '<([a-zA-Z]*) .*android:exported="true" .*android:name="([a-zA-Z.]*)"'
#ANDROID_EXPORTED = '<([a-zA-Z]*) .*android:name="([a-zA-Z.]*)" .*android:exported="true"'

#RES FOLDER CONFIG.XML
ACCESS_ORIGIN = 'access .*origin=.*"(.*)"'
ALLOW_INTENT_HTTP_HTTPS = 'allow-intent href="(.*)"'
ALLOW_INTENT_NAVIGATION = 'allow-navigation href="(.*)"'

#OBFUSCATION FORMATS
PROGUARD_OBFUSCATION = '\.*f\d*\.'




def get_permissions_regex():
    return PERMISSIONS_REGEX

def get_manifest_xml_regex():
    regex_dict = {}
    regex_dict[Constants.ANDROID_DEBUGGABLE_KEY] = ANDROID_DEBUGGABLE
    regex_dict[Constants.ANDROID_ALLOW_BACKUP_KEY] = ANDROID_ALLOW_BACKUP
    regex_dict[Constants.ANDROID_FULL_BACKUP_CONTENT_KEY] = ANDROID_FULL_BACKUP_CONTENT
    regex_dict[Constants.ANDROID_EXPORTED_KEY] = ANDROID_EXPORTED
    regex_dict[Constants.ANDROID_PROTECTION_LEVEL_KEY] = PERMISSIONS_PROTECTION_LEVEL

    return regex_dict

def res_config_xml_regex():
    regex_dict = {}
    regex_dict[Constants.ACCESS_ORIGIN_KEY] = ACCESS_ORIGIN
    regex_dict[Constants.ALLOW_INTENT_KEY] = ALLOW_INTENT_HTTP_HTTPS
    regex_dict[Constants.ALLOW_INTENT_NAVIGATION_KEY] = ALLOW_INTENT_NAVIGATION

    return regex_dict