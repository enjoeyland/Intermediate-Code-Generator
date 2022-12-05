%token  INTEGER VARIABLE
%left   '+' '-'
%left   '*' '/'

%{
    #include <stdio.h>
    #include "lex.yy.h"
    int symbol_table[26];
    void yyerror(char *);

%}

%%

program: 
    program statement '\n'
    |
    ;

statement:  
    expression  { printf("%d\n", $1); }
    | VARIABLE '=' expression { symbol_table[$1] = $3; }
    ;

expression:
    INTEGER
    | VARIABLE    { $$ = symbol_table[$1]; }
    | expression '+' expression { $$ = $1 + $3; }
    | expression '-' expression { $$ = $1 - $3; }
    | expression '*' expression { $$ = $1 * $3; }
    | expression '/' expression { $$ = $1 / $3; }
    | '(' expression ')' { $$ = $2; }
    ;

%%


void main() {
    yyparse();
}