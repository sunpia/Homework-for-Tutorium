#include <stdio.h>
#include "output.h"
//In this programm I use linklist to store the string, so it can be more than 256 characters
int conting(char *argv){
	int num =0;
	while(*argv != '\0'){
		num++;
		argv++;
	}
	return num;
}
int main(int argc, char *argv[]) {
	int num =0;
	if( argc == 2 ) {
		num=conting(argv[1]);
	}
	else if( argc > 2 ) {
		printf("Too many arguments supplied.\n");
	return 0;
	}
	outputT1(num);
	return 0;
}
