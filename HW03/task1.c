#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "output.h"
//In this programm I use linklist to store the string, so it can be more than 256 characters
typedef struct savechar{
	struct savechar *next;
	char str[10];
	bool full;
}sav;
sav *read(char *arg[],int *number){
	sav *head, *p;
	p = (sav*)malloc(sizeof(sav));
	p -> full = false;
	p -> next = NULL;
	head = p;
	int num = 0;
	while(1){
		if(arg[0][num] == '\n'){
			break;
		}else{	
			if(num%10==0 && num != 0){
				p->full = true;
				p->next = (sav*)malloc(sizeof(sav));
				p=p->next;
				p->next =NULL;
				p->full = false;
			}
			p->str[num%10] = arg[0][num];
		}
		num++;
	}
	*number = num;
	return head;
}
void delet(sav *head){
	sav *p = head->next;
	free(head);
	if(p){
	delet(p);
	}
}
int main(int argc, char *argv[]) {
	int num;
//	sav *head = read(argv,&num);
	printf("%s",argv[1]);
	outputT1(num);
//	delet(head);		
	return 0;
}
