import threading
from queue import Queue
import requests
import bs4
import time
#import multiprocessing
print_lock = threading.Lock()


#########################
#########################
#########################
#########################
def get_url(current_url):

    with print_lock:
        print("\nStarting thread {}".format(threading.current_thread().name))
    res = requests.get(current_url)
    res.raise_for_status()

    current_page = bs4.BeautifulSoup(res.text,"html.parser")
    current_title = current_page.select('title')[0].getText()

    with print_lock:
        print("{}\n".format(threading.current_thread().name))
        print("{}\n".format(current_url))
        print("{}\n".format(current_title))
        print("\nFinished fetching : {}".format(current_url))

#########################
#########################
#########################
#########################
def process_queue():
    while True:
        current_url = url_queue.get() # at this point the get() function will not
                                      # return anything as the url_queue variable is empty, but waits for a fixed time-out period
                                      # for some value to be input to the url_queue.
                                      # beyond this time out period "queue empty" exception is raised'''
        get_url(current_url)
        url_queue.task_done() # for every queue.get() method, a task_done()
                              # method must be called to indicate the completion of the task or in this case a thread

#########################
#########################
#########################
#########################
# create a queue-array object
url_queue = Queue()

# create a array of "google.com"
url_list = ["https://en.wikipedia.org/wiki/Maxinquaye","https://www.google.com","http://www.facebook.com","https://www.twitter.com"]


# iterate over the array
for i in range(len(url_list)):
    t = threading.Thread(target=process_queue)
    t.daemon = True # the thread is background and exits as soon as the program exits if stuck at some point
    t.start()

# after start all the above initialized threads are waiting in the process_queue function at url_queue.get()

for current_url in url_list:
    url_queue.put(current_url) # as soon as the elements get input to the queue,
                               # the get() function in process_queue is called in all the threads as the iteration proceeds


start = time.time()
'''for url in url_list:
    get_url(url)'''


url_queue.join() # do not proceed till task_done from all the items in the queue is obtained


print(threading.enumerate())

print("Execution time = {0:.5f}".format(time.time() - start))

