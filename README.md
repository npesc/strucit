# mini-compiler

### Compiler le tout

```sh
lex ANSI-C.l
yacc structfe.y -d
gcc y.tab.h lex.yy.c -ll
./a.out
````
