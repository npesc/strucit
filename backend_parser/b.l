%{
#include <stdio.h>
#include "y.tab.h"
void yyerror(char*);
%}

D                       [0-9] 
L                       [a-zA-Z_] 
IS                      (u|U|l|L)*
com                     \/\*.*\*\/


%%
"const"                 { return CONST; }
"extern"                { printf("%s\n",yytext); return EXTERN; }
"goto"                  { return GOTO; }
"if"                    { return IF; }
"int"                   { return INT; }
"return"                { return RETURN; }
"void"                  { return VOID; }

(\*)*{L}({L}|{D})*           {printf("%s\n",yytext); return IDENTIFIER; }

0{D}+{IS}?              { return CONST; }
{D}+{IS}?               { return CONST; }
L?'(\\.|[^\\'])+'       {} /* pas trop compris celle là
# any of (letter, uppercase, one of "_"), optional, literally "'",
capture (any of ((backslash, anything), none of \\'))
, once or more */
{com}             {}


"<"                     { return LT_OP; }
"<="                    { return LE_OP; }
">"                     { return GT_OP; }
">="                    { return GE_OP; }
"=="                    { return EQ_OP; }
"!="                    { return NE_OP; }
"*"                     { printf("%s",yytext);return STAR;}

"\n"                    { yylineno++; }

[ \t\v\n\f]             { }
.                       { return yytext[0];}
%%

int yywrap (void) {
    return 1;
}
