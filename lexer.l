%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

static char *copy_text(const char *text) {
    size_t length = strlen(text) + 1;
    char *copy = (char *)malloc(length);
    if (copy == NULL) {
        fprintf(stderr, "Fatal error: out of memory.\n");
        exit(EXIT_FAILURE);
    }
    memcpy(copy, text, length);
    return copy;
}
%}

%option noyywrap
%option yylineno

DIGIT       [0-9]
LETTER      [a-zA-Z_]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*
NUMBER      {DIGIT}+(\.{DIGIT}+)?

%%

"int"       { printf("TOKEN: KEYWORD(int)\n"); return INT; }
"float"     { printf("TOKEN: KEYWORD(float)\n"); return FLOAT; }

{IDENTIFIER} {
                printf("TOKEN: IDENTIFIER(%s)\n", yytext);
                yylval.str = copy_text(yytext);
                return ID;
             }

{NUMBER}    {
                printf("TOKEN: NUMBER(%s)\n", yytext);
                yylval.number = atof(yytext);
                return NUMBER;
            }

"="         { printf("TOKEN: ASSIGNMENT(=)\n"); return '='; }
";"         { printf("TOKEN: SEMICOLON(;)\n"); return ';'; }
"+"         { printf("TOKEN: OPERATOR(+)\n"); return '+'; }
"-"         { printf("TOKEN: OPERATOR(-)\n"); return '-'; }
"*"         { printf("TOKEN: OPERATOR(*)\n"); return '*'; }
"/"         { printf("TOKEN: OPERATOR(/)\n"); return '/'; }
"("         { printf("TOKEN: LEFT_PARENTHESIS(()\n"); return '('; }
")"         { printf("TOKEN: RIGHT_PARENTHESIS())\n"); return ')'; }

[ \t\r\n]+  { /* Ignore whitespace. */ }

"//".*      { /* Ignore single-line comments. */ }

.           {
                printf("LEXICAL ERROR at line %d: Unknown character '%s'\n",
                       yylineno, yytext);
                return yytext[0];
            }

%%
