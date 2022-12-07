%option header-file="lex.yy.h"

%{
#include "main.tab.h"
void yyerror(char *);
%}

comment #.*
blank   [ \t\r\n]+
letter  [a-zA-Z]
digit   [0-9]

%%

{comment}       ;
{blank}         ;


{digit}+"."{digit}* |
{digit}*"."{digit}+ { strncpy(yylval.buf, yytext, 50); return DOUBLE; }

{letter}({letter}|{digit})* {strncpy(yylval.buf, yytext, 10); return VARIABLE;}

{digit}+            { strncpy(yylval.buf, yytext, 50); return INTEGER; }

[\-+()=/*;]         { return *yytext; }

{digit}+{letter}+   { char str[50]; sprintf(str, "lexical error %s", yytext); yyerror(str); }
.                   { char str[50]; sprintf(str, "lexical error %s", yytext); yyerror(str); }

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int yywrap(void) {
    return 1;
}

// .               { printf("lexical error %s", yytext); }
// .               { char str[128]; sprintf(str, "lexical error %s", yytext); yyerror(str); }