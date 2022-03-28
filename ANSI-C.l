D                       [0-9] 
L                       [a-zA-Z_] 
H                       [a-fA-F0-9] 
E                       [Ee][+-]?{D}+ 
FS                      (f|F|l|L) 
IS                      (u|U|l|L)*

%{
#include <stdio.h>
#include "y.tab.h"


/* Ne g�re pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%%
"auto"                  { return AUTO; }
"break"                 { return BREAK; }
"case"                  { return CASE; }
"char"                  { return CHAR; }
"const"                 { return CONST; }
"continue"              { return CONTINUE; }
"default"               { return DEFAULT; }
"do"                    { return DO; }
"double"                { return DOUBLE; }
"else"                  { return ELSE; }
"enum"                  { return ENUM; }
"extern"                { return EXTERN; }
"float"                 { return FLOAT; }
"for"                   { return FOR; }
"goto"                  { return GOTO; }
"if"                    { return IF; }
"int"                   { return INT; }
"long"                  { return LONG; }
"register"              { return REGISTER; }
"return"                { return RETURN; }
"short"                 { return SHORT; }
"signed"                { return SIGNED; }
"sizeof"                { return SIZEOF; }
"static"                { return STATIC; }
"struct"                { return STRUCT; }
"switch"                { return SWITCH; }
"typedef"               { return TYPEDEF; }
"union"                 { return UNION; }
"unsigned"              { return UNSIGNED; }
"void"                  { return VOID; }
"volatile"              { return VOLATILE; }
"while"                 { return WHILE; }

{L}({L}|{D})*           { return IDENTIFIER ; }

0[xX]{H}+{IS}?          { return CONSTANT; }
0{D}+{IS}?              { return CONSTANT; }
{D}+{IS}?               { return CONSTANT; }
L?'(\\.|[^\\'])+'       {} /* pas trop compris celle là
# any of (letter, uppercase, one of "_"), optional, literally "'",
capture (any of ((backslash, anything), none of \\'))
, once or more */

{D}+{E}{FS}?            { return CONSTANT; }
{D}*"."{D}+({E})?{FS}?  {}
{D}+"."{D}*({E})?{FS}?  {}

L?\"(\\.|[^\\"])*\"     {}

"..."                   {}
">>="                   { return RSHIFT_ASSIGN; }
"<<="                   { return LSHIFT_ASSIGN; }
"+="                    { return ADD_ASSIGN; }
"-="                    { return SUB_ASSIGN; }
"*="                    { return MUL_ASSIGN; }
"/="                    { return DIV_ASSIGN; }
"%="                    { return MOD_ASSIGN; }
"&="                    { return BIT_AND_ASSIGN; }
"^="                    { return BIT_XOR_ASSIGN; }
"|="                    { return BIT_OR_ASSIGN; }
">>"                    { return RSHIFT; }
"<<"                    { return LSHIFT; }
"<"                     { return LT_OP; }
"<="                    { return LE_OP; }
">"                     { return GT_OP; }
">="                    { return GE_OP; }
"++"                    { return INC; }
"--"                    { return DEC; }
"->"                    { return POINTER_STRC; }
"&&"                    { return AND_OP; }
"||"                    { return OR_OP; }
"=="                    { return EQ_OP; }
"!="                    { return NE_OP; }
"+"                     { return PLUS; }
"*"                     { return PTR_OP; }
"/"                     { return DIV; }
"-"                     { return MINUS; }

[ \t\v\n\f]             { }
.                       { return yytext[0]; }
%%
int yywrap (void) {return 1;}
int main(){
    yylex();
    return 1;
}
int yyerror(char *errormsg)
{
    fprintf(stderr, "%s\n", errormsg);
    exit(1);
}