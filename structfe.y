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

    extern int countn;
	extern FILE *fp;
	extern FILE* yyin;
	extern int yylineno;
	extern char yytext[];
	extern int comacc;

	int type;
	char *id;
    struct node *head;
	varEnv *env;

	void setID(char *idVal);
	void setType(int typeVal);
	void convertToPointer(void);
%}

%union { 
	struct var_name { 
		char name[100]; 
		struct node* nd;
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

%type <ndObj> primary_expression postfix_expression argument_expression_list unary_expression unary_operator
%type <ndObj> binary_expression multiplicative_expression additive_expression relational_expression equality_expression
%type <ndObj> logical_and_expression logical_or_expression expression declaration declaration_specifiers
%type <ndObj> type_specifier struct_specifier struct_declaration_list struct_declaration declarator
%type <ndObj> direct_declarator parameter_list parameter_declaration statement compound_statement
%type <ndObj> declaration_list statement_list expression_statement selection_statement iteration_statement
%type <ndObj> jump_statement program external_declaration function_definition

%left '&'
%left '*'
%left '-'

%nonassoc IFX
%nonassoc ELSE

%start program

%%

primary_expression
        : IDENTIFIER 
		{
			$$.nd = mkNode(NULL, NULL, $1.name);
			setID($1.name);
		}
        | CONSTANT
		{
			$$.nd = mkNode(NULL, NULL, $1.name);
		} 
        | '(' expression ')'
		{
			$$.nd = $2.nd;
		}
        ;

postfix_expression
        : primary_expression
		{
			$$.nd = $1.nd;
		}
        | postfix_expression '(' ')'
		{
			$$.nd = mkNode($1.nd, NULL, "func()");
		}
        | postfix_expression '(' argument_expression_list ')'
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
        | argument_expression_list ',' expression
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
        | SIZEOF '(' type_specifier ')'
		{
			struct node *tmp = mkNode(NULL, NULL, "sizeof");
			$$.nd = mkNode(tmp, $3.nd, "unaryExp");
		}
        ;

unary_operator
        : '&'
		{
			$$.nd = mkNode(NULL, NULL, "&");
		}
        | '*'
		{
			$$.nd = mkNode(NULL, NULL, "*");
		}
        | '-'
		{
			$$.nd = mkNode(NULL, NULL, "-");
		}
        ;

binary_expression
        : unary_expression
		{
			$$.nd = $1.nd;
		}
        | binary_expression '&' unary_expression
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
        | multiplicative_expression '*' binary_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "*");
		}
        | multiplicative_expression '/' binary_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "/");
		}
        ;

additive_expression
        : multiplicative_expression
		{
			$$.nd = $1.nd;
		}
        | additive_expression '+' multiplicative_expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "+");
		}
        | additive_expression '-' multiplicative_expression
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
        | unary_expression '=' expression
		{
			$$.nd = mkNode($1.nd, $3.nd, "=");
		}
        ;

declaration
        : declaration_specifiers declarator ';'
		{
			$$.nd = mkNode($1.nd, $2.nd, "declarVar");
			env = addNewVar(env, createVarData(id, type, countn));
		}
        | struct_specifier ';'
		{
			$$.nd = mkNode($1.nd, NULL, "declarStruct");
		}
        ;

declaration_specifiers
        : EXTERN type_specifier
		{
			struct node *tmp = mkNode(NULL, NULL, "extern");
			$$.nd = mkNode(tmp, $2.nd, "declarSpecif");
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
		}
        | INT
		{
			$$.nd = mkNode(NULL, NULL, "int");
			setType(1);
		}
        | struct_specifier
		{
			$$.nd = $1.nd;
		}
        ;

struct_specifier
        : STRUCT IDENTIFIER '{' struct_declaration_list '}'
		{
			struct node *tmp = mkNode(NULL, NULL, $2.name);
			$$.nd = mkNode(tmp, $4.nd, "structSpecID");
		}
        | STRUCT '{' struct_declaration_list '}'
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
        : type_specifier declarator ';' 
		{
			$$.nd = mkNode($1.nd, $2.nd, "structDeclar");
		}
        ;

