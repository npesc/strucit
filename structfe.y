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
	extern int countn;
	extern int comacc;
	extern char yytext[];
	
	struct node *head;
	struct node *headArray[100];
	
	int type; //data type
	int typeReturn; //return data type
	int returnFlag = 0; //flag to check return data
	int globalFlag = 1; //flag to check if var is global or local
	int *argsType; //array to keep params type
	int nature = -1; //flag to determine if we declared a variable or a fuction
	int argsLen = 0; //count number of argument on function definition

	int programNb = 0; //count program start
	

	char *varID; //variable's identifier
	char *funcID; //function's identifier 
	char *structID; //structure's identifier

	int fieldsLen = 0; //count number of structure's field
		
	int *tmpFieldsType; //variable used to stock fields type of structure
	char **tmpFieldsName; //variable used to stock fields name of structure
	char **tmpParamsName; //variable used to stock params name of function

	varEnv *envVar; //variable's ST
	structEnv *envStruct; //struct's ST
	funcEnv *envFunc; //function's ST

	void setVarID(char *idVal);
	void setFuncID(char *idVal);
	void setStructID(char *idVal);
	void setType(int typeVal);
	void convertToPointer(void);
	void check2OperInt(char *n1, char *n2);

	// nature :
	// 	0 -> variable
	// 	1 -> function
	// 	2 -> structure

	//VARIABLES FOR CODE GENERATION
	int isPointer = 0;
	int ifLabelCounter = 0;
	int iterLabelCounter = 0;

	char *generatedCode;
%}

