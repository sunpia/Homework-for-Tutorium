#include <stdio.h>
#include <stdlib.h>
#include "output.h"

int int_sorter(const void* first_arg, const void* second_arg) {
	// cast the pointers to the right type
	int first = *(int*)first_arg;
	int second = *(int*)second_arg;
	// carry out the comparison
	if (first < second) {
		return -1;
	}
	else if (first == second) {
		return 0;
	}
	else {
		return 1;
	}
}

int main(int argc, char* argv[]) {
	if (argc != 2) {
		printf("Need one argument to play.\n");
		exit(1);
	}
	int n = atoi(argv[1]);
	if (n <= 0 || n >= 100) {
		printf("Need an integer value between 0 and 100");
		return NULL;
	}
	else {
		int len_arr = n + 1;
		int* storageArray = (int*)malloc(len_arr * sizeof(int));
		if (storageArray == NULL){
			printf("Can't allocate %d ints", len_arr);
			return NULL;
		}
		else{
			for (int i = 0;i <= n;i++) {
				storageArray[i] = n - i;
				/*printf("%p\n", &storageArray[i]);*/
			}
			qsort(storageArray, len_arr, sizeof(int), int_sorter);
			outputT5(storageArray, len_arr);

			return 0;
		}
		free(storageArray);
	}
}
