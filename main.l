%option header-file="lex.yy.h"

%{
#include "main.tab.h"
void yyerror(char *);
%}

comment #.*
blank   [ \t\r]+
letter  [a-zA-Z]
digit   [0-9]

%%

{comment}       ;
{blank}         ;

{letter}        { yylval = *yytext -'a'; return VARIABLE; }
{digit}+        { yylval = atoi(yytext); return INTEGER; }
[\-+()=/*\n]    { return *yytext; }
{blank}         ;
.               { char str[128]; sprintf(str, "lexical error %s", yytext); yyerror(str); }

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int yywrap(void) {
    return 1;
}

// .               { printf("lexical error %s", yytext); }
// .               { char str[128]; sprintf(str, "lexical error %s", yytext); yyerror(str); }