#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "output.h"

//const nRow = 1000;
//const nCol = 1000;


double norm2fct(double *dbl_arr) {
	double norm = 0.0;
	for (int i = 0;i <= 1000;i++) {
		norm = norm + pow(dbl_arr[i],2);
	}
	norm = sqrt(norm);
	return(norm);
}

int main() {
	clock_t start, end;
	double cpu_time_used;

	start = clock();
	double* A = (double*)malloc(1000 * 1000 * sizeof(double));

	randomT2(A);

	double* b = (double*)malloc(1000 * sizeof(double));

	b[0] = 0.5;
	b[1] = -0.5;
	for (int i = 2;i < 999;i++) {
		b[i] = b[i - 2];
	}

	double* c = (double*)malloc(1000 * sizeof(double));

	for (int i = 0;i < 999;i++) {
		for (int j = 0;j < 999;j++) {
			c[i] += A[i * 1000 + j] * b[j];
		}
	}

	end = clock();
	cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;

	outputT2(norm2fct(c),1000 * cpu_time_used);

	free(A);
	return(0);
}