declarator
        : '*' direct_declarator 
		{
			$$.nd = mkNode($2.nd, NULL, "*declar");
			convertToPointer();
		}
        | direct_declarator
		{
			$$.nd = $1.nd;
		}
        ;

direct_declarator
        : IDENTIFIER 
		{
			$$.nd = mkNode(NULL, NULL, $1.name);
			setID($1.name);
		}
        | '(' declarator ')'
		{
			$$.nd = mkNode($2.nd, NULL, "(declar)");
		}
        | direct_declarator '(' parameter_list ')'
		{
			$$.nd = mkNode($1.nd, $3.nd, "directDeclar(...)");
		}
        | direct_declarator '(' ')'
		{
			$$.nd = mkNode($1.nd, NULL, "directDeclar()");
		}
        ;

parameter_list
        : parameter_declaration
		{
			$$.nd = $1.nd;
		}
        | parameter_list ',' parameter_declaration
		{
			$$.nd = mkNode($1.nd, $3.nd, "paramList");
		}
        ;

parameter_declaration
        : declaration_specifiers declarator
		{
			$$.nd = mkNode($1.nd, $2.nd, "paramDeclar");
		}
        ;

statement
        : compound_statement
		{
			$$.nd = $1.nd;
		}
        | expression_statement
		{
			$$.nd = $1.nd;
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
        : '{' '}'
		{
			$$.nd = mkNode(NULL, NULL, "stmts{}");
		}
        | '{' statement_list '}'
		{
			$$.nd = mkNode($2.nd, NULL, "stmts{...}");
		}
        | '{' declaration_list '}'
		{
			$$.nd = mkNode($2.nd, NULL, "stmts{...}");
		}
        | '{' declaration_list statement_list '}'
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
		}
        ;

statement_list
        : statement
		{
			$$.nd = $1.nd;
		}
        | statement_list statement
		{
			$$.nd = mkNode($1.nd, $2.nd, "stmtsList");
		}
        ;

expression_statement
        : ';'
		{
			$$.nd = mkNode(NULL, NULL, ";");
		}
        | expression ';'
		{
			$$.nd = mkNode($1.nd, NULL, "expr");
		}
        ;

selection_statement
        : IF '(' expression ')' statement %prec IFX
		{
			$$.nd = mkNode($3.nd, $5.nd, "if");
		}
        | IF '(' expression ')' statement ELSE statement
		{
			struct node *tmp = mkNode($3.nd, $5.nd, "if");
			$$.nd = mkNode(tmp, $7.nd, "ifElse");
		}
        ;


iteration_statement
        : WHILE '(' expression ')' statement
		{
			$$.nd = mkNode($3.nd, $5.nd, "while");
		}
        | FOR '(' expression_statement expression_statement expression ')' statement
		{
			struct node *cond = mkNode($4.nd, $5.nd, "subCond");
			struct node *condMain = mkNode($3.nd, cond, "condFor");
			$$.nd = mkNode(condMain, $7.nd, "for");
		}
        ;

jump_statement
        : RETURN ';'
		{
			$$.nd = mkNode(NULL, NULL, "return");
		}
        | RETURN expression ';'
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
    printf("Line no: %d Error message: %s Token: %s\n", (yylineno+comacc), msg, yytext);
    return 1;
}
int main(int argc, char* argv[]){
	yyin = fopen(argv[1],"r");
	if (yyin == NULL) {
		printf("file not found: %s!\n", argv[1]);
		return 1;
	}
	if(!yyparse()){
		int *tab = malloc(sizeof(int) * 100);
		tab = getMaxLvlLen(head, tab,  0);
		printVarST(env);
		printf("Parsing complete\n");
	}
	else
		printf("Parsing failed\n");
	fclose(yyin);
	return 0;

	/* printSyntaxTree_v2(head, tab, -1, 0, 0, 0);  */
	/* printSyntaxTree_v1(head, 0);  */
}
