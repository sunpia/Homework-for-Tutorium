#include <stdio.h>

int A(int y) {
	y = y+1;
	return y;
}

void B(int *y) {
	y = (int*) 10;
}

void C(int *y) {
	*y = 6;
}

int main(int argc, char *argv[]) {
	int x = 4;

	x = A(x);
	printf("%d\n", x);
// Hier print 5, in the function A it print the value of x+1 but donnot change the value of x.
	A(x);
	B(&x);
	printf("%d\n", x);
// Hier print 5, A return x+1 but print nothing and donnot change the value of x, B get the address of x, but then jump to another address, so x is still unchanged.
	C(&x);
	printf("%d\n", x);
// Hier print 6, C get the address of x and change the data in this address to 6, so it become 6. 
	return 0;
}
