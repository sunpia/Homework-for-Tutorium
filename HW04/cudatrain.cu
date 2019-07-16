#include <stdlib.h>
#include <stdio.h>
#include <cuda.h>
#define imin(a,b) (a<b?a:b)

const int N = 33 * 1024;
const int threadPerBlock = 256;
const int blockPerGrid = imin( 32, (N+threadPerBlock-1) / threadPerBlock );

__global__ void dot( float *a, float *b, float *c)
{
    //共享内存, 每个block都有一份拷贝
printf("run");    
__shared__ float cache[threadPerBlock];
    // thread的索引
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    // 共享内存的索引,每个block都有cache, 故只用threadIdx.x即可
    int cacheIdx = threadIdx.x;

    float temp = 0;
    while(tid<N)
    {
        //当前tid的thread负责把tid,和tid间隔threadIdx总量整数倍的向量做乘-加操作.
        temp += a[tid] * b[tid];
        tid += blockDim.x * gridDim.x;
    }
    // 完成求和之后,当前thread把和放在对应的cache中
    cache[cacheIdx] = temp;
    // 在当前block内做同步操作, 等所有thread都完成乘-加运算之后才能做reduction.
    __syncthreads();

    //reduction, 向量缩减.
    //缩减后的结果在cache[0]里.
    int i = blockDim.x/2;
    while (i!=0)
    {
        if (cacheIdx<i)
        {
            cache[cacheIdx] += cache[cacheIdx + i];

        }
        //同步, 等所有thread都完成了当次缩减了才能做下一次的缩减.
        //书上说: 同步不能放在if里面, 否则报错.
        //经过试验没有报错, 结果正确.
        __syncthreads();
        i /= 2;
    }
    // 一个block输出一个值,即cache[0]. 所以c的长度和block数量相同.
    // 限制cacheIdx == 0是为了只做一次赋值操作,节省时间.
    if (cacheIdx == 0)
    {
        c[blockIdx.x] = cache[0];
    }
    // 没有做剩下的累加操作是因为在CPU上做小批量的累加更加有效.
}

int main(void)
{
    float *a, *b, c, *partial_c;
    float *dev_a, *dev_b, *dev_partial_c;

    //分配CPU端的内存
    a = (float *)malloc( N*sizeof(float) );
    b = (float *)malloc( N*sizeof(float) );
    partial_c = (float *)malloc( blockPerGrid*sizeof(float));

    //分配GPU端的内存
   cudaMalloc( (void**)&dev_a, N*sizeof(float));
  cudaMalloc( (void**)&dev_b, N*sizeof(float));
  cudaMalloc( (void**)&dev_partial_c, blockPerGrid*sizeof(float));

    //将主机内存填入数据
    for (int i=0; i<N; i++)
    {
        a[i] = i;
        b[i] = i*2;
    }

    //将向量a和b拷入GPU
    cudaMemcpy( dev_a, a, N*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy( dev_b, b, N*sizeof(float), cudaMemcpyHostToDevice);

    //GPU上做点积运算
    dot<<<blockPerGrid, threadPerBlock>>>(dev_a, dev_b, dev_partial_c);

    //将向量拷入主机
    cudaMemcpy( partial_c, dev_partial_c, blockPerGrid*sizeof(float), cudaMemcpyDeviceToHost);

    //剩余CPU运算, 求累加和
    c = 0;
    for (int i=0; i<blockPerGrid; i++)
    {
        c += partial_c[i];
    }

    //验证结果是否正确
#define sum_square(x) (x*(x+1)*(2*x+1)/6)
    printf( "Does GPU value %.6g = %.6g?\n",c,
            2 * sum_square( (float)(N-1) ) );
    //释放内存
    cudaFree( dev_a );
    cudaFree( dev_b );
    cudaFree( dev_partial_c);

    free( a );
    free( b );
    free( partial_c);

    return 0;
}
