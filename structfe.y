%{
  	#include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <ctype.h>
	#include "modules/utility.h"
	#include "modules/syntaxTree.h"
	#include "modules/symbolTable.h"

	int yylex(void);
	int yyerror(char *msg);
	int yywrap();

	extern FILE *fp;
	extern FILE* yyin;
	extern int yylineno;
	extern char yytext[];
	extern int comacc;
	FILE* out;
	
	char temp[200];
	char msg[200];
	int type;
	char *id;
    struct node *head;
	varEnv *env;

	void setID(char *idVal);
	void setType(int typeVal);
	void convertToPointer(void);
	int insert(char* str);

%}

%union { 
	struct var_name { 
		char name[150]; 
		struct node* nd;
		char code[6553];
	} ndObj; 
} 

%token <ndObj>  IDENTIFIER CONSTANT SIZEOF 
%token <ndObj>  PTR_OP LE_OP GE_OP EQ_OP NE_OP LT_OP GT_OP
%token <ndObj>  AND_OP OR_OP
%token <ndObj>  EXTERN
%token <ndObj>  INT VOID
%token <ndObj>  STRUCT
%token <ndObj>  IF ELSE WHILE FOR RETURN
%token <ndObj>  RSHIFT LSHIFT

%token <ndObj> STAR PLUS MINUS SLASH EG
%token <ndObj> LPAR RPAR RBR LBR
%token <ndObj> SEMI COMMA COMAND

%type <ndObj> primary_expression postfix_expression argument_expression_list unary_expression unary_operator
%type <ndObj> binary_expression multiplicative_expression additive_expression relational_expression equality_expression
%type <ndObj> logical_and_expression logical_or_expression expression declaration declaration_specifiers
%type <ndObj> type_specifier struct_specifier struct_declaration_list struct_declaration declarator
%type <ndObj> direct_declarator parameter_list parameter_declaration statement compound_statement
%type <ndObj> declaration_list statement_list expression_statement selection_statement iteration_statement
%type <ndObj> jump_statement program external_declaration function_definition

%left COMAND
%left STAR
%left MINUS

%nonassoc IFX
%nonassoc ELSE

%start program

%%

primary_expression
        : IDENTIFIER 
		{
			$$.nd = mkNode(NULL, NULL, $1.name);
			setID($1.name);
			insert($$.code);
			
		}
        | CONSTANT
		{
			$$.nd = mkNode(NULL, NULL, $1.name);
		} 
        | LPAR expression RPAR
		{
			$$.nd = $2.nd;

		}
        ;

postfix_expression
        : primary_expression
		{
			$$.nd = $1.nd;
		}
        | postfix_expression LPAR RPAR
		{
			$$.nd = mkNode($1.nd, NULL, "func()");
			sprintf($$.code, $1.code);
		}
        | postfix_expression LPAR argument_expression_list RPAR
		{
			$$.nd = mkNode($1.nd, $3.nd, "func(...)");
		}
        | postfix_expression '.' IDENTIFIER
		{
			$$.nd = mkNode($1.nd, $3.nd, "struct.id");
		}
        | postfix_expression PTR_OP IDENTIFIER
		{
			$$.nd = mkNode($1.nd, $3.nd, "struct->id");
		}
        ;

argument_expression_list
        : expression
		{
			$$.nd = $1.nd;
		}
        | argument_expression_list COMMA expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "argExpList");
		}
        ;

unary_expression
        : postfix_expression
		{
			$$.nd = $1.nd;
		}
        | unary_operator unary_expression
		{
			$$.nd = mkNode($1.nd, $2.nd, "unaryExp");
		}
        | SIZEOF unary_expression
		{
			struct node *tmp = mkNode(NULL, NULL, "sizeof");
			$$.nd = mkNode(tmp, $2.nd, "unaryExp");
		}
        | SIZEOF LPAR type_specifier RPAR
		{
			struct node *tmp = mkNode(NULL, NULL, "sizeof");
			$$.nd = mkNode(tmp, $3.nd, "unaryExp");
		}
        ;

