#include <stdio.h>
#include <stdlib.h>

long dateToInt( int, int, int );
int* intToDate( long );

int main( int argc, char* argv[] ) {
    char buf;
    //date[0]=year, date[1]=month, date[2]=day
    char date[3][5];
    
    for( int i = 0, j = 0, k = 0; argv[ 1 ][ k ] != '\0'; ++k ) {
        switch( argv[ 1 ][ k ] ) {
            case '-':
                date[ j ][ i ] = '\0';
                i = 0;
                ++j;
                break;
            
            default:
                date[ j ][ i ] = argv[ 1 ][ k ];
                ++i;
                date[ j ][ i ] = '\0';
                break;
        }
    }

    int d = atoi( date[ 2 ] );
    int m = atoi( date[ 1 ] );
    int y = atoi( date[ 0 ] );
    int off = atoi( argv[ 2 ] );

    int* res = intToDate( dateToInt( y, m, d ) + off );
    printf( "%d-%02d-%02d", res[ 0 ], res[ 1 ], res[ 2 ] );

    return 0;
}

long dateToInt( int y, int m, int d ) {
    m = ( m + 9 ) % 12;
    y = y - m/10;

    return 365*y + y/4 - y/100 + y/400 + (m*306 + 5)/10 + (d-1);
}

int* intToDate( long g ) {
    int* res = malloc( 3 * sizeof(int) );
    int y, mm, dd;

y = (10000*g + 14780)/3652425;
int ddd = g - (365*y + y/4 - y/100 + y/400);
if (ddd < 0) {
 y = y - 1;
 ddd = g - (365*y + y/4 - y/100 + y/400);
}
int mi = (100*ddd + 52)/3060;
mm = (mi + 2)%12 + 1;
y = y + (mi + 2)/12;
dd = ddd - (mi*306 + 5)/10 + 1;

    res[ 0 ] = y; res[ 1 ] = mm; res[ 2 ] = dd;
    return res;
}