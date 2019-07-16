#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include "../randoms/randoms.c"
#include <cuda.h>

#define PI 3.1415926535
#define MAX(a,b) (a>b)?a:b
#define MIN(a,b) (a<b)?a:b
#define WEIGHT(R,i) sqrt((float)(2/(PI*R*R)))*__expf(-2*(i-R)*(i-R)/(R*R))


__global__ void kernel1(float *inarray,float *outarray, int R, int N)
{
	int treadid = threadIdx.x+threadIdx.y*blockDim.x+(blockIdx.x+blockIdx.y*gridDim.x)*(blockDim.x*blockDim.y);  
	if(treadid<N){
		float *temp=(float*)malloc((2*R+1)*sizeof(float));
		for(int i = -R;i<R+1;i++)
		{	
			if(treadid+i>=0)
			{temp[i+R]=inarray[treadid+i]*WEIGHT(R,i);}
			else{temp[i+R] = 0;}
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

__global__ void kernel2(float *inarray,float *outarray, int R, int N)
{
	const int size = 1024;
	__shared__ float mem[size+42];
	int treadinbox =threadIdx.x+threadIdx.y*blockDim.x;
	int treadid = threadIdx.x+threadIdx.y*blockDim.x+(blockIdx.x+blockIdx.y*gridDim.x)*(blockDim.x*blockDim.y);  
	if(treadid<N){
		mem[21+treadinbox] = inarray[treadid];
		if(treadinbox<R){
			if(treadid-R>0){
				
				mem[21-R+treadinbox] = inarray[treadid-R];	
			}else{
				
				mem[21-R+treadinbox] = 0;}
		}
		if(treadinbox>N-R){
			if(treadid+R<N){
				mem[treadinbox+R+21] = inarray[treadid+R];	
			}else{mem[R+treadinbox+21] = 0;}
		}
	}
	__syncthreads();
//	if(treadid == 0){
//		for (int i=0;i<size+2*R;i++){	
//			printf("%f\n",mem[i+21-R]);
//		}
//	}	
	if(treadid<N){
		float *temp=(float*)malloc((2*R+1)*sizeof(float));
		for(int i = -R;i<R+1;i++)
		{	
			temp[i+R]=mem[treadinbox+21+i]*WEIGHT(R,i);
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

__global__ void getresult(float *arr,float *result, int N)
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
	*result = sqrt((float)(arr[0]));
}

int main(int argc,char *argcv[]){
	//	clock_t start, end;
	//	double cpu_time_used;
	//	start = clock();
	int N,R,seed,s;
	read(argc,argcv,&N,&R,&seed,&s);
	int blockwid = 32;
	int blocklen = 32;
	int gridlen = MIN(64, find2times(N/blockwid/blocklen));
	int gridwid = find2times(N/blockwid/blocklen/gridlen);
	dim3 grid(gridwid,gridlen,1), block(blockwid,blocklen,1);

	float *inArr = (float*)malloc(N*sizeof(float));	
	float *outArr = (float*)malloc(N*sizeof(float));
	float *devInArr,*devOutArr,*result, *devresult;
	result = (float*)malloc(sizeof(float));
	cudaMalloc((void**)&devInArr,sizeof(float)*N);
	cudaMalloc((void**)&devOutArr,sizeof(float)*N);
	cudaMalloc((void**)&devresult,sizeof(float));

	//random
	random_floats(inArr,-1.0,1.0,N,seed);
	//copy data to device	
	cudaMemcpy(devInArr,inArr,sizeof(float)*N,cudaMemcpyHostToDevice);
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
	cudaMemcpy(result,devresult,sizeof(float),cudaMemcpyDeviceToHost);

	printf("%f",*result);


	free(inArr);
	free(outArr);
	free(result);
	cudaFree(devresult);
	cudaFree(devInArr);
	cudaFree(devOutArr);
	return 0;

}
