#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void outputT1(int i) {
	printf("%d\n", i);
}


// For simplicity's sake, we'll go with random values -100 from 100
void randomT2(double* matrix) {
	srand(time(NULL));
	for (size_t i = 0; i < (1000*1000); i++) {
		matrix[i] = -100.0 + (double)rand() / ((double)RAND_MAX / 200.0 + 1.0);
	}
}


void outputT2(double norm2, double timing) {
    printf("norm two:     %f\n", norm2);
	printf("elapsed time: %f ms\n", timing);
}
