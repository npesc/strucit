%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbolTableModule.c"

extern int yylineno;
extern char* yytext;

int yylex(void);
int yyerror(char *msg);

int deepthLevel = -1;

char *identifName;
int identifType = -1;
int identifVal = -1;

globalEnvironnement glEnv0 = {0, NULL, NULL};
%}

%union {
        int num;
        char id;
}

%token IDENTIFIER CONSTANT SIZEOF 
%token PTR_OP LE_OP GE_OP EQ_OP NE_OP LT_OP GT_OP
%token AND_OP OR_OP
%token AUTO SWITCH CASE
%token UNION 
%token EXTERN REGISTER STATIC TYPEDEF VOLATILE
%token INT VOID DOUBLE CHAR FLOAT LONG SHORT SIGNED UNSIGNED
%token CONST
%token STRUCT DEFAULT ENUM
%token IF ELSE WHILE FOR RETURN BREAK CONTINUE DO GOTO 
%token INC DEC
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token RSHIFT_ASSIGN LSHIFT_ASSIGN BIT_AND_ASSIGN BIT_OR_ASSIGN BIT_XOR_ASSIGN
%token RSHIFT LSHIFT

%nonassoc IFX
%nonassoc ELSE

%start program
%%

primary_expression
        : IDENTIFIER 
            {
                identifName = malloc(sizeof(char) * 255);
                memcpy(identifName, yytext, sizeof(char) * 255);
            }
        | CONSTANT 
            {
                identifVal = atoi(yytext);
            }
        | '(' expression ')'
        ;

postfix_expression
        : primary_expression
        | postfix_expression '(' ')'
        | postfix_expression '(' argument_expression_list ')'
        | postfix_expression '.' IDENTIFIER
        | postfix_expression PTR_OP IDENTIFIER
        ;

argument_expression_list
        : expression
        | argument_expression_list ',' expression
        ;

unary_expression
        : postfix_expression
        | unary_operator unary_expression
        | SIZEOF unary_expression
        | SIZEOF '(' type_specifier ')'
        ;

unary_operator
        : '&'
        | '*'
        | '-'
        ;

binary_expression
        : unary_expression
        | binary_expression '&' unary_expression
        | binary_expression '|' unary_expression
        | binary_expression '^' unary_expression
        | binary_expression LSHIFT unary_expression
        | binary_expression RSHIFT unary_expression
        ;

multiplicative_expression
        : binary_expression
        | multiplicative_expression '*' binary_expression
        | multiplicative_expression '/' binary_expression
        ;

additive_expression
        : multiplicative_expression
        | additive_expression '+' multiplicative_expression
        | additive_expression '-' multiplicative_expression
        ;

relational_expression
        : additive_expression
        | relational_expression LT_OP additive_expression
        | relational_expression GT_OP additive_expression
        | relational_expression LE_OP additive_expression
        | relational_expression GE_OP additive_expression
        ;

equality_expression
        : relational_expression
        | equality_expression EQ_OP relational_expression
        | equality_expression NE_OP relational_expression
        ;

logical_and_expression
        : equality_expression
        | logical_and_expression AND_OP equality_expression
        ;

logical_or_expression
        : logical_and_expression
        | logical_or_expression OR_OP logical_and_expression
        ;

expression
        : logical_or_expression
        | unary_expression '=' expression
        ;

declaration
        : declaration_specifiers declarator ';'
            {
                int t[] = {1, 0};

                infoIdentif *tmp = malloc(sizeof(infoIdentif));
                tmp->class = 1;
                tmp->type = identifType;
                tmp->value = identifVal;
                tmp->arraySize = 2;
                tmp->parameterList = t;

                localEnvironnement *tmpLocEnv = malloc(sizeof(localEnvironnement));
                tmpLocEnv->name = identifName;
                tmpLocEnv->info = tmp;
                tmpLocEnv->nextLocEnv = NULL;

                addNewIdentif(&glEnv0, tmpLocEnv, deepthLevel);
            }
        | struct_specifier ';'
        ;

declaration_specifiers
        : EXTERN type_specifier
        | type_specifier
        ;

type_specifier
        : VOID {identifType = 3;}
        | INT {identifType = 1;}
        | struct_specifier
        ;

struct_specifier
        : STRUCT IDENTIFIER '{' struct_declaration_list '}'
        | STRUCT '{' struct_declaration_list '}'
        | STRUCT IDENTIFIER
        ;

struct_declaration_list
        : struct_declaration
        | struct_declaration_list struct_declaration
        ;

struct_declaration
        : type_specifier declarator ';' 
        ;

declarator
        : '*' direct_declarator
        | direct_declarator
        ;

direct_declarator
        : IDENTIFIER 
            {
                identifName = malloc(sizeof(char) * 255);
                memcpy(identifName, yytext, sizeof(char) * 255);
            }
        | '(' declarator ')'
        | direct_declarator '(' parameter_list ')'
        | direct_declarator '(' ')'
        ;

parameter_list
        : parameter_declaration
        | parameter_list ',' parameter_declaration
        ;

parameter_declaration
        : declaration_specifiers declarator
        ;

statement
        : compound_statement
        | expression_statement
        | selection_statement
        | iteration_statement
        | jump_statement 
        ;

compound_statement
        : '{' inter_newBlock '}' {deepthLevel--;}
        | '{' inter_newBlock statement_list '}' {deepthLevel--;}
        | '{' inter_newBlock declaration_list '}' {deepthLevel--;}
        | '{' inter_newBlock declaration_list statement_list '}' {deepthLevel--;}
        ;

inter_newBlock
        : 
            {
                deepthLevel++;
                if (deepthLevel != 0) {
                    addNewDeepthLevel(&glEnv0, deepthLevel);
                }
            }

declaration_list
        : declaration
        | declaration_list declaration
        ;

statement_list
        : statement
        | statement_list statement
        ;

expression_statement
        : ';'
        | expression ';'
        ;
selection_statement
        : IF '(' expression ')' statement %prec IFX
        | IF '(' expression ')' statement ELSE statement
        ;


iteration_statement
        : WHILE '(' expression ')' statement
        | FOR '(' expression_statement expression_statement expression ')' statement
        ;

jump_statement
        : RETURN ';'
        | RETURN expression ';'
        ;

program 
        : external_declaration 
        | program external_declaration 
        ;

external_declaration
        : function_definition
        | declaration
        ;

function_definition
        : declaration_specifiers declarator compound_statement
        ;

%%

// Function to display error messages with line no and token
int yyerror(char *msg)
{
    printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg, yytext);
    return 0;
}

int main(){
        yyparse();
        printSymbolTable(&glEnv0);
        return 1;
}