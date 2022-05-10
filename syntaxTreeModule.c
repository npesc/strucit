#include <stdio.h>
#include<string.h>
#include <stdlib.h>  

typedef struct infoNode {
    int typeNode;
} infoNode;

typedef struct syntaxTree {
    struct infoNode *info;
    struct syntaxTree *parent;
    struct syntaxTree *childs[5];
} syntaxTree;

char codeSyntax[][35] = {"function_definition", "external_declaration", "program",
                    "jump_statement", "iteration_statement", "selection_statement",
                    "expression_statement", "statement_list", "declaration_list",
                    "inter_newBlock", "compound_statement", "statement",
                    "parameter_declaration", "parameter_list", "direct_declarator",
                    "declarator", "struct_declaration", "struct_declaration_list",
                    "struct_specifier", "type_specifier", "declaration_specifiers",
                    "declaration", "expression", "logical_or_expression",
                    "logical_and_expression", "equality_expression", "relational_expression",
                    "additive_expression", "multiplicative_expression", "binary_expression",
                    "unary_operator", "unary_expression", "argument_expression_list",
                    "postfix_expression", "primary_expression"};

int getTokenKey(char *token) {
    int codeSynLen = (sizeof(codeSyntax) / (sizeof(char) * 35));
    for (int i = 0; i < codeSynLen; i++) {
        if (strcmp(codeSyntax[i], token) == 0) {
            return i;
        }
    }
}

void addChildInTree(syntaxTree *tree, syntaxTree *child) {
    for (int i = 0; i < 5; i++) {
        if (tree->childs[i] == NULL) {
            tree->childs[i] = child;
            return ;
        }
    }
}

void printSpace(int j) {
    printf("\n");
    for (int i = 0; i < j; i++) {
        printf(" ");
    }
}

void printSyntaxTree(syntaxTree *synTree, int freeSpaceNb) {
    syntaxTree *actSynTree = synTree;

    printSpace(freeSpaceNb);
    printf("--> %s", codeSyntax[actSynTree->info->typeNode]);

    for (int i = 0; i < 5; i++) {
        if (actSynTree->childs[i] != NULL) {
            syntaxTree *actChild = actSynTree->childs[i];
            printSyntaxTree(actChild, freeSpaceNb + 3);
        }
    }
    printf("\n");
}

// int main(int argc, char *argv[]) {
    
//     infoNode *infNode = malloc(sizeof(infoNode));
//     infNode->typeNode = getTokenKey("additive_expression");

//     syntaxTree *id = malloc(sizeof(syntaxTree));
//     syntaxTree *val = malloc(sizeof(syntaxTree));
//     id->info = infNode;
//     val->info = infNode;

//     syntaxTree *synTree = malloc(sizeof(syntaxTree));
//     synTree->childs[0] = id;
//     synTree->childs[1] = val;
//     synTree->info = infNode;

//     printSyntaxTree(synTree, 1);
//     return 0;
// }