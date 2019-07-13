#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "output.h"
double norm2(double *c,int n){
	double sum =0;
	for(int i=0;i<n-1;i++){
		sum += c[i]*c[i];
	}
	return sqrt(sum);
}
void main(){
	clock_t start, end;
	double cpu_time_used;
	double *A = (double*)malloc(1000*1000*sizeof(double));
	randomT2(A);
	double *B = (double*)malloc(1000*sizeof(double));
	B[0]=0.5;
	for(int i=1;i<999;i++){
		B[i]=B[i-1]*(-1);
	}
	double *C = (double*)malloc(1000*sizeof(double));
	start = clock();
	for(int i=0;i<999;i++){
		for(int j=0;j<999;j++){
			C[j] += A[j*1000+i]*B[i];	
		}
	}

	end = clock();
	cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
	outputT2(norm2(C,1000),cpu_time_used);
	free(A);
	free(B);
	free(C);
}
