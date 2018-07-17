################################
################################
################################    file
################################
################################
''''
import re

with open("/Users/a391141/Desktop/test.txt","r") as file:
    file.seek(0,0)
    test = file.read()
    test = re.search(r"vXC|vad",test)
    print(test)

disneyLand = ('Minnie Mouse', 'Donald Duck', 'Daisy Duck', ['Goofy', 'Goofy'])
disneyLand2 = set(['Minnie Mouse', 'Donald Duck', 'Daisy Duck', 'Goofy', 'Goofy'])
disneyLand2 = list(disneyLand2)
print(type(disneyLand2))
#disneyLand.add(disneyLand2)
for ele in disneyLand2:
    print(ele)
'''
'''
################################
################################
################################    decorator
################################
################################
def our_decorator(func):
    print("before wrapper")
    def function_wrapper(x):
        print("Before calling " + func.__name__)
        func(x)
        print("After calling " + func.__name__)

    return function_wrapper


def foo(x):
    print("Hi, foo has been called with " + str(x))


print("We call foo before decoration:")
foo("Hi")

print("We now decorate foo with f:... this is going to assign decorator return function-variable to variable")
foos = our_decorator(foo)
print("decoration complete")

print("We call foo after decoration:... now the 'funciton_wrapper' is called as it is what is assigned to the variable")
foos(42)
'''

def f(x):
    def g(y):
        x=9
        return y + x + 3
    return g

nf1 = f(1)
nf2 = f(3)

print(nf1(1))
print(nf2(1))