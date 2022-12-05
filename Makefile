TARGET = parser_202020790.out

all: $(TARGET)
$(TARGET): lex.yy.c main.tab.c
	gcc -lfl -o $@ main.tab.c lex.yy.c -I. 
lex.yy.c: main.l
	flex main.l
main.tab.c: main.y
	bison -d main.y
.PHONY : clean
clean:
	rm -rf *.out *.yy.c *.yy.h *.tab.c *.tab.h