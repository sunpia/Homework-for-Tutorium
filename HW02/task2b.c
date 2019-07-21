#include <stdio.h>
#include <stdlib.h>
#include "output.h"

int main(int argc, char* argv[]) {
	if (argc != 2) {
		printf("Need one argument to play.\n");
		exit(1);
	}
	int n = atoi(argv[1]);

	for (int i = 0; i <= n; i++) {
		outputT2(i);
	}
	return 0;
}
