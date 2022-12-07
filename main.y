

%{
    #include <stdio.h>
    #include <string.h>
    #include "lex.yy.h"
    int symbol_table[26];
    void yyerror(char *);
    void gencode(char*, char*, char*, char*);
    void newtemp(char* s);
%}


%union {
    char buf[50];
    int val;
}

%token  <buf>  INTEGER
%token  <buf>  DOUBLE
%token  <buf>  VARIABLE
%type   <buf>  expression

%left   '+' '-'
%left   '*' '/'

%%

program:
    program statement ';'
    |
    ;

statement:  
    expression  { printf("%s\n", $1); }
    | VARIABLE '=' expression   { gencode($1, $3, "", ""); }
    ;

expression:
    INTEGER
    | DOUBLE
    | VARIABLE
    | expression '+' expression { 
                                    char tmp[10];
                                    newtemp(tmp); 
                                    strncpy($$, tmp, 10);                              
                                    gencode(tmp, $1, "+", $3);
                                }
    | expression '-' expression { 
                                    char tmp[10];
                                    newtemp(tmp); 
                                    strncpy($$, tmp, 10);                              
                                    gencode(tmp, $1, "-", $3);
                                }
    | expression '*' expression { 
                                    char tmp[10];
                                    newtemp(tmp); 
                                    strncpy($$, tmp, 10);                              
                                    gencode(tmp, $1, "*", $3);
                                }
    | expression '/' expression { 
                                    char tmp[10];
                                    newtemp(tmp); 
                                    strncpy($$, tmp, 10);                              
                                    gencode(tmp, $1, "/", $3);
                                }
    | '(' expression ')' { strncpy($$, $2, 10); }
    ;

%%

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