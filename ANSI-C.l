%{
    #include "string.h"
    #include "y.tab.h"

    int countn = 0;
%}

%option yylineno

D                       [0-9] 
L                       [a-zA-Z_] 
H                       [a-fA-F0-9] 
E                       [Ee][+-]?{D}+ 
FS                      (f|F|l|L) 
IS                      (u|U|l|L)*

%%

"else"                  { strcpy(yylval.ndObj.name, (yytext)); return ELSE; }
"extern"                { strcpy(yylval.ndObj.name, (yytext)); return EXTERN; }
"for"                   { strcpy(yylval.ndObj.name, (yytext)); return FOR; }
"if"                    { strcpy(yylval.ndObj.name, (yytext)); return IF; }
"int"                   { strcpy(yylval.ndObj.name, (yytext)); return INT; }
"return"                { strcpy(yylval.ndObj.name, (yytext)); return RETURN; }
"sizeof"                { strcpy(yylval.ndObj.name, (yytext)); return SIZEOF; }
"struct"                { strcpy(yylval.ndObj.name, (yytext)); return STRUCT; }
"void"                  { strcpy(yylval.ndObj.name, (yytext)); return VOID; }
"while"                 { strcpy(yylval.ndObj.name, (yytext)); return WHILE; }

{L}({L}|{D})*           { strcpy(yylval.ndObj.name, (yytext)); return IDENTIFIER; }

0[xX]{H}+{IS}?          { strcpy(yylval.ndObj.name, (yytext)); return CONSTANT; }
0{D}+{IS}?              { strcpy(yylval.ndObj.name, (yytext)); return CONSTANT; }
{D}+{IS}?               { strcpy(yylval.ndObj.name, (yytext)); return CONSTANT; }
L?'(\\.|[^\\'])+'       {} /* pas trop compris celle là
# any of (letter, uppercase, one of "_"), optional, literally "'",
capture (any of ((backslash, anything), none of \\'))
, once or more */

{D}+{E}{FS}?            { strcpy(yylval.ndObj.name,(yytext)); return CONSTANT; }
{D}*"."{D}+({E})?{FS}?  {}
{D}+"."{D}*({E})?{FS}?  {}

L?\"(\\.|[^\\"])*\"     {}

"..."                   {}
">>"                    { strcpy(yylval.ndObj.name, (yytext)); return RSHIFT; }
"<<"                    { strcpy(yylval.ndObj.name, (yytext)); return LSHIFT; }
"<"                     { strcpy(yylval.ndObj.name, (yytext)); return LT_OP; }
"<="                    { strcpy(yylval.ndObj.name, (yytext)); return LE_OP; }
">"                     { strcpy(yylval.ndObj.name, (yytext)); return GT_OP; }
">="                    { strcpy(yylval.ndObj.name, (yytext)); return GE_OP; }
"->"                    { strcpy(yylval.ndObj.name, (yytext)); return PTR_OP; }
"&&"                    { strcpy(yylval.ndObj.name, (yytext)); return AND_OP; }
"||"                    { strcpy(yylval.ndObj.name, (yytext)); return OR_OP; }
"=="                    { strcpy(yylval.ndObj.name, (yytext)); return EQ_OP; }
"!="                    { strcpy(yylval.ndObj.name, (yytext)); return NE_OP; }

"\n"                    { yylineno++; }

[ \t\v\n\f]             { countn++; }
.                       { return yytext[0]; }

%%

int yywrap (void) {
    return 1;
}
