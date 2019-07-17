#include <time.h>
#include <stdlib.h>
#include <omp.h>
#include <stdio.h>
#include <math.h>
#define FUN(x) exp(sin(x))*cos(x/40)


void read(int argc,char* arcgv[], int *npartitions){
	if( argc == 2){
		*npartitions=atoi(arcgv[1]);
	}else{
		printf("Argument donnot enough!");
	}
}

int getCoefficient(int num,int npartitions){
	int coeff[]={17,59,43,49,48};
	if(num<4)
	{
		return coeff[num];
	}else if(num>npartitions-4){
		return coeff[npartitions-num];
	}else
	{return 48;}
}


double function(double x)
{
	
	exp(sin(x))*cos(x/40);
}

double simpsion(int npartitions){
	double h,n;
	h=(double)100/npartitions;

	n=npartitions;
	double sum = 0;
#pragma omp parallel for reduction(+:sum)
	for(int i =0;i<npartitions+1;i++){
		sum+=getCoefficient(i,npartitions)*FUN(i*h);
	
	}
	return sum*h/48;
}

int main(int argc,char *argcv[]){
	double cpu_time;
	int npartitions;
	read(argc,argcv,&npartitions);
	double start = omp_get_wtime();
	double res = simpsion(npartitions);
	double end = omp_get_wtime();
	cpu_time = ((double)(end-start))/1000;

	printf("%f\n",res);
	printf("%f ms\n" ,cpu_time);
}

