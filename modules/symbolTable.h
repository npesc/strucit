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
    int line;
}funcData;

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

unsigned long hash(unsigned char *str);
varEnv *addNewVar(varEnv *env, varData *data);
funcEnv *addNewFunc(funcEnv *env, funcData *data);
varEnv* lookupvar(varEnv* env, unsigned int hash);
char *getDataType(int i);
char *getArgsType(int *argsType);
varData *createVarData(char *id, int type, int line);
void printDashes(int n);
void printVarST(varEnv *env);
void printFuncST(funcEnv *env);