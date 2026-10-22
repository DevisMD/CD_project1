%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *message);

#define MAX_SYMBOLS 200

typedef struct {
    char name[100];
    char type[10];
    double value;
    int initialized;
} Symbol;

static Symbol symbol_table[MAX_SYMBOLS];
static int symbol_count = 0;
static int syntax_errors = 0;
static int semantic_errors = 0;

static int find_symbol(const char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

static void declare_variable(const char *type, const char *name,
                             int initialized, double value) {
    if (find_symbol(name) >= 0) {
        printf("SEMANTIC ERROR: Variable '%s' is already declared.\n", name);
        semantic_errors++;
        return;
    }

    if (symbol_count >= MAX_SYMBOLS) {
        printf("SEMANTIC ERROR: Symbol table is full; cannot declare '%s'.\n", name);
        semantic_errors++;
        return;
    }

    snprintf(symbol_table[symbol_count].name,
             sizeof(symbol_table[symbol_count].name), "%s", name);
    snprintf(symbol_table[symbol_count].type,
             sizeof(symbol_table[symbol_count].type), "%s", type);
    symbol_table[symbol_count].value = value;
    symbol_table[symbol_count].initialized = initialized;
    symbol_count++;

    if (initialized) {
        printf("DECLARATION: '%s' declared as %s and initialized to %g.\n",
               name, type, value);
    } else {
        printf("DECLARATION: '%s' declared as %s.\n", name, type);
    }
}

static void assign_variable(const char *name, double value) {
    int index = find_symbol(name);
    if (index < 0) {
        printf("SEMANTIC ERROR: Variable '%s' used before declaration.\n", name);
        semantic_errors++;
        return;
    }

    symbol_table[index].value = value;
    symbol_table[index].initialized = 1;
    printf("ASSIGNMENT: '%s' = %g\n", name, value);
}

static void print_symbol_table(void) {
    printf("\n--- SYMBOL TABLE ---\n");
    printf("%-15s %-10s %-12s %-12s\n", "Variable", "Type", "Value", "Initialized");
    printf("--------------------------------------------------\n");
    for (int i = 0; i < symbol_count; i++) {
        printf("%-15s %-10s %-12g %-12s\n",
               symbol_table[i].name,
               symbol_table[i].type,
               symbol_table[i].value,
               symbol_table[i].initialized ? "Yes" : "No");
    }
    if (symbol_count == 0) {
        printf("(empty)\n");
    }
    printf("--------------------\n");
}
%}

%union {
    char *str;
    double number;
}

%token INT FLOAT
%token <str> ID
%token <number> NUMBER
%type <str> data_type
%type <number> expression

%left '+' '-'
%left '*' '/'
%right UMINUS

%start program

%%

program
    : statements
    ;

statements
    : /* empty */
    | statements statement
    ;

statement
    : declaration
    | assignment
    | error ';'  { syntax_errors++; printf("SYNTAX ERROR: Skipping invalid statement.\n"); yyerrok; }
    ;

data_type
    : INT   { $$ = "int"; }
    | FLOAT { $$ = "float"; }
    ;

declaration
    : data_type ID ';'
      {
          declare_variable($1, $2, 0, 0);
          free($2);
      }
    | data_type ID '=' expression ';'
      {
          declare_variable($1, $2, 1, $4);
          free($2);
      }
    ;

assignment
    : ID '=' expression ';'
      {
          assign_variable($1, $3);
          free($1);
      }
    ;

expression
    : NUMBER                 { $$ = $1; }
    | ID
      {
          int index = find_symbol($1);
          if (index < 0) {
              printf("SEMANTIC ERROR: Variable '%s' used before declaration.\n", $1);
              semantic_errors++;
              $$ = 0;
          } else if (!symbol_table[index].initialized) {
              printf("SEMANTIC WARNING: Variable '%s' is used before initialization; using 0.\n", $1);
              $$ = 0;
          } else {
              $$ = symbol_table[index].value;
          }
          free($1);
      }
    | expression '+' expression { $$ = $1 + $3; }
    | expression '-' expression { $$ = $1 - $3; }
    | expression '*' expression { $$ = $1 * $3; }
    | expression '/' expression
      {
          if ($3 == 0) {
              printf("SEMANTIC ERROR: Division by zero.\n");
              semantic_errors++;
              $$ = 0;
          } else {
              $$ = $1 / $3;
          }
      }
    | '-' expression %prec UMINUS { $$ = -$2; }
    | '(' expression ')'        { $$ = $2; }
    ;

%%

void yyerror(const char *message) {
    printf("SYNTAX ERROR: %s\n", message);
    syntax_errors++;
}

int main(void) {
    printf("====================================\n");
    printf("     VARIABLE DECLARATION COMPILER\n");
    printf("====================================\n");
    printf("Supported types: int, float\n");
    printf("Enter statements, or redirect a file into the program.\n\n");

    int parse_result = yyparse();

    print_symbol_table();

    printf("\n--- COMPILATION SUMMARY ---\n");
    if (parse_result == 0 && syntax_errors == 0 && semantic_errors == 0) {
        printf("Compilation completed successfully.\n");
    } else {
        printf("Compilation completed with errors.\n");
    }
    printf("Syntax errors: %d\n", syntax_errors);
    printf("Semantic errors: %d\n", semantic_errors);

    return (parse_result == 0 && syntax_errors == 0 && semantic_errors == 0) ? 0 : 1;
}
