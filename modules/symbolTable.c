#include "symbolTable.h"
#include <stdbool.h>

unsigned long hash(unsigned char *str){
    unsigned int hash = 0;
    int c;

    while (c = *str++)
        hash += c;

    return hash;
}

varEnv* lookupvar(varEnv* env, unsigned int hash){
    while (env != NULL){
        if (env->hash == hash) {
            return env;
        } else {
            env = env->nextEnv;
        }
    }
    return NULL; 
}
funcEnv* lookupfun(funcEnv* env, unsigned int hash){
    while (env != NULL){
        if (env->hash == hash) {
            return env;
        } else {
            env = env->nextEnv;
        }
    }
    return NULL; 
}

varEnv *addNewVar(varEnv *env, varData *data){  
    varEnv *tmpEnv = env;
    varEnv *newVar = malloc(sizeof(varEnv));

    newVar->hash = hash(data->id);
    newVar->data = data;
    newVar->nextEnv = NULL;

    while (tmpEnv != NULL && tmpEnv->nextEnv != NULL){
        tmpEnv = tmpEnv->nextEnv;
    }
    
    if (env == NULL){
        env = newVar;
    } else {
        tmpEnv->nextEnv = newVar; 
    }
    
    return env;
}

funcEnv *addNewFunc(funcEnv *env, funcData *data){  
    funcEnv *tmpEnv = env;
    funcEnv *newFunc = malloc(sizeof(funcEnv));

    newFunc->hash = hash(data->id);
    newFunc->data = data;
    newFunc->nextEnv = NULL;

    while (tmpEnv != NULL && tmpEnv->nextEnv != NULL){
        tmpEnv = tmpEnv->nextEnv;
    }
    
    if (env == NULL){
        env = newFunc;
    } else {
        tmpEnv->nextEnv = newFunc; 
    }
    
    return env;
}

structEnv *addNewStruct(structEnv *env, structData *data){  
    structEnv *tmpEnv = env;
    structEnv *newVar = malloc(sizeof(structEnv));

    newVar->hash = hash(data->id);
    newVar->data = data;
    newVar->nextEnv = NULL;

    while (tmpEnv != NULL && tmpEnv->nextEnv != NULL){
        tmpEnv = tmpEnv->nextEnv;
    }
    
    if (env == NULL){
        env = newVar;
    } else {
        tmpEnv->nextEnv = newVar; 
    }
    
    return env;
}

char *getDataType(int i){
    switch (i)
    {
        case 0:
            return "VOID";
        case 1:
            return "INT";
        case 2:
            return "*STRUCT";
        case 3:
            return "*FUNC";
        case 4:
            return "*INT";
    }
}

char *getArgsType(int *argsType, int argsLen){
    char *res = NULL;
    char tmpDest[255] = "";

    for(int i = 0; i < argsLen; i++){
        if ((argsType + i) != NULL){
            char *tmpChar = strdup(getDataType(*(argsType + i))); 
            strcat(tmpDest, tmpChar);

            if (i != argsLen){
                strcat(tmpDest, " ");
            }

            res = strdup(tmpDest);
        }
    }

    return res;
}

varData *createVarData(char *id, int type, int line){
    varData *tmpVarData = malloc(sizeof(varData));
    tmpVarData->id = strdup(id);
    tmpVarData->type = type;
    tmpVarData->line = line;

    return tmpVarData;
}

structData *createStructData(char *id, int *argsType, int line){
    structData *tmpStructData = malloc(sizeof(structData));
    tmpStructData->id = strdup(id);
    tmpStructData->argsType = argsType;
    tmpStructData->line = line;
    return tmpStructData;
}

funcData *createFuncData(char *id, int returnType, int *argsType, int argsLen, int line){
    funcData *tmpFuncData = malloc(sizeof(funcData));
    tmpFuncData->id = strdup(id);
    tmpFuncData->returnType = returnType;
    tmpFuncData->argsType = argsType;
    tmpFuncData->argsLen = argsLen;
    tmpFuncData->line = line;
    return tmpFuncData;
}

