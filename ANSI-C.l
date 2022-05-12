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
com                     \/\*.*\*\/


%%

"auto"                  { strcpy(yylval.nd_obj.name,(yytext)); return AUTO; }
"break"                 { strcpy(yylval.nd_obj.name,(yytext)); return BREAK; }
"case"                  { strcpy(yylval.nd_obj.name,(yytext)); return CASE; }
"char"                  { strcpy(yylval.nd_obj.name,(yytext)); return CHAR; }
"const"                 { strcpy(yylval.nd_obj.name,(yytext)); return CONST; }
"continue"              { strcpy(yylval.nd_obj.name,(yytext)); return CONTINUE; }
"default"               { strcpy(yylval.nd_obj.name,(yytext)); return DEFAULT; }
"do"                    { strcpy(yylval.nd_obj.name,(yytext)); return DO; }
"double"                { strcpy(yylval.nd_obj.name,(yytext)); return DOUBLE; }
"else"                  { strcpy(yylval.nd_obj.name,(yytext)); return ELSE; }
"enum"                  { strcpy(yylval.nd_obj.name,(yytext)); return ENUM; }
"extern"                { strcpy(yylval.nd_obj.name,(yytext)); return EXTERN; }
"float"                 { strcpy(yylval.nd_obj.name,(yytext)); return FLOAT; }
"for"                   { strcpy(yylval.nd_obj.name,(yytext)); return FOR; }
"goto"                  { strcpy(yylval.nd_obj.name,(yytext)); return GOTO; }
"if"                    { strcpy(yylval.nd_obj.name,(yytext)); return IF; }
"int"                   { strcpy(yylval.nd_obj.name,(yytext)); return INT; }
"long"                  { strcpy(yylval.nd_obj.name,(yytext)); return LONG; }
"register"              { strcpy(yylval.nd_obj.name,(yytext)); return REGISTER; }
"return"                { strcpy(yylval.nd_obj.name,(yytext)); return RETURN; }
"short"                 { strcpy(yylval.nd_obj.name,(yytext)); return SHORT; }
"signed"                { strcpy(yylval.nd_obj.name,(yytext)); return SIGNED; }
"sizeof"                { strcpy(yylval.nd_obj.name,(yytext)); return SIZEOF; }
"static"                { strcpy(yylval.nd_obj.name,(yytext)); return STATIC; }
"struct"                { strcpy(yylval.nd_obj.name,(yytext)); return STRUCT; }
"switch"                { strcpy(yylval.nd_obj.name,(yytext)); return SWITCH; }
"typedef"               { strcpy(yylval.nd_obj.name,(yytext)); return TYPEDEF; }
"union"                 { strcpy(yylval.nd_obj.name,(yytext)); return UNION; }
"unsigned"              { strcpy(yylval.nd_obj.name,(yytext)); return UNSIGNED; }
"void"                  { strcpy(yylval.nd_obj.name,(yytext)); return VOID; }
"volatile"              { strcpy(yylval.nd_obj.name,(yytext)); return VOLATILE; }
"while"                 { strcpy(yylval.nd_obj.name,(yytext)); return WHILE; }

{L}({L}|{D})*           { strcpy(yylval.nd_obj.name,(yytext)); return IDENTIFIER; }

0[xX]{H}+{IS}?          { strcpy(yylval.nd_obj.name,(yytext)); return CONSTANT; }
0{D}+{IS}?              { strcpy(yylval.nd_obj.name,(yytext)); return CONSTANT; }
{D}+{IS}?               { strcpy(yylval.nd_obj.name,(yytext)); return CONSTANT; }
L?'(\\.|[^\\'])+'       {} /* pas trop compris celle là
# any of (letter, uppercase, one of "_"), optional, literally "'",
capture (any of ((backslash, anything), none of \\'))
, once or more */

{D}+{E}{FS}?            { strcpy(yylval.nd_obj.name,(yytext)); return CONSTANT; }
{D}*"."{D}+({E})?{FS}?  {}
{D}+"."{D}*({E})?{FS}?  {}
{com}             {}

"..."                   {}
">>="                   { strcpy(yylval.nd_obj.name,(yytext)); return RSHIFT_ASSIGN; }
"<<="                   { strcpy(yylval.nd_obj.name,(yytext)); return LSHIFT_ASSIGN; }
"+="                    { strcpy(yylval.nd_obj.name,(yytext)); return ADD_ASSIGN; }
"-="                    { strcpy(yylval.nd_obj.name,(yytext)); return SUB_ASSIGN; }
"*="                    { strcpy(yylval.nd_obj.name,(yytext)); return MUL_ASSIGN; }
"/="                    { strcpy(yylval.nd_obj.name,(yytext)); return DIV_ASSIGN; }
"%="                    { strcpy(yylval.nd_obj.name,(yytext)); return MOD_ASSIGN; }
"&="                    { strcpy(yylval.nd_obj.name,(yytext)); return BIT_AND_ASSIGN; }
"^="                    { strcpy(yylval.nd_obj.name,(yytext)); return BIT_XOR_ASSIGN; }
"|="                    { strcpy(yylval.nd_obj.name,(yytext)); return BIT_OR_ASSIGN; }
">>"                    { strcpy(yylval.nd_obj.name,(yytext)); return RSHIFT; }
"<<"                    { strcpy(yylval.nd_obj.name,(yytext)); return LSHIFT; }
"<"                     { strcpy(yylval.nd_obj.name,(yytext)); return LT_OP; }
"<="                    { strcpy(yylval.nd_obj.name,(yytext)); return LE_OP; }
">"                     { strcpy(yylval.nd_obj.name,(yytext)); return GT_OP; }
">="                    { strcpy(yylval.nd_obj.name,(yytext)); return GE_OP; }
"++"                    { strcpy(yylval.nd_obj.name,(yytext)); return INC; }
"--"                    { strcpy(yylval.nd_obj.name,(yytext)); return DEC; }
"->"                    { strcpy(yylval.nd_obj.name,(yytext)); return PTR_OP; }
"&&"                    { strcpy(yylval.nd_obj.name,(yytext)); return AND_OP; }
"||"                    { strcpy(yylval.nd_obj.name,(yytext)); return OR_OP; }
"=="                    { strcpy(yylval.nd_obj.name,(yytext)); return EQ_OP; }
"!="                    { strcpy(yylval.nd_obj.name,(yytext)); return NE_OP; }

"\n"                    { yylineno++; }

[ \t\v\n\f]             { countn++; }
.                       { return yytext[0]; }

%%

int yywrap (void) {
    return 1;
}