unary_operator
        : COMAND
		{
			$$.nd = mkNode(NULL, NULL, "&");
		}
        | STAR
		{
			$$.nd = mkNode(NULL, NULL, "*");
		}
        | MINUS
		{
			$$.nd = mkNode(NULL, NULL, "-");
		}
        ;

binary_expression
        : unary_expression
		{
			$$.nd = $1.nd;
		}
        | binary_expression COMAND unary_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "&");
		}
        | binary_expression '|' unary_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "|");
		}
        | binary_expression '^' unary_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "^");
		}
        | binary_expression LSHIFT unary_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "<<");
		}
        | binary_expression RSHIFT unary_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, ">>");
		}
        ;

multiplicative_expression
        : binary_expression
		{
			$$.nd = $1.nd;
		}
        | multiplicative_expression STAR binary_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "*");
		}
        | multiplicative_expression SLASH binary_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "/");
		}
        ;

additive_expression
        : multiplicative_expression
		{
			$$.nd = $1.nd;
		}
        | additive_expression PLUS multiplicative_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "+");
		}
        | additive_expression MINUS multiplicative_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "-");
		}
        ;

relational_expression
        : additive_expression
		{
			$$.nd = $1.nd;
		}
        | relational_expression LT_OP additive_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "<");
		}
        | relational_expression GT_OP additive_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, ">");
		}
        | relational_expression LE_OP additive_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "<=");
		}
        | relational_expression GE_OP additive_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, ">=");
		}
        ;

equality_expression
        : relational_expression
		{
			$$.nd = $1.nd;
		}
        | equality_expression EQ_OP relational_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "==");
		}
        | equality_expression NE_OP relational_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "!=");
		}
        ;

logical_and_expression
        : equality_expression
		{
			$$.nd = $1.nd;
		}
        | logical_and_expression AND_OP equality_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "&&");
		}
        ;

logical_or_expression
        : logical_and_expression
		{
			$$.nd = $1.nd;
		}
        | logical_or_expression OR_OP logical_and_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "||");
		}
        ;

expression
        : logical_or_expression
		{
			$$.nd = $1.nd;
		}
        | unary_expression EG expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "=");
		}
        ;

declaration
        : declaration_specifiers declarator SEMI
		{
			
			$$.nd = mkNode($1.nd, $2.nd, "declarVar");
			env = addNewVar(env, createVarData(id, type, yylineno));
			sprintf(temp, "%s %s;\n",$1.code, $2.code);
			strcpy($$.code, temp);
			}
        | struct_specifier SEMI
		{
			$$.nd = mkNode($1.nd, NULL, "declarStruct");
		}
        ;

declaration_specifiers
        : EXTERN type_specifier
		{
			struct node *tmp = mkNode(NULL, NULL, "extern");
			$$.nd = mkNode(tmp, $2.nd, "declarSpecif");
			char* temp = malloc(sizeof(char) * (strlen($1.name) + strlen($2.code) + 1));
			sprintf(temp, "extern %s", $2.code);
			strcpy($$.code, temp);
			insert($$.code);
		}
        | type_specifier
		{
			$$.nd = $1.nd;
		}
        ;

type_specifier
        : VOID
		{
			$$.nd = mkNode(NULL, NULL, "void");
			setType(0);
			strcpy($$.code, $1.name);
		}
        | INT
		{
			$$.nd = mkNode(NULL, NULL, "int");
			setType(1);
			strcpy($$.code, $1.name);
		}
        | struct_specifier
		{
			$$.nd = $1.nd;
		}
        ;

struct_specifier
        : STRUCT IDENTIFIER LBR struct_declaration_list RBR
		{
			struct node *tmp = mkNode(NULL, NULL, $2.name);
			$$.nd = mkNode(tmp, $4.nd, "structSpecID");
		}
        | STRUCT LBR struct_declaration_list RBR
		{
			$$.nd = mkNode($3.nd, NULL, "structSpec");
		}
        | STRUCT IDENTIFIER
		{
			struct node *tmp = mkNode(NULL, NULL, $2.name);
			$$.nd = mkNode(tmp, NULL, "structSpecID");
		}
        ;