void printDashes(int n){
    printf("\n");
	for(int i = 0; i < n; i++) {
	    printf("=");
    }
	printf("\n");
}

void printVarST(varEnv *env){
    varEnv *tmpEnv = env;

    printDashes(80);
    printf("VARIABLE SYMBOL TABLE");
    printDashes(80);
    printf("%-20s %-20s %-20s %-20s\n", "ID", "HASH", "TYPE", "LINE");

    while(tmpEnv != NULL) {
        varData *data = tmpEnv->data;
        
        printf("%-20s %-20d %-20s %-20d", data->id, tmpEnv->hash, getDataType(data->type), data->line);

        if (tmpEnv->nextEnv != NULL){
            printf("\n");
        }

        tmpEnv = tmpEnv->nextEnv;
    }
    printDashes(80);   
}

void printFuncST(funcEnv *env){
    funcEnv *tmpEnv = env;

    printDashes(150);
    printf("FUNCTION SYMBOL TABLE");
    printDashes(150);
    printf("%-20s %-20s %-20s %-70s %-20s\n", "ID", "HASH", "RETURN_TYPE", "ARGS_TYPE", "LINE");

    while(tmpEnv != NULL) {
        funcData *data = tmpEnv->data;
        
        printf("%-20s %-20d %-20s %-70s %-20d", data->id, tmpEnv->hash, getDataType(data->returnType), getArgsType(data->argsType, data->argsLen), data->line);

        if (tmpEnv->nextEnv != NULL){
            printf("\n");
        }

        tmpEnv = tmpEnv->nextEnv;
    }
    printDashes(150);   
}

void printStructST(structEnv *env){
    structEnv *tmpEnv = env;

    printDashes(130);
    printf("STRUCT SYMBOL TABLE");
    printDashes(130);
    printf("%-20s %-20s %-70s %-20s\n", "ID", "HASH", "ARGS_TYPE", "LINE");

    while(tmpEnv != NULL) {
        structData *data = tmpEnv->data;
        
        printf("%-20s %-20d %-70s %-20d", data->id, tmpEnv->hash, getArgsType(data->argsType, data->argsLen), data->line);

        if (tmpEnv->nextEnv != NULL){
            printf("\n");
        }

        tmpEnv = tmpEnv->nextEnv;
    }
    printDashes(130);   
}

// int main(int argc, char *argv[]) {
    // varData *data1 = malloc(sizeof(varData));
    // varData *data2 = malloc(sizeof(varData));
    // varData *data3 = malloc(sizeof(varData));

    // data1->id = strdup("var1");
    // data2->id = strdup("var2");
    // data3->id = strdup("var3");
    
    // data1->type = 1;
    // data2->type = 3;
    // data3->type = 2;
     
    // data1->line = 23;
    // data2->line = 12;
    // data3->line = 5;

    // varEnv *env1;

    // env1 = addNewVar(env1, data1);
    // env1 = addNewVar(env1, data2);
    // env1 = addNewVar(env1, data3);

    // printVarST(env1);

//     int type1[] = {3, 2, 3};
//     int type2[] = {2, 2, 3};
//     int type3[] = {3, 2, 3};

//     funcData *dataF1 = malloc(sizeof(funcData));
//     funcData *dataF2 = malloc(sizeof(funcData));
//     funcData *dataF3 = malloc(sizeof(funcData));

//     dataF1->argsType = type1;
//     dataF1->id = strdup("func1");
//     dataF1->line = 12;
//     dataF1->returnType = 3;

//     dataF2->argsType = type2;
//     dataF2->id = strdup("func2");
//     dataF2->line = 32;
//     dataF2->returnType = 1;

//     dataF3->argsType = type3;
//     dataF3->id = strdup("func3");
//     dataF3->line = 5;
//     dataF3->returnType = 2;

//     funcEnv *fEnv = NULL;

//     fEnv = addNewFunc(fEnv, dataF1);
//     fEnv = addNewFunc(fEnv, dataF2);
//     fEnv = addNewFunc(fEnv, dataF3);

//     printFuncST(fEnv);
    
// }
