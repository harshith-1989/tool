from datetime import datetime
import os

import Constants

def prepare_logging_directory():
	current_datetime = datetime.now().strftime("%Y:%m:%d_%H-%M-%S")
	try:
		os.mkdir("{}/{}".format(Constants.LOGGING_FOLDER,current_datetime))
		return "{}/{}".format(Constants.LOGGING_FOLDER,current_datetime)
	except Exception as e:
		print (str(e))
		return

