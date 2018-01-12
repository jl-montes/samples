Msg = "You enter a number, and we'll list a Fibonacci series from 0 up to the number entered"
print("*" * len(Msg))
print(Msg)
value = int(input("Enter a numeric value: "))

def fib(n):
    a, b = 0, 1
    ctr = 0
    while a < n:
        print('{:>5d}'.format(a), end=' ')
        a, b = b, a+b
        ctr += 1
        if ctr % 15 == 0:
            print()
    print('\n# of Fibonacci numbers between 0 and', value, '=', ctr)
    

fib(value)

