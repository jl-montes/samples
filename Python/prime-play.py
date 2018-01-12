'''
Python program to generate prime numbers
'''

import sys

def show_msg():
    Msg = "You enter a number, and we'll check if numbers between 1 and your number is a prime number"
    print("*" * len(Msg))
    print(Msg)
    

if len(sys.argv) ==  2: # Two arguments passed, take index 1 as integer
    value  = int(sys.argv[1])
else:
    show_msg()
    value = int(input("Enter a numeric value: "))

print('\nPrimes Numbers between 1 and ', value)

counter = 0
for outer in range(2, value):
    for inner in range(2, outer):
        if not outer % inner:
            #print(outer, '=', inner, '*', int(outer / inner))
            break
    else:
        #print(outer, 'is prime')
        print('{:>7d}'.format(outer), end=' ')
        counter += 1
        if counter % 15 == 0:
            print()

print("\n\nThe total number of detected primes =", counter)

