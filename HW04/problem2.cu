#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include "../randoms/randoms.c"
#include <cuda.h>
#define PI 3.1415926535
#define MAX(a,b) (a>b)?a:b
#define MIN(a,b) (a<b)?a:b
#define WEIGHT(R,i) sqrt((double)(2/(PI*R*R)))*__expf(-2*(i-R)*(i-R)/(R*R))
const int blockwid = 32;
const int blocklen = 32;
const int gridlen = 512;
const int gridwid = 32;
dim3 grid(gridwid,gridlen,1), block(blockwid,blocklen,1);

const int N = gridlen*gridwid;
const int arry_size =16000000;
__global__ void kernel1(double *inarray1,double *inarray2, double *outarray)
{
	int treadid = threadIdx.x+threadIdx.y*blockDim.x+(blockIdx.x+blockIdx.y*gridDim.x)*(blockDim.x*blockDim.y); 
	int treadinbox = threadIdx.x+threadIdx.y*blockDim.x;
	__shared__ double mem[1024];	       
	if(treadid<arry_size){	
		mem[treadinbox]=inarray1[treadid]*inarray2[treadid];
	}else{
		mem[treadinbox]=0;
	}
	__syncthreads();
	int offset = 512;
	while(offset!=0){
		if(treadinbox<offset){
			mem[treadinbox]+=mem[treadinbox+offset];
		}
		__syncthreads();
		offset /=2;
	}
	if(treadinbox == 0){
		outarray[blockIdx.x+blockIdx.y*gridDim.x]=mem[0];
	}
}


void read(int argc,char* arcgv[], int *seed, int *target){
	if( argc == 3){
		*seed=atoi(arcgv[1]);
		*target=atoi(arcgv[2]);
	}else{
		printf("Argument donnot enough!");
	}
}


__global__ void getresult(double *arr,double *result)
{	
	const int nummem = gridlen;
	__shared__ double mem[nummem];
	int treadinbox = threadIdx.x+threadIdx.y*blockDim.x;
	int blockid = blockIdx.x;
	int treadid = blockid*(blockDim.x*blockDim.y)+treadinbox;	
	int offset = nummem/2;
	if(treadid == 0){*result = 0;}
	if(treadid<N){
		mem[treadinbox]=arr[treadid];
	}
	__syncthreads();
	while(offset!=0){
		if(treadinbox<offset){
			mem[treadinbox]+=mem[treadinbox+offset];
		}
		__syncthreads();
		offset/=2;
	}
	if(treadinbox == 0){
		//	printf("%d\n",blockid);

		result[blockid] = mem[0];
		//	printf("%f\n",mem[0]);
	}
}

double hostcalc(double *arr1,double *arr2,int num){
	double result=0;
	for(int i =0;i<num;i++){
		result+=arr1[i]*arr2[i];	
	}
	return result;
}



int main(int argc,char *argcv[]){
	int seed,target;
	read(argc,argcv,&seed,&target);

	double *inArr1 = (double*)malloc(arry_size*sizeof(double));	
	double *inArr2 = (double*)malloc(arry_size*sizeof(double));	
	double *outArr = (double*)malloc(arry_size*sizeof(double));
	double *result = (double*)malloc(sizeof(double)*gridwid);

	double *devInArr1,*devInArr2,*devOutArr, *devresult;
	double final_result=0;

	cudaMalloc((void**)&devInArr1,sizeof(double)*arry_size);
	cudaMalloc((void**)&devInArr2,sizeof(double)*arry_size);
	cudaMalloc((void**)&devOutArr,sizeof(double)*N);
	cudaMalloc((void**)&devresult,sizeof(double)*gridwid);

	//random
	random_doubles(inArr1,-2.0,2.0,arry_size,seed);
	random_doubles(inArr2,-2.0,2.0,arry_size,seed);

	//copy data to device	
	cudaMemcpy(devInArr1,inArr1,sizeof(double)*arry_size,cudaMemcpyHostToDevice);
	cudaMemcpy(devInArr2,inArr2,sizeof(double)*arry_size,cudaMemcpyHostToDevice);

	//calc 
	if(target != 0){
		kernel1 <<<grid,block>>>(devInArr1,devInArr2,devOutArr);
		//get data from device

		getresult<<<gridwid,gridlen>>>(devOutArr,devresult);
		cudaMemcpy(result,devresult,sizeof(double)*gridwid,cudaMemcpyDeviceToHost);
		for(int i =0; i<gridwid;i++){
			final_result+=result[i];
		}
	}else{
		final_result = hostcalc(inArr1,inArr2,arry_size);
	}
	printf("%f",final_result);

	free(inArr1);
	free(inArr2);
	free(outArr);
	free(result);
	cudaFree(devresult);
	cudaFree(devInArr1);
	cudaFree(devInArr2);
	cudaFree(devOutArr);
	return 0;

}
