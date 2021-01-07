#student: Horovei Andreea-Georgiana, 335CC
build:
	flex program.l
	gcc -o program lex.yy.c
run:
	./program ${TEST_FILE}

