"""
import turtle
from HelperFunctions import *

def generate_fibonacci_series(n):
    fib_array = [0,1]
    end_number = 0
    while(n>end_number):
        fib_array.append(fib_array[end_number]+fib_array[end_number+1])
        end_number+=1

    return fib_array

def draw_fibonacci(arr,index):
    if arr[index]!=0:
        n = arr[index]
        prevn = arr[index - 1]
        if index % 2 == 0:
            turtle.right(90)
            turtle.forward(n * 20)
            turtle.right(90)
            turtle.forward(n * 20)
            turtle.right(90)
            turtle.forward(n * 20)
            turtle.right(90)
            turtle.forward(n * 20)
            turtle.right(90)
            turtle.forward(n * 20)
        else:
            turtle.right(90)
            turtle.forward(n * 20)
            turtle.right(90)
            turtle.forward(n * 20)
            turtle.right(90)
            turtle.forward(n * 20)
            turtle.right(90)
            turtle.forward(n * 20)
            turtle.right(90)
            turtle.forward(n * 20)
        '''
        if index % 2 == 0:
            turtle.right(90)
            turtle.forward(n * 10)
            turtle.right(90)
            turtle.forward(n * 10)
            turtle.right(90)
            turtle.forward(n * 10)
            turtle.right(90)
            turtle.forward(n * 10)
            turtle.right(90)
            turtle.forward(n * 10)
        else:
            turtle.right(90)
            turtle.forward(n * 10)
            turtle.right(90)
            turtle.forward(n * 10)
            turtle.right(90)
            turtle.forward(n * 10)
            turtle.right(90)
            turtle.forward(n * 10)
            turtle.right(90)
            turtle.forward(n * 10)'''
        execute_shell_command("screencapture /Users/a391141/Desktop/sc.png")

my_arr = generate_fibonacci_series(7)

for n in range(len(my_arr)):
    draw_fibonacci(my_arr,n)

"""

class Directory:
    directory_structure_file_path = "/Users/a391141/directory.txt"

    def __init__(self):