%option header-file="lex.yy.h"

%{
    #include "main.tab.h"
    void yyerror(char *);

    enum Type {T_INT, T_DOUBLE};
%}

comment #.*
blank   [ \t\r\n]+
letter  [a-zA-Z]
digit   [0-9]

%%

{comment}       ;
{blank}         ;

"int"       { yylval.buf.type = T_INT; strncpy(yylval.buf.text, yytext, 50); return TYPE;}
"double"    { yylval.buf.type = T_DOUBLE; strncpy(yylval.buf.text, yytext, 50); return TYPE;}

{digit}+"."{digit}* |
{digit}*"."{digit}+ { yylval.buf.type = T_INT; strncpy(yylval.buf.text, yytext, 50); return DOUBLE; }

{letter}({letter}|{digit})* {
                                int id_len = yyleng > 10 ? 10 : yyleng;
                                char limited_symbol[11];
                                strncpy(limited_symbol, yytext, id_len);
                                limited_symbol[id_len] = '\0';
                                strncpy(yylval.buf.text, limited_symbol, 11);

                                return VARIABLE;
                            }

{digit}+            { yylval.buf.type = T_INT; strncpy(yylval.buf.text, yytext, 50); return INTEGER; }

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
