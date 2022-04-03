# mini-compiler

### Compiler le tout

~~
```sh
lex ANSI-C.l
yacc structfe.y -d
gcc y.tab.h lex.yy.c -ll
./a.out
````
~~

```
yacc -d structfe.y 
flex ANSI-C.l 
gcc -o myProgram y.tab.c lex.yy.c
./myProgram
```
