%{
#include <stdio.h>
#include "y.tab.h"

%}

D                       [0-9] 
L                       [a-zA-Z_] 
IS                      (u|U|l|L)*
com                     \/\*.*\*\/


%%
"const"                 { return CONST; }
"extern"                { return EXTERN; }
"goto"                  { return GOTO; }
"if"                    { return IF; }
"int"                   { return INT; }
"return"                { return RETURN; }
"void"                  { return VOID; }

{L}({L}|{D})*           { return IDENTIFIER; }

0{D}+{IS}?              { return CONST; }
{D}+{IS}?               { return CONST; }
L?'(\\.|[^\\'])+'       {} /* pas trop compris celle là
# any of (letter, uppercase, one of "_"), optional, literally "'",
capture (any of ((backslash, anything), none of \\'))
, once or more */
{com}             {}

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
"->"                    { return PTR_OP; }
"&&"                    { return AND_OP; }
"||"                    { return OR_OP; }
"=="                    { return EQ_OP; }
"!="                    { return NE_OP; }

"\n"                    { yylineno++; }

[ \t\v\n\f]             { }
.                       { return yytext[0]; }
%%

int yywrap (void) {
    return 1;
}
