#include <stdio.h>
#include <stdlib.h>
#include "output.h"
int read(char *arcv[]){
	int n = atoi(arcv[1]);
	if (n<100 && n>0){
	return n;
	}else{
	printf("the value in invalid, please input a new again");
	scanf("%s",arcv[1]);
	read(arcv);
	}
}

int cmp ( const void *a , const void *b )

{

  return *(int *)a - *(int *)b;
}

int main(int arc,char *arcv[]) {
	int n = read(arcv);
	int *array = (int*)malloc((n+1)*sizeof(int));
	for(int i=0;i<=n;i++){
		array[i] = n-i;
	}
	qsort(array,n+1,sizeof(array[0]),cmp);
	outputT5(array,n+1);
	free(array);
}
	
