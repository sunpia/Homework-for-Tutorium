#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include "../randoms/randoms.c"
#include <cuda.h>
#define PI 3.1415926535
#define MAX(a,b) (a>b)?a:b
#define MIN(a,b) (a<b)?a:b
#define WEIGHT(R,i) sqrt((double)(2/(PI*R*R)))*__expf(-2*(i-R)*(i-R)/(R*R))


__global__ void kernel1(double *inarray,double *outarray, int R, int N)
{
	int treadid = threadIdx.x+threadIdx.y*blockDim.x+(blockIdx.x+blockIdx.y*gridDim.x)*(blockDim.x*blockDim.y);  
	if(treadid<N){
		double temp=0;
		for(int i = -R;i<R+1;i++)
		{	
			if(treadid+i>=0 && treadid+i<N)
			{	
				temp+=inarray[treadid+i]*WEIGHT(R,i);
			}
		}
		outarray[treadid]=temp;
	}
}

__global__ void kernel2(double *inarray,double *outarray, int R, int N)
{
	int blockid = blockIdx.x+blockIdx.y*gridDim.x;  
	int treadinbox =threadIdx.x+threadIdx.y*blockDim.x;
	const int Num=2*R+1;
	__shared__ double mem[42];
	if(blockid<N){
		int i = treadinbox-R;
		if(blockid+i>=0 && blockid+i<N)
		{	
			mem[treadinbox]=inarray[blockid+i]*WEIGHT(R,i);
		}else{
			mem[treadinbox]=0;
		}
	}
	__syncthreads();

	if(blockid<N){

	int offeset = Num;

	while(offeset != 1){
		if(offeset%2==1){
			offeset /=2;
			if(treadinbox==0){mem[0]+=mem[2*offeset];}
		}else{
			offeset /=2;
		}
		if(treadinbox<offeset){mem[treadinbox]+=mem[treadinbox+offeset];}
		__syncthreads();
	}
	outarray[blockid]=mem[0];
	}
	/*	const int size = 1024;
		__shared__ double mem[size+42];
		int treadinbox =threadIdx.x+threadIdx.y*blockDim.x;
		int treadid = threadIdx.x+threadIdx.y*blockDim.x+(blockIdx.x+blockIdx.y*gridDim.x)*(blockDim.x*blockDim.y);  
		if(treadid<N){
		mem[21+treadinbox] = inarray[treadid];
		if(treadinbox<R){
		if(treadid-R>0){
		mem[21-R+treadinbox] = inarray[treadid-R];	
		}else{
		mem[21-R+treadinbox] = 0;
		}
		}
		if(treadinbox>size-R-1){
		if(treadid+R<N){
		mem[treadinbox+R+21] = inarray[treadid+R];
		}else{
		mem[R+treadinbox+21] = 0;
		}
		}
		}
		__syncthreads();
		if(treadid<N){
		double temp=0;
		for(int i = -R;i<R+1;i++)
		{	
		temp+=mem[treadinbox+21+i]*WEIGHT(R,i);
		}
		outarray[treadid]=temp;
		}
	 */
}

void read(int argc, char* arcgv[], int* N, int* R, int* seed, int* s) {
	if (argc == 5) {
		*N = atoi(arcgv[1]);
		*R = atoi(arcgv[2]);
		*seed = atoi(arcgv[3]);
		*s = atoi(arcgv[4]);
		if (*N < (2 * *R + 1)) {
			printf("Invalid choice of N (%d) and R (%d), please define accordingly: N>=2*R+1.", N, R);
			exit(1);
		}
	}
	else {
		printf("Improper input arguments. Please enter 4 inputs (N,R,seed,s).");
		exit(1);
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


int main(int argc,char *argcv[]){
	cudaEvent_t start, end;
	cudaEventCreate(&start);
	cudaEventCreate(&end);
	float elapsedTime = 0.0;
	int N,R,seed,s;
	read(argc,argcv,&N,&R,&seed,&s);
	int blockwid = 1;
	int blocklen = 1;
	int gridlen = MIN(1024, find2times(N/blockwid/blocklen));
	int gridwid = find2times(N/blockwid/blocklen/gridlen);
	dim3 grid(gridwid,gridlen,1), block(blockwid,blocklen,1);

	double *inArr = (double*)malloc(N*sizeof(double));	
	double *outArr = (double*)malloc(N*sizeof(double));
	double *devInArr,*devOutArr;//*result, *devresult;
	cudaMalloc((void**)&devInArr,sizeof(double)*N);
	cudaMalloc((void**)&devOutArr,sizeof(double)*N);

	//random
	random_doubles(inArr,-1.0,1.0,N,seed);
	//copy data to device	
	cudaMemcpy(devInArr,inArr,sizeof(double)*N,cudaMemcpyHostToDevice);
	//calc 

	cudaEventRecord(start,0);
	if(s==0){	
		kernel1 <<<grid,1>>>(devInArr,devOutArr,R,N);
	}else{
		kernel2 <<<grid,2*R+1>>>(devInArr,devOutArr,R,N);
	}
	cudaEventRecord(end,0);
	cudaEventSynchronize(end);
	cudaEventElapsedTime(&elapsedTime,start,end);


	cudaMemcpy(outArr,devOutArr,N*sizeof(double),cudaMemcpyDeviceToHost);
	double res=0;
	for(int i=0;i<N;i++){
		res+=outArr[i]*outArr[i];
	}
	res = sqrt(res);
	//get data from device
	printf("%f\n",res);
	printf( "%f ms\n", elapsedTime ); 

	cudaEventDestroy(start);
	cudaEventDestroy(end);
	free(inArr);
	free(outArr);
	cudaFree(devInArr);
	cudaFree(devOutArr);
	return 0;

}
