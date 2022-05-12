%{
  	#include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <ctype.h>

	int yylex(void);
	int yyerror(char *msg);
	int yywrap();

	struct dataType {
        char * id_name;
        char * data_type;
        char * type;
        int line_no;
    } symbolTable[150];

	struct node { 
		char *token; 
		struct node *childL; 
		struct node *childR;  
    };

    int count=0;
    int q;
    char type[10];
    extern int countn;
	extern char *yytext;
    struct node *head;

	void add(char);
    void insert_type(void);
    int search(char *);
    void printTree(struct node *, int);
    void printInorder(struct node *);
    struct node* mkNode(struct node *childL, struct node *childR, char *token);
	
%}

%union { 
	struct var_name { 
		char name[100]; 
		struct node* nd;
	} nd_obj; 
} 

%token <nd_obj>  IDENTIFIER CONSTANT SIZEOF 
%token <nd_obj>  PTR_OP LE_OP GE_OP EQ_OP NE_OP LT_OP GT_OP
%token <nd_obj>  AND_OP OR_OP
%token <nd_obj>  AUTO SWITCH CASE
%token <nd_obj>  UNION 
%token <nd_obj>  EXTERN REGISTER STATIC TYPEDEF VOLATILE
%token <nd_obj>  INT VOID DOUBLE CHAR FLOAT LONG SHORT SIGNED UNSIGNED
%token <nd_obj>  CONST
%token <nd_obj>  STRUCT DEFAULT ENUM
%token <nd_obj>  IF ELSE WHILE FOR RETURN BREAK CONTINUE DO GOTO 
%token <nd_obj>  INC DEC
%token <nd_obj>  ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token <nd_obj>  RSHIFT_ASSIGN LSHIFT_ASSIGN BIT_AND_ASSIGN BIT_OR_ASSIGN BIT_XOR_ASSIGN
%token <nd_obj>  RSHIFT LSHIFT

%type <nd_obj> primary_expression postfix_expression argument_expression_list unary_expression unary_operator
%type <nd_obj> binary_expression multiplicative_expression additive_expression relational_expression equality_expression
%type <nd_obj> logical_and_expression logical_or_expression expression declaration declaration_specifiers
%type <nd_obj> type_specifier struct_specifier struct_declaration_list struct_declaration declarator
%type <nd_obj> direct_declarator parameter_list parameter_declaration statement compound_statement
%type <nd_obj> declaration_list statement_list expression_statement selection_statement iteration_statement
%type <nd_obj> jump_statement program external_declaration function_definition

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
		}
        | INT
		{
			$$.nd = mkNode(NULL, NULL, "int");
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

// Function to display error messages with line no and token
int yyerror(char *msg)
{
    printf("Error message: %s\n", msg);
    return 0;
}

int main(){
	yyparse();
	printf("\t\t\t\t\t\t PHASE 2: SYNTAX ANALYSIS \n\n");
	printTree(head, 1); 
	return 1;
}

int search(char *type) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbolTable[i].id_name, type)==0) {
			return -1;
			break;
		}
	}
	return 0;
}

void add(char c) {
    q=search(yytext);
	if(q==0) {
		if(c=='H') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Header");
			count++;
		}
		else if(c=='K') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("N/A");
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Keyword\t");
			count++;
		}
		else if(c=='V') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup(type);
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Variable");
			count++;
		}
		else if(c=='C') {
			symbolTable[count].id_name=strdup(yytext);
			symbolTable[count].data_type=strdup("CONST");
			symbolTable[count].line_no=countn;
			symbolTable[count].type=strdup("Constant");
			count++;
		}
    }
}

struct node* mkNode(struct node *childL, struct node *childR, char *token) {	
	struct node *newNode = (struct node *)malloc(sizeof(struct node));
	char *newStr = (char *)malloc(strlen(token)+1);

	strcpy(newStr, token);
	newNode->childL = childL;
	newNode->childR = childR;
	newNode->token = newStr;
	return(newNode);
}

void printSpace(int c) {
	printf("\n");
	for (int i = 0; i < c; i++) {
		printf(" ");
	}
}

void printTree(struct node* tree, int c) {
	printSpace(c);
	printf("--> %s", tree->token);
	if (tree->childL) {
		printTree(tree->childL, c + 2);
	}
	if (tree->childR) {
		printTree(tree->childR, c + 2);
	}
}

void insert_type() {
	strcpy(type, yytext);
}