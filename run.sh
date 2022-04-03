#!/usr/bin/zsh

yacc -d structfe.y 
flex ANSI-C.l 
gcc -o myProgram y.tab.c lex.yy.c