#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utility.h"

// type_code : 
//     0 -> void
//     1 -> int
//     2 -> *struct
//     3 -> *func 
//     4 -> *int 

typedef struct varData{
    char *id;
    int type;
    int global;
    int line;
} varData;

typedef struct funcData{
    char *id;
    int returnType;
    int *argsType;
    int argsLen;
    char *paramsName[100];
    int line;
}funcData;

typedef struct structData{
    char *id;
    int *fieldsType;
    int fieldsLen;
    char *fieldsName[100];
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

int hash(unsigned char *str);
varEnv *addNewVar(varEnv *env, varData *data);
funcEnv *addNewFunc(funcEnv *env, funcData *data);
structEnv *addNewStruct(structEnv *env, structData *data);
varEnv* lookupvar(varEnv* env, int hash);
char *getDataType(structEnv* envStruct, int i);
char *getArgsType(int *argsType, int argsLen);
varData *createVarData(char *id, int type, int globalFlag, int line);
void printDashes(int n);
void printVarST(structEnv* envS, varEnv *env);
void printFuncST(structEnv* envS, funcEnv *env);
structData *createStructData(char *id, int *fieldsType, int fieldsLen, char *fieldsName[100], int line);
funcData *createFuncData(char *id, int returnType, int *argsType, int argsLen, char *paramsName[100], int line);
void printStructST(structEnv *env);
void deleteNonGlobal(varEnv **env);
void deleteNonGlobal1El(varEnv** head_ref);
int countNonGlobal(varEnv *env);

//SEMANTICS PARTS -> need to add in a new FILE after

int getSizePrimitif(int i);
int getSizeOf(varEnv *envVar, structEnv *envStruct, funcEnv *envFunc, int hash);
int checkVarFuncType(varEnv *env, funcEnv *envFunc, char *funcID, int hash);
int checkVarFuncExists(varEnv *env, funcEnv *envFunc, int hash);
int checkFuncExists(funcEnv *envFunc, int hash);
int checkFieldExists(structEnv *env, int hash, char *field);
int getVarType(varEnv *env, int hash);
int checkStringIsInt(char *str);
void writeFile(char *data);