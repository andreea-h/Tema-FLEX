#!/bin/bash

flex program.l
gcc -o program lex.yy.c
./program testInput1.txt