%union { 
	struct var_name { 
		char name[100]; 
		char code[5000];
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
%token <ndObj>  RSHIFT LSHIFT BAR UP

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
			sprintf($$.code, "%s", $1.name);
			$$.nd = mkNode(NULL, NULL, $1.name);

			setVarID($1.name);
			//setFuncID($1.name); //ADDED -> THERE IS NO ERROR?
		}
        | CONSTANT
		{
			sprintf($$.code, "%s", $1.name);
			$$.nd = mkNode(NULL, NULL, $1.name);
		} 
        | LPAR expression RPAR
		{
			sprintf($$.code, "%s", $2.code);
			$$.nd = $2.nd;
		}
        ;

postfix_expression
        : primary_expression
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | postfix_expression LPAR RPAR
		{
			sprintf($$.code, "%s()", $1.code);
			$$.nd = mkNode($1.nd, NULL, "func()");

			if (checkFuncExists(envFunc, hash(funcID)) == -1){
				logError(102);
			}
		}
        | postfix_expression LPAR argument_expression_list RPAR
		{
			sprintf($$.code, "%s(%s)", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "func(...)");

			if (checkFuncExists(envFunc, hash(funcID)) == -1){
				logError(102);
			}
		}
        | postfix_expression '.' IDENTIFIER
		{
			sprintf($$.code, "%s.%s", $1.code, $3.name);
			$$.nd = mkNode($1.nd, $3.nd, "struct.id");

			int varType = getVarType(envVar, hash(structID)); //We take the var type
			if (varType < -2){
				varType = varType * -1;
			}
			if (checkFieldExists(envStruct, varType, $3.name) == -1){ //We look if the structure has a such field
				logError(103);
			}
		}
        | postfix_expression PTR_OP IDENTIFIER
		{
			sprintf($$.code, "%s->%s", $1.code, $3.name);
			$$.nd = mkNode($1.nd, $3.nd, "struct->id");

			int varType = getVarType(envVar, hash(structID)); //We take the var type
			if (varType < -2){
				varType = varType * -1;
			}
			if (checkFieldExists(envStruct, varType, $3.name) == -1){ //We look if the structure has a such field
				logError(103);
			}
		}
        ;

argument_expression_list
        : expression
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | argument_expression_list COMMA expression
		{	
			sprintf($$.code, "%s, %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "argExpList");
		}
        ;

unary_expression
        : postfix_expression
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | unary_operator unary_expression
		{
			sprintf($$.code, "%s %s", $1.code, $2.code);
			$$.nd = mkNode($1.nd, $2.nd, "unaryExp");
		}
        | SIZEOF unary_expression
		{
			sprintf($$.code, "sizeof(%d)", getSizeOf(envVar, envStruct, envFunc, hash(varID))); //Due to getSizeOf we check if the sizeof'param exists
			struct node *tmp = mkNode(NULL, NULL, "sizeof");
			$$.nd = mkNode(tmp, $2.nd, "unaryExp");
		}
        | SIZEOF LPAR type_specifier RPAR
		{
			sprintf($$.code, "sizeof(%d)", getSizeOf(envVar, envStruct, envFunc, hash(varID))); //Due to getSizeOf we check if the sizeof'param exists
			struct node *tmp = mkNode(NULL, NULL, "sizeof");
			$$.nd = mkNode(tmp, $3.nd, "unaryExp");
		}
        ;

unary_operator
        : COMAND
		{
			sprintf($$.code, "&");
			$$.nd = mkNode(NULL, NULL, "&");
		}
        | STAR
		{
			sprintf($$.code, "*");
			$$.nd = mkNode(NULL, NULL, "*");
		}
        | MINUS
		{
			sprintf($$.code, "-");
			$$.nd = mkNode(NULL, NULL, "-");
		}
        ;

//BITWISE OPERATOR ACCEPT ONLY INT -> We check if var or function return type are int
binary_expression
        : unary_expression
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | binary_expression COMAND unary_expression
		{
			sprintf($$.code, "%s & %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "&");

			check2OperInt($1.name, $3.name);			
		}
        | binary_expression BAR unary_expression
		{
			sprintf($$.code, "%s | %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "|");

			check2OperInt($1.name, $3.name);
		}
        | binary_expression UP unary_expression
		{
			sprintf($$.code, "%s ^ %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "^");

			check2OperInt($1.name, $3.name);
		}
        | binary_expression LSHIFT unary_expression
		{
			sprintf($$.code, "%s << %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "<<");

			check2OperInt($1.name, $3.name);
		}
        | binary_expression RSHIFT unary_expression
		{
			sprintf($$.code, "%s >> %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, ">>");

			check2OperInt($1.name, $3.name);
		}
        ;

multiplicative_expression
        : binary_expression
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | multiplicative_expression STAR binary_expression
		{
			sprintf($$.code, "%s * %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "*");

			check2OperInt($1.name, $3.name);
		}
        | multiplicative_expression SLASH binary_expression
		{
			sprintf($$.code, "%s / %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "/");

			check2OperInt($1.name, $3.name);
		}
        ;

additive_expression
        : multiplicative_expression
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | additive_expression PLUS multiplicative_expression
		{
			sprintf($$.code, "%s + %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "+");

			check2OperInt($1.name, $3.name);
		}
        | additive_expression MINUS multiplicative_expression
		{
			sprintf($$.code, "%s - %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "-");

			check2OperInt($1.name, $3.name);
		}
        ;

relational_expression
        : additive_expression
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | relational_expression LT_OP additive_expression
		{
			sprintf($$.code, "%s >= %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "<");

			check2OperInt($1.name, $3.name);
		}
        | relational_expression GT_OP additive_expression
		{
			sprintf($$.code, "%s <= %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, ">");

			check2OperInt($1.name, $3.name);
		}
        | relational_expression LE_OP additive_expression
		{
			sprintf($$.code, "%s > %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "<=");

			check2OperInt($1.name, $3.name);
		}
        | relational_expression GE_OP additive_expression
		{
			sprintf($$.code, "%s < %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, ">=");

			check2OperInt($1.name, $3.name);
		}
        ;

equality_expression
        : relational_expression
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | equality_expression EQ_OP relational_expression
		{
			sprintf($$.code, "%s != %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "==");

			check2OperInt($1.name, $3.name);
		}
        | equality_expression NE_OP relational_expression
		{
			sprintf($$.code, "%s == %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "!=");

			check2OperInt($1.name, $3.name);
		}
        ;

logical_and_expression
        : equality_expression
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | logical_and_expression AND_OP equality_expression
		{
			sprintf($$.code, "%s || %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "&&");
		}
        ;

logical_or_expression
        : logical_and_expression
		{
			sprintf($$.code, "%s", $1.code);	
			$$.nd = $1.nd;
		}
        | logical_or_expression OR_OP logical_and_expression
		{
			sprintf($$.code, "%s && %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "||");
		}
        ;

expression
        : logical_or_expression
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | unary_expression EG expression
		{
			sprintf($$.code, "%s = %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "=");

			lookupvar(envVar, hash($1.name));
		}
        ;

declaration
        : declaration_specifiers declarator SEMI
		{
			sprintf($$.code, "%s %s;", $1.code, $2.code);
			$$.nd = mkNode($1.nd, $2.nd, "declarVar");

			if (nature == 0){
				if (checkVarFuncExists(envVar, envFunc, hash(varID)) == 1){
					logError(107);
				}
				envVar = addNewVar(envVar, createVarData(varID, type, globalFlag, yylineno));
			} else {
				if (checkVarFuncExists(envVar, envFunc, hash(funcID)) == 1){
					logError(108);
				}
				envFunc = addNewFunc(envFunc, createFuncData(funcID, typeReturn, argsType, argsLen, tmpParamsName, yylineno));
				typeReturn = 0;
				returnFlag = 0;
				argsLen = 0;
				argsType = NULL;
				tmpParamsName = NULL;
			}
		}
        | struct_specifier SEMI
		{
			sprintf($$.code, " ");
			$$.nd = mkNode($1.nd, NULL, "declarStruct");

			envStruct = addNewStruct(envStruct, createStructData(structID, tmpFieldsType, fieldsLen, tmpFieldsName, yylineno));
			tmpFieldsType = NULL;
			fieldsLen = 0;
			tmpFieldsName = NULL;
		}
        ;

declaration_specifiers
        : EXTERN type_specifier
		{
			sprintf($$.code, "extern %s", $2.code);
			struct node *tmp = mkNode(NULL, NULL, "extern");
			$$.nd = mkNode(tmp, $2.nd, "declarSpecif");
		}
        | type_specifier
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        ;

type_specifier
        : VOID
		{
			sprintf($$.code, "void");
			$$.nd = mkNode(NULL, NULL, "void");

			setType(0);
		}
        | INT
		{
			sprintf($$.code, "int");
			$$.nd = mkNode(NULL, NULL, "int");

			setType(1);
		}
        | struct_specifier
		{
			sprintf($$.code, "void *");
			$$.nd = $1.nd;
		}
        ;

struct_specifier
        : STRUCT IDENTIFIER LBR struct_declaration_list RBR
		{
			sprintf($$.code, "");
			struct node *tmp = mkNode(NULL, NULL, $2.name);
			$$.nd = mkNode(tmp, $4.nd, "structSpecID{...}");
			
			setStructID($2.name);
			setType(hash(structID));
		}
        | STRUCT LBR struct_declaration_list RBR
		{
			sprintf($$.code, "");
			$$.nd = mkNode($3.nd, NULL, "structSpec");
		}
        | STRUCT IDENTIFIER
		{
			sprintf($$.code, "");
			struct node *tmp = mkNode(NULL, NULL, $2.name);
			$$.nd = mkNode(tmp, NULL, "structSpecID");

			setStructID($2.name);
			setType(hash(structID));
		}
        ;

struct_declaration_list
        : struct_declaration
		{
			sprintf($$.code, "");
			$$.nd = $1.nd;
		}
        | struct_declaration_list struct_declaration
		{
			sprintf($$.code, "%s\n%s", $1.code, $2.code);
			$$.nd = mkNode($1.nd, $2.nd, "structDeclarList");
		}
        ;

struct_declaration
        : type_specifier declarator SEMI 
		{
			sprintf($$.code, "");
			$$.nd = mkNode($1.nd, $2.nd, "structDeclar");

			fieldsLen++;
			tmpFieldsType = addNewIntArray(tmpFieldsType, fieldsLen, type);
			tmpFieldsName = addNewCharArray(tmpFieldsName, fieldsLen, structID);
		}
        ;

declarator
        : STAR direct_declarator 
		{
			sprintf($$.code, "*%s", $2.code);
			$$.nd = mkNode($2.nd, NULL, "*declar");

			if (nature == 1){
				returnFlag = -1;
			}
			convertToPointer();
		}
        | direct_declarator
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        ;

direct_declarator
        : IDENTIFIER 
		{
			sprintf($$.code, "%s", $1.name);
			$$.nd = mkNode(NULL, NULL, $1.name);

			setVarID($1.name);
			setStructID($1.name);
			nature = 0;
		}
        | LPAR declarator RPAR
		{
			sprintf($$.code, "(%s)", $2.code);
			$$.nd = mkNode($2.nd, NULL, "(declar)");

			nature = 1;
		}
        | direct_declarator LPAR parameter_list RPAR
		{
			sprintf($$.code, "%s(%s)", $1.code, $2.code);
			$$.nd = mkNode($1.nd, $3.nd, "directDeclar(...)");

			setFuncID($1.name);
			nature = 1;
			globalFlag = 0;
		}
        | direct_declarator LPAR RPAR
		{
			sprintf($$.code, "%s()", $1.code);
			$$.nd = mkNode($1.nd, NULL, "directDeclar()");

			setFuncID($1.name);
			nature = 1;
			globalFlag = 0;
		}
        ;

parameter_list
        : parameter_declaration
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | parameter_list COMMA parameter_declaration
		{
			sprintf($$.code, "%s, %s", $1.code, $3.code);
			$$.nd = mkNode($1.nd, $3.nd, "paramList");
		}
        ;

parameter_declaration
        : declaration_specifiers declarator
		{
			sprintf($$.code, "%s %s", $1.code, $2.code);
			$$.nd = mkNode($1.nd, $2.nd, "paramDeclar");

			argsLen++;
			argsType = addNewIntArray(argsType, argsLen, type);
			tmpParamsName = addNewCharArray(tmpParamsName, argsLen, varID);
		}
        ;

statement
        : compound_statement
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | expression_statement
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | selection_statement
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | iteration_statement
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | jump_statement 
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        ;

compound_statement
        : LBR RBR
		{
			sprintf($$.code, "{}\n");
			$$.nd = mkNode(NULL, NULL, "stmts{}");
		}
        | LBR statement_list RBR
		{
			sprintf($$.code, "{\n%s\n}\n", $2.code);
			$$.nd = mkNode($2.nd, NULL, "stmts{...}");
		}
        | LBR declaration_list RBR
		{
			sprintf($$.code, "{\n%s\n}\n", $2.code);
			$$.nd = mkNode($2.nd, NULL, "stmts{...}");
		}
        | LBR declaration_list statement_list RBR
		{
			sprintf($$.code, "{\n%s\n%s\n}\n", $2.code, $3.code);
			$$.nd = mkNode($2.nd, $3.nd, "stmts{...}");
		}
        ;

declaration_list
        : declaration
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | declaration_list declaration
		{
			sprintf($$.code, "%s\n%s", $1.code, $2.code);
			$$.nd = mkNode($1.nd, $2.nd, "declarList");
		}
        ;

statement_list
        : statement
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | statement_list statement
		{
			sprintf($$.code, "%s\n%s", $1.code, $2.code);
			$$.nd = mkNode($1.nd, $2.nd, "stmtsList");
		}
        ;

expression_statement
        : SEMI
		{
			sprintf($$.code, ";");
			$$.nd = mkNode(NULL, NULL, ";");
		}
        | expression SEMI
		{
			sprintf($$.code, "%s;", $1.code);
			$$.nd = mkNode($1.nd, NULL, "expr");
		}
        ;

selection_statement
        : IF LPAR expression RPAR statement %prec IFX
		{
			sprintf($$.code, "if (%s) goto condLabel_%d;\n%s\ncondLabel_%d:\n", $3.code, ifLabelCounter, $5.code, ifLabelCounter);
			$$.nd = mkNode($3.nd, $5.nd, "if");

			ifLabelCounter++;
		}
        | IF LPAR expression RPAR statement ELSE statement
		{
			sprintf($$.code, "if (%s) goto condLabel_%d;\n%s\ncondLabel_%d:\n%s\n", $3.code, ifLabelCounter,$5.code,ifLabelCounter,$7.code);
			struct node *tmp = mkNode($3.nd, $5.nd, "if");
			$$.nd = mkNode(tmp, $7.nd, "ifElse");

			ifLabelCounter++;
		}
        ;


iteration_statement
        : WHILE LPAR expression RPAR statement
		{
			sprintf($$.code, "iterTest_%d:\nif (%s) goto iterLabel_%d;\n%s\ngoto iterTest_%d;\niterLabel_%d:\n", iterLabelCounter, $3.code, iterLabelCounter, $5.code, iterLabelCounter, iterLabelCounter);
			$$.nd = mkNode($3.nd, $5.nd, "while");

			iterLabelCounter++;
		}
        | FOR LPAR expression_statement expression_statement expression RPAR statement
		{
			sprintf($$.code, "%s\niterTest_%d:\nif (%s) goto iterLabel_%d;\n%s%s\ngoto iterTest_%d;\niterLabel_%d:\n", $3.code, iterLabelCounter, $4.code, iterLabelCounter, $7.code, $5.code, iterLabelCounter, iterLabelCounter);
			struct node *cond = mkNode($4.nd, $5.nd, "subCond");
			struct node *condMain = mkNode($3.nd, cond, "condFor");
			$$.nd = mkNode(condMain, $7.nd, "for");

			iterLabelCounter++;
		}
        ;

jump_statement
        : RETURN SEMI
		{
			sprintf($$.code, "return ;");
			$$.nd = mkNode(NULL, NULL, "return");
		}
        | RETURN expression SEMI
		{
			sprintf($$.code, "return %s;", $2.code);
			$$.nd = mkNode($2.nd, NULL, "returnExpr");
		}
        ;

program 
		: external_declaration 
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = mkNode($1.nd, NULL, "program");

			headArray[programNb] = $$.nd;
			programNb++;
			returnFlag = 0;
		}
        | program external_declaration 
		{
			sprintf($$.code, "%s\n%s", $1.code, $2.code);
			$$.nd = mkNode($1.nd, $2.nd, "program");
			// printf("\n\nResultat:\n\n%s\n\n", replaceWord($$.code, "  ", " "));
			generatedCode = replaceWord($$.code, "  ", " ");
			headArray[programNb] = $$.nd;
			programNb++;
		}
		;

external_declaration
        : function_definition
		{
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
        | declaration
        {
			sprintf($$.code, "%s", $1.code);
			$$.nd = $1.nd;
		}
		;

function_definition
        : declaration_specifiers declarator compound_statement
		{
			sprintf($$.code, "%s %s %s\n", $1.code, $2.code, $3.code);
			struct node *sign = mkNode($1.nd, $2.nd, "funcSign");
			struct node *stmts = mkNode($3.nd, NULL, "stmts");
			$$.nd = mkNode(sign, stmts, "functionDef");

			envFunc = addNewFunc(envFunc, createFuncData(funcID, type, argsType, argsLen, tmpParamsName, yylineno));
			typeReturn = 0;
			returnFlag = 0;
			argsLen = 0;
			globalFlag = 1;
			argsType = NULL;
			tmpParamsName = NULL;

			deleteNonGlobal(&envVar);
		}
        ;

%%

void setVarID(char *idVal){
	varID = strdup(idVal);
}

void setFuncID(char *idVal){
	funcID = strdup(idVal);
}

void setStructID(char *idVal){
	structID = strdup(idVal);
}

void setType(int typeVal){
	type = typeVal;
	if (returnFlag == 0){
		typeReturn = typeVal;
		returnFlag = -2;
	}
}

void convertToPointer(){
	type *= -1;
	if (returnFlag == -1){ 
		typeReturn *= -1;
	}
}

void check2OperInt(char *n1, char *n2){
	if (checkStringIsInt(n1) == 1){
		if (checkStringIsInt(n2) != 1 && checkVarFuncType(envVar, envFunc, funcID, hash(n2)) != 1){
			logError(105);
		}
	} else if (checkStringIsInt(n2) == 1) {
		if (checkStringIsInt(n1) != 1 && checkVarFuncType(envVar, envFunc, funcID, hash(n1)) != 1){
			logError(105);
		}
	}else if(checkVarFuncType(envVar, envFunc, funcID, hash(n1)) == 1){
		if (checkStringIsInt(n2) != 1 && checkVarFuncType(envVar, envFunc, funcID, hash(n2)) != 1){
			logError(105);
		}
	}else if (checkVarFuncType(envVar, envFunc, funcID, hash(n2)) == 1) {
		if (checkStringIsInt(n1) != 1 && checkVarFuncType(envVar, envFunc, funcID, hash(n1)) != 1){
			logError(105);
		}
	} else {
		logError(105);
	}
}

// Function to display error messages with line no and token
int yyerror(char *msg)
{       
    printf("Line no: %d Error message: %s \n", (yylineno+comacc), msg);
    return 1;
}
int main(int argc, char* argv[]){
	yyin = fopen(argv[1],"r");

	if (yyin == NULL) {
		printf("file not found: %s!\n", argv[1]);
		return 1;
	}

	if (!yyparse()){
		/* writeFile(generatedCode); */
		
		printVarST(envStruct, envVar);
		printFuncST(envStruct, envFunc);
		printStructST(envStruct);

		printDashes(25);
		printf("Syntax Tree");
		printDashes(25);

		head = headArray[programNb - 1];

		//syntax tree v1
		/* int *tab = malloc(sizeof(int) * 100);
		tab = getMaxLvlLen(head, tab,  0);
		printSyntaxTree_v2(head, tab, -1, 0, 0, 0);  */

		//syntax tree v1
		printSyntaxTree_v1(head, 0);

		printf("\n");

		printf("\nParsing complete\n");
	} else {
		printf("Parsing failed\n");
	}

	fclose(yyin);
	return 0;

}
