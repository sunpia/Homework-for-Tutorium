#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "output.h"
//In this programm I use linklist to store the string, so it can more than 256 characters
typedef struct savechar{
	struct savechar *next;
	char str[10];
	bool full;
}sav;
sav *read(int *number){
	sav *head, *p;
	p = (sav*)malloc(sizeof(sav));
	p -> full = false;
	p -> next = NULL;
	head = p;
	char c;
	int num = 0;
	while(1){
		c = getchar();
		if(c == '\n'){
			break;
		}else{	
			if(num%10==0 && num != 0){
				p->full = true;
				p->next = (sav*)malloc(sizeof(sav));
				p=p->next;
				p->next =NULL;
				p->full = false;
			}
			p->str[num%10] = c;
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
void main() {
	int num;
	sav *head = read(&num);
	outputT1(num);
	delet(head);		
}
