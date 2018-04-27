#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <errno.h>
#include <locale.h>
#include <uchar.h>

int main(void) {
	setlocale(LC_CTYPE, "");

	// Read the input, to be encoded as multibyte sequence
	char buf[64];
	if (!fgets(buf, sizeof (buf), stdin)) {
		fprintf(stderr, "Error reading in\n");
		return (1);
	}

	// Variable used to 16-bit encoded character
	char16_t c16;
	// zero-initialized mbstate, eg. for saving whether we are in a
	// surrogate pair, or in a specific shift state etc.
	mbstate_t mbs = { 0 };
	// mbrtoc16 converts to an *implementation-defined* encoding.  This
	// happens to be UTF-16 for me on Linux/glibc, at least when setting
	// LC_CTYPE to *.UTF-8
	for (size_t n, i = 0; (n = mbrtoc16(&c16, &buf[i], sizeof (buf) - i, &mbs));) {
		if (n == (size_t)-3) { continue; } // surrogate pair
		if (n == (size_t)-2) {
			fprintf(stderr, "Incomplete multibyte char\n");
			break;
		}
		if (n == (size_t)-1) {
			perror("mbrtoc16");
			break;
		}

		if( c16 >= -128 && c16 <= 127 ) {
			// Print ASCII character
			printf("%c", c16);
		} else {
			printf("\\\\u%d\\\\'3f", c16);
		}

		i += n;
	}
}
