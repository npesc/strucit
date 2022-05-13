%{
#include <stdio.h>
#include "y.tab.h"
void yyerror(char*);
int lineno = 0;
%}

D                       [0-9] 
L                       [a-zA-Z_] 
IS                      (u|U|l|L)*
com                     \/\*.*\*\/

%x ML_COMMENT


%%
"const"                 { return CONST; }
"extern"                { printf("%s\n",yytext); return EXTERN; }
"goto"                  { return GOTO; }
"if"                    { return IF; }
"int"                   { return INT; }
"return"                { return RETURN; }
"void"                  { return VOID; }


(\*)*{L}({L}|{D})*           {strcpy(yylval.name,yytext); return IDENTIFIER; }

0{D}+{IS}?              { return CONST; }
{D}+{IS}?               { return CONST; }
L?'(\\.|[^\\'])+'       {} /* pas trop compris celle là
# any of (letter, uppercase, one of "_"), optional, literally "'",
capture (any of ((backslash, anything), none of \\'))
, once or more */
{com}                   {}
"/*"                    { printf("comment from line %d ", yylineno); BEGIN(ML_COMMENT); }
<ML_COMMENT>"*/"        { printf("to line %d\n", (yylineno+lineno)); BEGIN(INITIAL); }
<ML_COMMENT>[^*\n]+		
<ML_COMMENT>"*"			
<ML_COMMENT>"\n"        { lineno += 1;}

"<"                     { return LT_OP; }
"<="                    { return LE_OP; }
">"                     { return GT_OP; }
">="                    { return GE_OP; }
"=="                    { return EQ_OP; }
"!="                    { return NE_OP; }
"*"                     { printf("%s",yytext);return STAR;}
"+"                     { return PLUS;}
"-"                     { return MINUS;}
"/"                     { return SLASH;}

"\n"                    { yylineno++; }

[ \t\v\n\f]             { }
.                       { return yytext[0];}
%%

int yywrap (void) {
    return 1;
}
