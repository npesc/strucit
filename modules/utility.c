#include "utility.h"

char* replaceWord(const char* s, const char* oldW, const char* newW){
    char* result;
    int i, cnt = 0;
    int newWlen = strlen(newW);
    int oldWlen = strlen(oldW);
  
    for (i = 0; s[i] != '\0'; i++) {
        if (strstr(&s[i], oldW) == &s[i]) {
            cnt++;
            i += oldWlen - 1;
        }
    }
  
    result = (char*)malloc(i + cnt * (newWlen - oldWlen) + 1);
  
    i = 0;
    while (*s) {
        if (strstr(s, oldW) == s) {
            strcpy(&result[i], newW);
            i += newWlen;
            s += oldWlen;
        }
        else
            result[i++] = *s++;
    }
  
    result[i] = '\0';
    return result;
}

void logError(int errorCode){
	printf("\n\n[ERROR : %d] ", errorCode);

	switch (errorCode){
		case 101:
			printf("Parameter was not find in TS.\n");
			break;
		case 102:
			printf("Function was not find in TS.\n");
			break;
		case 103:
			printf("Structure's field was not find in TS.\n");
			break;
		case 104:
			printf("Variable was not find in TS.\n");
			break;
		case 105:
			printf("Expression was wainting for an integer.\n");
			break;
		case 106:
			printf("Variable was not declared.\n");
			break;
		case 107:
			printf("Variable already declared.\n");
			break;
		case 108:
			printf("Function already declared.\n");
			break;
		default:
			break;
	}

	exit(1);
}

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

int *addNewIntArray(int *tab, int size, int newVal){
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

char **addNewCharArray(char **tab, int size, char *newEl){
	char **tmpTab = malloc(size * 100 * sizeof(char));

	for (int i = 0; i < size; i++){
		if (i == size - 1){
			*(tmpTab + i) = strdup(newEl);
		} else {
			*(tmpTab + i) = strdup(*(tab + i));
		}
	}

	return tmpTab;
}

// int main(){
	// int *tab;
	// int array[] = {1, 2, 3, 4};
	// tab = array;
	// tab = addNewIntArray(tab, 5, 5);

	// for (int i = 0; i <  5; i++){
	// 	printf("\n%d", *(tab+i));
	// }

// 	char *tab[100];
// 	tab[0] = strdup("test1");
// 	tab[1] = strdup("test2");
// 	tab[2] = strdup("test3");
// 	char **res;
// 	res = tab;
// 	res = addNewCharArray(res, 4, "test4");

// 	for (int i = 0; i <  4; i++){
// 		printf("\n%s", res[i]);
// 	}
// }