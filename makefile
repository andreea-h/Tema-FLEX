build:
	flex program.l
	gcc -o program lex.yy.c
run:
	./program testInput1.txt
