# flex genera un lex.yy.c
# bison genera fichero.tab.c y .tab.h
# gcc -ly (library yacc) y -lfl (library flex) y genera fichero.out

NAME=parser
INFILE=in.txt
FLAGS=-lfl -ly -w 
compile: $(NAME).l
	flex $(NAME).l
	bison -o $(NAME).tab.c $(NAME).y -yd
	gcc -o $(NAME).out lex.yy.c $(NAME).tab.c $(FLAGS)

run:
	./$(NAME).out < $(INFILE)

clean:
	rm *.yy.c *.tab.c *.out *.tab.h
