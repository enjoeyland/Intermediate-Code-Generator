

%{
    #include <stdio.h>
    #include <string.h>
    #include "lex.yy.h"

    #define TYPE_CONV(a,b) ((a.type == T_DOUBLE || b.type == T_DOUBLE) ? T_DOUBLE : T_INT)

    void yyerror(char *);
    void gencode(char*, char*, char*, char*);
    void newtemp(char*);

    struct _SymbolEntry {
        char name[11];
        char type_name[10];
        int type;
        int size;
    } typedef SymbolEntry;
    SymbolEntry symbolTable[100];
    int symbolTableIndex = 0;
    void printSymbolTable(FILE*);
    SymbolEntry* getSymbolEntry(char*);
    int insertSymbol(char*, char*, int);

    enum Type {T_INT, T_DOUBLE};

    struct Buf;
    struct Buf type_conv_left(struct Buf a, struct Buf b);

%}


%union {
    struct Buf {
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

define:
    TYPE varlist
    |
    ;

varlist:
    VARIABLE { insertSymbol($1.text, $<buf>0.text, $<buf>0.type); }
    | varlist ',' VARIABLE  { insertSymbol($3.text, $<buf>0.text, $<buf>0.type); }
    

body:
    statement ';' body
    |
    ;

statement:  
    VARIABLE '=' expression { gencode($1.text, $3.text, "", ""); }
    |
    ;

expression:
    INTEGER
    | DOUBLE
    | VARIABLE  {
                    SymbolEntry* se;
                    if (se = getSymbolEntry($1.text)) {
                        strncpy($$.text, se->name, 50);
                        $$.type = se->type;
                    } else {
                        $$ = $1;
                    }
                }
    | expression '+' expression {
                                    $1 = type_conv_left($1,$3);
                                    $3 = type_conv_left($3,$1);
                                    newtemp($$.text);     
                                    $$.type = TYPE_CONV($1, $3);                       
                                    gencode($$.text, $1.text, "+", $3.text);
                                }
    | expression '-' expression { 
                                    $1 = type_conv_left($1,$3);
                                    $3 = type_conv_left($3,$1);
                                    newtemp($$.text);
                                    $$.type = TYPE_CONV($1, $3);                       
                                    // $$.type = ($1.type == T_DOUBLE || $3.type == T_DOUBLE) ? T_DOUBLE : T_INT;
                                    gencode($$.text, $1.text, "-", $3.text);
                                }
    | expression '*' expression {
                                    $1 = type_conv_left($1,$3);
                                    $3 = type_conv_left($3,$1);
                                    newtemp($$.text);                             
                                    $$.type = TYPE_CONV($1, $3);                       
                                    gencode($$.text, $1.text, "*", $3.text);
                                }
    | expression '/' expression { 
                                    $1 = type_conv_left($1,$3);
                                    $3 = type_conv_left($3,$1);
                                    newtemp($$.text);                           
                                    $$.type = TYPE_CONV($1, $3);                       
                                    gencode($$.text, $1.text, "/", $3.text);
                                }
    | '(' expression ')'    { $$ = $2; }
    ;

%%

void printSymbolTable(FILE* fp) {
    fprintf(fp,"%10s| %8s|\toffset\n", "name", "type");
    fprintf(fp, "---------------------------------------\n");
    int offset = 0;
    for (int i = 0; i < symbolTableIndex; i++) {
        SymbolEntry se = symbolTable[i];
        fprintf(fp, "%10s| %8s|\t%d\n", se.name, se.type_name, offset);
        offset += se.size;
    }
}

SymbolEntry* getSymbolEntry(char* symbol) {
    for (int i = 0; i < symbolTableIndex; i++) {
        if (strcmp(symbol, symbolTable[i].name) == 0) {
            return &symbolTable[i];
        }
    }
    return NULL;
}

int insertSymbol(char* name, char* type_name, int type) {
    int size;
    if (strcmp(type_name, "int") == 0) {
        size = 4;
    } else if (strcmp(type_name, "double") == 0) {
        size = 8;
    }
    strncpy(symbolTable[symbolTableIndex].name, name, 11);
    strncpy(symbolTable[symbolTableIndex].type_name, type_name, 50);
    symbolTable[symbolTableIndex].type =  type;
    symbolTable[symbolTableIndex].size = size;
    symbolTableIndex++;
}

struct Buf type_conv_left(struct Buf a, struct Buf b) {
    if (a.type == T_INT && b.type == T_DOUBLE) {
        char tmp[11];
        newtemp(tmp);
        gencode(tmp, "", "inttoreal", a.text);
        strncpy(a.text, tmp, 11); 
        a.type = T_DOUBLE;
    }
    return a;    
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