#include "output.h"

int countString(char *cstring) {
	int len = 0;
	while (*cstring != '\0') {
		len++;
		cstring++;
	}
	return len;
}

int main(int argc, char* argv[]) {

	if (argc == 2) {
		printf("The argument supplied is %s\n", argv[1]);
	}
	else if (argc > 2) {
		printf("Too many arguments supplied.\n");
		exit(1);
	}
	else {
		printf("One argument expected.\n");
		exit(1);
	}
	// int n = strlen(argv[1]);

	int num = countString(argv[1]);
	outputT1(num);
	//printf("Length of String: %d", num);
	return 0;
}
