#include <sys/time.h>
#include <openacc.h>
#include <stdlib.h>
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

double simpsion(int npartitions){
	double h;
	h=(double)100/npartitions;
	double sum = 0;
#pragma acc parallel loop reduction(+:sum)
	for(int i =0;i<npartitions+1;i++){
		sum+=getCoefficient(i,npartitions)*FUN(i*h);
	
	}
	return sum*h/48;
}

int main(int argc,char *argcv[]){
	struct timeval start1,end1;
	double cpu_time;
	int npartitions;
	read(argc,argcv,&npartitions);

	gettimeofday(&start1,NULL);
	double res = simpsion(npartitions);

	gettimeofday(&end1,NULL);
	cpu_time = ((double)(end1.tv_usec-start1.tv_usec))/1000000;

	printf("%.15f %.15f\n",fabs(res-32.121040666358),res);
	printf("%f ms\n" ,cpu_time);
}

