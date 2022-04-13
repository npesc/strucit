#include <stdio.h>
#include <stdlib.h>

#define C_VARIABLE 1
#define C_CONSTANT 2
#define C_FUNCTION 3
#define C_ARGUMENT 4

#define T_INT 1
#define T_INT_ARRAY 2
#define T_VOID 3

typedef struct globalEnvironnement {
    int deepthLevel;
    struct localEnvironnement *locEnv;
    struct globalEnvironnement *nextGlEnv;
} globalEnvironnement;

typedef struct infoIdentif {
    int class;
    int type;
    int value;
    int arraySize;
    int *parameterList;
} infoIdentif;

typedef struct localEnvironnement {
    char *name;
    struct infoIdentif *info;
    struct localEnvironnement *nextLocEnv;
} localEnvironnement;

int getDeepthLevel(globalEnvironnement *glEnv)
{
    int deepthLevel = -1;
    while (glEnv != NULL) {
        deepthLevel++;
        glEnv = glEnv->nextGlEnv;
    }

    return deepthLevel;
}

void addNewDeepthLevel(globalEnvironnement *glEnv, int deepthLevel) {
    globalEnvironnement *nextGlEnv = malloc(sizeof(globalEnvironnement));
    nextGlEnv->deepthLevel = deepthLevel;

    while (glEnv->nextGlEnv != NULL) {
        glEnv = glEnv->nextGlEnv;
    }
    glEnv->nextGlEnv = nextGlEnv;
}

void addNewIdentif(globalEnvironnement *glEnv, localEnvironnement *newLocEnv, int deepthLevel) {  
    int tmpDeepthLevel = 0;

    while (tmpDeepthLevel != deepthLevel) {
        tmpDeepthLevel++;
        glEnv = glEnv->nextGlEnv;
    }
   
    localEnvironnement **tmpLocEnv = &glEnv->locEnv;

    if (*tmpLocEnv == NULL) {
        *tmpLocEnv = newLocEnv;
    } 
    else {
        while (*tmpLocEnv != NULL) {
            tmpLocEnv = &((*tmpLocEnv)->nextLocEnv);
        }
        *tmpLocEnv = newLocEnv;
    }
}

char *getClassString(int i) {
    switch (i)
    {
        case 1:
            return "Var";
        case 2:
            return "Const";
        case 3:
            return "Func";
        case 4:
            return "Arg";
    }
}

char *getDataTypeClass(int i) {
    switch (i)
    {
        case 1:
            return "INT";
        case 2:
            return "INT_ARRAY";
        case 3:
            return "VOID";
    }
}

void print_dashes(int n)
{
    printf("\n");
	for(int i = 0; i < n; i++) {
	    printf("=");
    }
	printf("\n");
}

void printSymbolTable(globalEnvironnement *glEnv) {
    
    while (glEnv != NULL) {
        localEnvironnement *locEnv = glEnv->locEnv;

        print_dashes(120);
        printf("DEEPTH: %d", glEnv->deepthLevel);
        print_dashes(120);
        printf("%-20s %-20s %-20s %-20s %-20s %-20s\n", "name", "class", "data-type", "value", "array_dimension", "num_params");

        while(locEnv != NULL) {
            infoIdentif *info = locEnv->info;
            
            printf("%-20s %-20s %-20s %-20d %-20d %-20s\n", locEnv->name, getClassString(info->class), getDataTypeClass(info->type), info->value, info->arraySize, "2");
            locEnv = locEnv->nextLocEnv;
        }

        glEnv = glEnv->nextGlEnv; 
    }
}

// int main(int argc, char *argv[]) {

//     int deepthLevel = 0;
//     int identifType = 1;

//     globalEnvironnement glEnv0 = {0, NULL, NULL};

//     int t[] = {1, 0};

//     infoIdentif *tmp = malloc(sizeof(infoIdentif));
//     tmp->class = 1;
//     tmp->type = 1;
//     tmp->value = 1;
//     tmp->arraySize = 2;
//     tmp->parameterList = t;

//     localEnvironnement *tmpLocEnv = malloc(sizeof(localEnvironnement));
//     tmpLocEnv->name = "test";
//     tmpLocEnv->info = tmp;
//     tmpLocEnv->nextLocEnv = NULL;

//     localEnvironnement *tmpLocEnv2 = malloc(sizeof(localEnvironnement));
//     tmpLocEnv2->name = "alfa2";
//     tmpLocEnv2->info = tmp;
//     tmpLocEnv2->nextLocEnv = NULL;

//     localEnvironnement *tmpLocEnv3 = malloc(sizeof(localEnvironnement));
//     tmpLocEnv3->name = "alfa3";
//     tmpLocEnv3->info = tmp;
//     tmpLocEnv3->nextLocEnv = NULL;

//     localEnvironnement *tmpLocEnv4 = malloc(sizeof(localEnvironnement));
//     tmpLocEnv4->name = "alfa4";
//     tmpLocEnv4->info = tmp;
//     tmpLocEnv4->nextLocEnv = NULL;

//     localEnvironnement *tmpLocEnv5 = malloc(sizeof(localEnvironnement));
//     tmpLocEnv5->name = "alfa5";
//     tmpLocEnv5->info = tmp;
//     tmpLocEnv5->nextLocEnv = NULL;

//     localEnvironnement *tmpLocEnv6 = malloc(sizeof(localEnvironnement));
//     tmpLocEnv6->name = "alfa6";
//     tmpLocEnv6->info = tmp;
//     tmpLocEnv6->nextLocEnv = NULL;
    
//     addNewIdentif(&glEnv0, tmpLocEnv, deepthLevel);
//     addNewIdentif(&glEnv0, tmpLocEnv2, deepthLevel);
//     addNewIdentif(&glEnv0, tmpLocEnv3, deepthLevel);
//     addNewIdentif(&glEnv0, tmpLocEnv4, deepthLevel);
//     addNewDeepthLevel(&glEnv0, 1);
//     addNewIdentif(&glEnv0, tmpLocEnv5, 1);
//     addNewIdentif(&glEnv0, tmpLocEnv6, 1);
//     addNewDeepthLevel(&glEnv0, 2);
//     printSymbolTable(&glEnv0);
// }
