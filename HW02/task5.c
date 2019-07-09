#include <stdio.h>
#include <stdlib.h>
#include "output.h"
int read(){
	int n;
	scanf("%d", &n);
	if (n<100 && n>0){
	return n;
	}else{
	printf("the value in invalid, please input a new again");
	read();
	}
}

int cmp ( const void *a , const void *b )

{

  return *(int *)a - *(int *)b;
}

void main() {
	printf("At first, you should input a integer between 0 and 100.");
	int n = read();
	int *array = (int*)malloc((n+1)*sizeof(int));
	for(int i=0;i<=n;i++){
		array[i] = n-i;
	}
	qsort(array,n+1,sizeof(array[0]),cmp);
	for (int i=0;i<=n;i++){
		printf("%d\t",array[i]);
	}
}
	
