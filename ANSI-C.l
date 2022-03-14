D                       [0-9] /* Decimal */ 
L                       [a-zA-Z_] /* Letter + _ */
H                       [a-fA-F0-9] /* Hex */
E                       [Ee][+-]?{D}+ /* Exposant */
FS                      (f|F|l|L) /*  */
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

{L}({L}|{D})*           { return ID ; }

0[xX]{H}+{IS}?          { return NUM; }
0{D}+{IS}?              { return NUM; }
{D}+{IS}?               { return NUM; }
L?'(\\.|[^\\'])+'       { return ; } /* pas trop compris celle là
# any of (letter, uppercase, one of "_"), optional, literally "'",
capture (any of ((backslash, anything), none of \\'))
, once or more */

/\*(.|\n)*?\*/          {} /* exp qui capture les commentaires sur plusieurs lignes */


{D}+{E}{FS}?            { return ; }
{D}*"."{D}+({E})?{FS}?  { return ; }
{D}+"."{D}*({E})?{FS}?  { return ; }

L?\"(\\.|[^\\"])*\"     { return ; }

"..."                   { return ; }
">>="                   { return ; }
"<<="                   { return ; }
"+="                    { return ; }
"-="                    { return ; }
"*="                    { return ; }
"/="                    { return ; }
"%="                    { return ; }
"&="                    { return ; }
"^="                    { return ; }
"|="                    { return ; }
">>"                    { return ; }
"<<"                    { return ; }
"++"                    { return ; }
"--"                    { return ; }
"->"                    { return ; }
"&&"                    { return ; }
"||"                    { return ; }
"<="                    { return ; }
">="                    { return ; }
"=="                    { return ; }
"!="                    { return ; }

[ \t\v\n\f]             { return ; }
.                       { return yytext[0]; }
%%

