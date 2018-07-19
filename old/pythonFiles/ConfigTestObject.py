class ConfigTestObject:
 	"""docstring for ClassName"""
	ID = ""
 	title = ""
 	command = ""
 	verification_keys = ""
 	description = ""

 	def __init__(self, title,command, verification_keys, description):
 		self.title = title
 		self.command = command
 		self.verification_keys = verification_keys
 		self.description = description

 	def return_verification_keys_list():
 		return self.verification_keys.split()

 	def 