

%{
    #include <stdio.h>
    #include <string.h>
    #include "lex.yy.h"
    void yyerror(char *);
    void gencode(char*, char*, char*, char*);
    void newtemp(char* s);

    struct _SymbolEntry {
        char name[11];
        char type[4];
        int size;
    } typedef SymbolEntry;
    SymbolEntry symbolTable[100];
    int symbolTableIndex = 0;
    void printSymbolTable(FILE*);
%}


%union {
    struct {
        char text[50];
        int type;
    } buf;
}

%token  <buf>  INTEGER
%token  <buf>  DOUBLE
%token  <buf>  VARIABLE
%token  <buf>  TYPE
%type   <buf>  expression

%left   '+' '-'
%left   '*' '/'

%%

program:
    define ';' program
    | body  {
                printSymbolTable(stdout);
                FILE* fp = fopen("sbt.out", "w");
                printSymbolTable(fp);
                fclose(fp);
            }     
    |   
    ;

body:
    statement ';' body
    |
    ;
define:
    TYPE VARIABLE   {
                        int size;
                        if (strcmp($1.text, "int") == 0) {
                            size = 4;
                        } else if (strcmp($1.text, "double") == 0) {
                            size = 8;
                        }
                        
                        strncpy(symbolTable[symbolTableIndex].name, $2.text, 11);
                        strncpy(symbolTable[symbolTableIndex].type, $1.text, 50);
                        symbolTable[symbolTableIndex].size = size;
                        symbolTableIndex++;
                    }
    |
    ;


statement:  
    VARIABLE '=' expression { gencode($1.text, $3.text, "", ""); }
    |
    ;

expression:
    INTEGER
    | DOUBLE
    | VARIABLE
    | expression '+' expression {
                                    char tmp[11];
                                    newtemp(tmp);
                                    strncpy($$.text, tmp, 11);                              
                                    gencode(tmp, $1.text, "+", $3.text);
                                }
    | expression '-' expression { 
                                    char tmp[11];
                                    newtemp(tmp); 
                                    strncpy($$.text, tmp, 11);                              
                                    gencode(tmp, $1.text, "-", $3.text);
                                }
    | expression '*' expression { 
                                    char tmp[11];
                                    newtemp(tmp); 
                                    strncpy($$.text, tmp, 11);                              
                                    gencode(tmp, $1.text, "*", $3.text);
                                }
    | expression '/' expression { 
                                    char tmp[11];
                                    newtemp(tmp); 
                                    strncpy($$.text, tmp, 11);                              
                                    gencode(tmp, $1.text, "/", $3.text);
                                }
    | '(' expression ')'    { strncpy($$.text, $2.text, 50); }
    ;

%%

void printSymbolTable(FILE* fp) {
    fprintf(fp,"%10s| %8s|\toffset\n", "name", "type");
    fprintf(fp, "---------------------------------------\n");
    int offset = 0;
    for (int i = 0; i < symbolTableIndex; i++) {
        SymbolEntry se = symbolTable[i];
        fprintf(fp, "%10s| %8s|\t%d\n", se.name, se.type, offset);
        offset += se.size;
    }
}

void gencode(char* var, char* operand1, char* operator, char* operand2) {
    printf("%s = %s %s %s\n", var, operand1, operator, operand2);   
}

int k = 1;
void newtemp(char* s) {
    sprintf(s, "t%d", k++);
}

void main() {
    yyparse();
}