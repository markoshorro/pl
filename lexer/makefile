SRC = lexer
TEST = in.txt

compile: lexer.l 
	flex $(SRC).l
	gcc -o $(SRC) lex.yy.c -lfl

clean:
	rm -f $(SRC) 

run:
	./$(SRC) < $(TEST)
