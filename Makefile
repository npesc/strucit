ok := all: ok
bok := backend: ok
fok := frontend: ok

all: backend frontend
	@echo ${ok}

backend: backend_parser/y.tab.c backend_parser/lex.yy.c
	@gcc -o backend_parser/backend backend_parser/y.tab.c backend_parser/lex.yy.c
	@echo ${bok}

frontend: lex.yy.c y.tab.c
	@gcc -o frontend y.tab.c lex.yy.c
	@echo ${fok}

backend_parser/y.tab.c: backend_parser/structbe.y
	@yacc -d backend_parser/structbe.y

backend_parser/lex.yy.c: backend_parser/b.l
	@lex backend_parser/b.l

y.tab.c: structfe.y
	@yacc -d structfe.y

lex.yy.c: ANSI-C.l
	@lex ANSI-C.l