struct_declaration_list
        : struct_declaration
		{
			$$.nd = $1.nd;
		}
        | struct_declaration_list struct_declaration
		{
			$$.nd = mkNode($1.nd, $2.nd, "structDeclarList");
		}
        ;

struct_declaration
        : type_specifier declarator SEMI 
		{
			$$.nd = mkNode($1.nd, $2.nd, "structDeclar");
		}
        ;

declarator
        : STAR direct_declarator 
		{
			$$.nd = mkNode($2.nd, NULL, "*declar");
			convertToPointer();
			sprintf($$.code, "%c%s", '*', $2.name);
		}
        | direct_declarator
		{
			$$.nd = $1.nd;
			strcpy($$.code, $1.name);
		}
        ;

direct_declarator
        : IDENTIFIER 
		{
			$$.nd = mkNode(NULL, NULL, $1.name);
			setID($1.name);
			strcpy($$.code, $1.name);
		}
        | LPAR declarator RPAR
		{
			$$.nd = mkNode($2.nd, NULL, "(declar)");
			sprintf(temp, "( %s )", $2.name);
			strcpy($$.code,temp);
		}
        | direct_declarator LPAR parameter_list RPAR
		{
			$$.nd = mkNode($1.nd, $3.nd, "directDeclar(...)");
			
			sprintf(temp, " %s( %s )", $1.code, $3.code);
			strcpy($$.code, temp);
			insert($$.code);
		}
        | direct_declarator LPAR RPAR
		{
			$$.nd = mkNode($1.nd, NULL, "directDeclar()");
			char* temp = malloc(sizeof(char) * 50);
			sprintf(temp, "%s()", $1.name);
			strcpy($$.code, temp);
			insert($$.code);
		}
        ;

parameter_list
        : parameter_declaration
		{
			$$.nd = $1.nd;
			sprintf($$.code, $1.code);
			
		}
        | parameter_list COMMA parameter_declaration
		{
			$$.nd = mkNode($1.nd, $3.nd, "paramList");
		}
        ;

parameter_declaration
        : declaration_specifiers declarator
		{
			$$.nd = mkNode($1.nd, $2.nd, "paramDeclar");
			sprintf(temp, "%s %s", $1.code, $2.code);

			strcpy($$.code, temp);
		}
        ;

statement
        : compound_statement
		{
			$$.nd = $1.nd;
		}
        | expression_statement
		{
			if (lookupvar(env, hash($1.name)) != NULL){
				$$.nd = $1.nd;
			} else {
				sprintf(msg, "undeclared variable %s", $1.name);
				return yyerror(msg);
			}
		}
        | selection_statement
		{
			$$.nd = $1.nd;
		}
        | iteration_statement
		{
			$$.nd = $1.nd;
		}
        | jump_statement 
		{
			$$.nd = $1.nd;
		}
        ;

compound_statement
        : LBR RBR
		{
			$$.nd = mkNode(NULL, NULL, "stmts{}");
			strcpy($$.code, "{}");
			
		}
        | LBR statement_list RBR
		{
			$$.nd = mkNode($2.nd, NULL, "stmts{...}");

		}
        | LBR declaration_list RBR
		{
			$$.nd = mkNode($2.nd, NULL, "stmts{...}");

		}
        | LBR declaration_list statement_list RBR
		{
			$$.nd = mkNode($2.nd, $3.nd, "stmts{...}");

		}
		
        ;

declaration_list
        : declaration
		{
			$$.nd = $1.nd;
		}
        | declaration_list declaration
		{
			$$.nd = mkNode($1.nd, $2.nd, "declarList");
			sprintf(temp, "\t%s\t%s", $1.code, $2.code);
			strcpy($$.code, temp);
			insert($$.code);
		}
        ;

statement_list
        : statement	{		$$.nd = $1.nd;		}
        | statement_list statement
		{
			$$.nd = mkNode($1.nd, $2.nd, "stmtsList");
			char* temp = malloc(sizeof(int) * (strlen($1.code) + strlen($2.code)));
			sprintf(temp, "%s\n\t%s", $1.code, $2.code);
			strcpy($$.code, temp);
		}
        ;

