#include <thrust/device_vector.h>
#include <sys/time.h>
#include <thrust/transform_reduce.h>
#include <stdlib.h>
#include <iostream>
#include <math.h>
#include <thrust/scan.h>
#define FUN(x) exp(sin(x))*cos(x/40)
#include <thrust/iterator/zip_iterator.h>
void read(int argc,char* arcgv[], int *npartitions){
	if( argc == 2){
		*npartitions=atoi(arcgv[1]);
	}else{
		printf("Argument donnot enough!");
	}
}

__host__  __device__ int getCoefficient(int num,int npartitions){
	int coeff[]={17,59,43,49,48};
	if(num<4)
	{
		return coeff[num];
	}else if(num>npartitions-4){
		return coeff[npartitions-num];
	}else
	{return 48;}
}


struct simp
{
	simp(double t){h =(double) (100/t);}
	double h;
	__host__ __device__
	double operator()(thrust::tuple<int,int> t){
		int coe,index;
		thrust::tie(index,coe)=t;
		return coe*FUN((double)(index*h));	
	}
};

int main(int argc,char *argcv[]){
	struct timeval start1,end1;

	int npartitions;
	double cpu_time;
	read(argc,argcv,&npartitions);

	simp calc(npartitions);
  	thrust::plus<double> binary_op;
        double init = 0;




	gettimeofday(&start1,NULL);
	thrust::device_vector<int> coe(npartitions,48);
	coe[0]=17;coe[npartitions-1]=17;
	coe[1]=59;coe[npartitions-2]=59;
	coe[2]=43;coe[npartitions-3]=43;
	coe[4]=49;coe[npartitions-4]=49;

	thrust::device_vector<int> index(npartitions,1);
	index[0]=0;
	thrust::inclusive_scan(index.begin(),index.end(),index.begin());

	double rest=thrust::transform_reduce(
			thrust::make_zip_iterator(thrust::make_tuple(index.begin(), coe.begin())),
			thrust::make_zip_iterator(thrust::make_tuple(index.end(), coe.end())),
			simp(npartitions),init,binary_op);

	rest = rest*100/npartitions/48;
	gettimeofday(&end1,NULL);
	cpu_time = ((double)(end1.tv_usec-start1.tv_usec))/1000000;
	std::cout.precision(15);
	std::cout<<rest-32.121040666358<<'\t'<<rest<<std::endl;
	std::cout.precision(6);
	std::cout<<cpu_time<<std::endl;

//	printf("%.15f %.15f\n",fabs(res-32.121040666358),res);
//	printf("%f ms\n" ,cpu_time);
}

