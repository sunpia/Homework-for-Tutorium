#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include "randoms.c"
#include <cuda.h>

#define PI 3.1415926535
#define MAX(a,b) (a>b)?a:b
#define MIN(a,b) (a<b)?a:b
#define WEIGHT(R,i) sqrt((double)(2/(PI*R*R)))*__expf(-2*(i-R)*(i-R)/(R*R))


__global__ void kernel1(double *inarray,double *outarray, int R, int N)
{
	int treadid = threadIdx.x+threadIdx.y*blockDim.x+(blockIdx.x+blockIdx.y*gridDim.x)*(blockDim.x*blockDim.y);  
	if(treadid<N){
		double *temp=(double*)malloc((2*R+1)*sizeof(double));
		for(int i = -R;i<R+1;i++)
		{	
			temp[i+R]=inarray[treadid+i]*WEIGHT(R,i);
		}
		int offset = R*2+1;
		while(offset!=0){
			if (offset%2==1){
				offset /=2;
				for(int i =0;i<offset;i++){
					temp[i]+=temp[i+offset];
				}
				temp[0]+=temp[2*offset+1];
			}else{
				offset/=2;
				for(int i =0;i<offset;i++){
					temp[i]+=temp[i+offset];
				}

			}
		}
		outarray[treadid]=temp[0];
		free(temp);
	}
}

__global__ void kernel2(double *inarray,double *outarray, int R, int N)
{
	//	__shared__ double memor[threadIdx.x+42];

	int treadid = threadIdx.x+threadIdx.y*blockDim.x+(blockIdx.x+blockIdx.y*gridDim.x)*(blockDim.x*blockDim.y);  
	if(treadid<N){
		double temp=0;
		for(int i = -R;i<R+1;i++)
		{	
			temp+=inarray[treadid+i]*WEIGHT(R,i);
		}
		outarray[treadid]=temp;
	}
}


void read(int argc,char* arcgv[], int *N, int *R, int *seed ,int *s){
	if( argc == 5){
		*N=atoi(arcgv[1]);
		*R=atoi(arcgv[2]);
		*seed=atoi(arcgv[3]);
		*s=atoi(arcgv[4]);
	}else{
		printf("Argument donnot enough!");
	}
}

int find2times(int num)
{
	int n = 1;
	while(n<num){
		n*=2;
	}
	return n;
}

__global__ void getresult(double *arr,double *result, int N)
{

	int treadid = threadIdx.x+threadIdx.y*blockDim.x+(blockIdx.x+blockIdx.y*gridDim.x)*(blockDim.x*blockDim.y);  
	int offset = N/2;
	if(treadid<N){
		arr[treadid]=arr[treadid]*arr[treadid];
	}
	while(offset!=0){
		if(treadid<offset){
			arr[treadid]+=arr[treadid+offset];
		}
		__syncthreads();
		offset/=2;
	}
	*result = sqrt((double)(arr[0]));
}

int main(int argc,char *argcv[]){
	//	clock_t start, end;
	//	double cpu_time_used;
	//	start = clock();
	int N,R,seed,s;
	read(argc,argcv,&N,&R,&seed,&s);
	int gridlen = MIN(32, find2times(N/32/32));
	int gridwid = find2times(N/32/32/gridlen);
	dim3 grid(gridwid,gridlen,1), block(32,32,1);

	double *inArr = (double*)malloc(N*sizeof(double));	
	double *outArr = (double*)malloc(N*sizeof(double));
	double *devInArr,*devOutArr,*result, *devresult;
	result = (double*)malloc(sizeof(double));
	cudaMalloc((void**)&devInArr,sizeof(double)*N);
	cudaMalloc((void**)&devOutArr,sizeof(double)*N);
	cudaMalloc((void**)&devresult,sizeof(double));

	//random
	random_doubles(inArr,-1.0,1.0,N,seed);
	//copy data to device	
	cudaMemcpy(devInArr,inArr,sizeof(double)*N,cudaMemcpyHostToDevice);
	//calc 
	if(s==0){	
		kernel1 <<<grid,block>>>(devInArr,devOutArr,R,N);
	}else{
		kernel2 <<<grid,block>>>(devInArr,devOutArr,R,N);
	}
	cudaError_t error_check = cudaGetLastError();
	if( error_check != cudaSuccess ){
		printf("%s\n" , cudaGetErrorString( error_check ) );
		system("pause") ;
		return 0 ;
	}    



	//get data from device

	getresult<<<grid,block>>>(devOutArr,devresult,N);
	cudaMemcpy(result,devresult,sizeof(double),cudaMemcpyDeviceToHost);

	printf("%f",*result);


	free(inArr);
	free(outArr);
	free(result);
	cudaFree(devresult);
	cudaFree(devInArr);
	cudaFree(devOutArr);
	return 0;

}
