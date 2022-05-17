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

int *addNewElArray(int *tab, int size, int newVal){
	int len = sizeof(tab) / sizeof(int);
	int *tmpTab = malloc(size * sizeof(int));

	for (int i = 0; i < size; i++){
		if (i == size - 1){
			*(tmpTab + i) = newVal;
			return tmpTab;
		} else {
			*(tmpTab + i) = *(tab + i);
		}
	}
}

// int main(){
// 	int *tab;
// 	int array[] = {1, 2, 3, 4};
// 	tab = array;
// 	tab = addNewElArray(tab, 4, 5);

// 	for (int i = 0; i <  5; i++){
// 		printf("\n%d", *(tab+i));
// 	}
// }