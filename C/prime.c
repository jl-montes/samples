#include <stdio.h>
#include <stdlib.h>
//#include <limits.h>
//#include <inttypes.h>


void print_primes(unsigned long num);


int main (int argc, char *argv[])
{
    int isPrime;
    unsigned long N;
    
    if( argc == 2) {
        N = strtoul(argv[argc-1],NULL,0);       
    }
    else {
        printf("\nPrint all prime numbers between 1 to N");
        printf("\nEnter a value for N: ");
        scanf("%lu",&N);    
    }
    
    /* For every number between 2 to N, check 
 *     whether it is prime number or not */

    print_primes(N);

    return 0;
}
void print_primes(unsigned long num)
{
    int isPrime;
    unsigned long i, j, n;
    
    printf("\nPrime numbers between %d to %lu\n", 1, num);

    for(i = 2, n = 0; i <= num; i++){
        isPrime = 0;
        /* Check whether i is prime or not */
        for(j = 2; j <= i/2; j++){
             /* Check If any number between 2 to i/2 divides I 
 *  *               completely If yes the i cannot be prime number */
             if(i % j == 0){
                 isPrime = 1;
                 break;
             }
        }

        if(isPrime==0 && num != 1) {
            printf("%7lu ",i);
            n++;
            if ( (n % 15) == 0 )
                printf("\n");
        }

    }
    /* getchar(); */
    printf("\n\nTotal prime numbers between 1 and %lu = %lu\n", num, n);

}

