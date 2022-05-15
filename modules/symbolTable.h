#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// type_code : 
//     0 -> void
//     1 -> int
//     2 -> *struct
//     3 -> *func 
//     4 -> *int 

typedef struct varData{
    char *id;
    int type;
    int line;
} varData;

typedef struct funcData{
    char *id;
    int returnType;
    int *argsType;
    int argsLen;
    int line;
}funcData;

typedef struct structData{
    char *id;
    int *argsType;
    int argsLen;
    int line;
} structData;

typedef struct varEnv{
    unsigned int hash;
    struct varData *data;
    struct varEnv *nextEnv;
} varEnv;

typedef struct funcEnv{
    unsigned int hash;
    struct funcData *data;
    struct funcEnv *nextEnv;
} funcEnv;

typedef struct structEnv{
    unsigned int hash;
    struct structData *data;
    struct structEnv *nextEnv;
} structEnv;

unsigned long hash(unsigned char *str);
varEnv *addNewVar(varEnv *env, varData *data);
funcEnv *addNewFunc(funcEnv *env, funcData *data);
structEnv *addNewStruct(structEnv *env, structData *data);
varEnv* lookupvar(varEnv* env, unsigned int hash);
char *getDataType(int i);
char *getArgsType(int *argsType, int argsLen);
varData *createVarData(char *id, int type, int line);
void printDashes(int n);
void printVarST(varEnv *env);
void printFuncST(funcEnv *env);
structData *createStructData(char *id, int *argsType, int line);
funcData *createFuncData(char *id, int returnType, int *argsType, int argsLen, int line);
void printStructST(structEnv *env);