expression_statement
        : SEMI
		{
			$$.nd = mkNode(NULL, NULL, ";");
			
		}
        | expression SEMI
		{
			$$.nd = mkNode($1.nd, NULL, "expr");
			sprintf(temp, "%s;", $1.code);
			strcpy($$.code,temp);
			}
        ;

selection_statement
        : IF LPAR expression RPAR statement %prec IFX
		{
			$$.nd = mkNode($3.nd, $5.nd, "if");
		}
        | IF LPAR expression RPAR statement ELSE statement
		{
			struct node *tmp = mkNode($3.nd, $5.nd, "if");
			$$.nd = mkNode(tmp, $7.nd, "ifElse");
		}
        ;


iteration_statement
        : WHILE LPAR expression RPAR statement
		{
			$$.nd = mkNode($3.nd, $5.nd, "while");
		}
        | FOR LPAR expression_statement expression_statement expression RPAR statement
		{
			struct node *cond = mkNode($4.nd, $5.nd, "subCond");
			struct node *condMain = mkNode($3.nd, cond, "condFor");
			$$.nd = mkNode(condMain, $7.nd, "for");
		}
        ;

jump_statement
        : RETURN SEMI
		{
			$$.nd = mkNode(NULL, NULL, "return");
		}
        | RETURN expression SEMI
		{
			$$.nd = mkNode($2.nd, NULL, "returnExpr");
		}
        ;

program 
		: external_declaration 
		{
			$$.nd = mkNode($1.nd, NULL, "program");
			if (head == NULL) {
				head = $$.nd;
			}

			
		}
        | program external_declaration 
		{
			$$.nd = mkNode($1.nd, $2.nd, "program");
			char *prog = malloc(sizeof(char) * (strlen($1.code) + strlen($2.code) + 1));
			sprintf(prog, "%s\n\n%s", $1.code, $2.code);
		}
		;

external_declaration
        : function_definition
		{
			$$.nd = $1.nd;
		}
        | declaration
        {
			$$.nd = $1.nd;
		}
		;

function_definition
        : declaration_specifiers declarator compound_statement
		{
			struct node *sign = mkNode($1.nd, $2.nd, "funcSign");
			struct node *stmts = mkNode($3.nd, NULL, "stmts");
			$$.nd = mkNode(sign, stmts, "functionDef");

			char *function = malloc(sizeof(int) * (strlen($1.code) + strlen($2.code) + strlen($3.code) + 1));
			sprintf(function, "%s %s %s", $1.code, $2.code, $3.code);
			strcpy($$.code, function);
			
		}
        ;

%%

void setID(char *idVal){
	id = strdup(idVal);
}

void setType(int typeVal){
	type = typeVal;
}

void convertToPointer(){
	switch (type){
		case 1:
			type = 4;
			break;
	}
}

// Function to display error messages with line no and token
int yyerror(char *msg)
{       
    printf("Error at line: %d \nMessage: %s \n", (yylineno+comacc), msg);
    return 1;
}
int insert(char* str){
		FILE* fp = fopen("test.txt", "a+");
		if(fp == NULL) {
			printf("insert: file couldn't be opened\n");
			exit(1);
		}
		fprintf(fp, str);
		fclose(fp);
		return 0;
	}
int main(int argc, char* argv[]){

	FILE* out = fopen("test.txt", "w");

    if(out == NULL) {
        printf("structfe: file couldn't be opened to write\n");
        exit(1);
    }

	yyin = fopen(argv[1],"r");
	if (yyin == NULL) {
		printf("file not found: %s!\n", argv[1]);
		return 1;
	}
	if(!yyparse()){
		int *tab = malloc(sizeof(int) * 100);
		tab = getMaxLvlLen(head, tab,  0);
		printVarST(env);
		/* printSyntaxTree_v2(head, tab, -1, 0, 0, 0); 
		printSyntaxTree_v1(head, 0);  */
		printf("\nParsing complete\n");
	}
	else
		printf("Parsing failed\n");
	fclose(yyin);
	return 0;

}
