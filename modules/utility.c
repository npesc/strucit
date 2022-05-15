#include "utility.h"

void printSpace(int c, int nbNL){
    for(int i = 0; i < nbNL; i++){
        printf("\n");
    }
	for(int i = 0; i < c; i++){
		printf(" ");
	}
}

int getIntLen(int n){
    char str[30];
	sprintf(str, "%d", n);
	return strlen(str);
}