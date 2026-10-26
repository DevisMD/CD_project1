# Variable Declaration Compiler — GitHub Pages Demo

An educational Compiler Design project demonstrating lexical analysis, syntax analysis,
semantic checks, arithmetic expressions, and a symbol table..

## Try the Website

This repository includes a browser-based interactive demo in `index.html`.
To publish it with GitHub Pages:

1. Create a GitHub repository (for example, `variable-declaration-compiler`).
2. Upload **all files in this folder** to the repository's root (not inside another nested folder).
3. Open **Settings → Pages**.
4. Under **Build and deployment**, choose **Deploy from a branch**.
5. Select branch `main` and folder `/(root)`, then click **Save**.
6. Wait for deployment. GitHub will show the published website URL in Settings → Pages.

The website is static HTML/CSS/JavaScript and runs in the visitor's browser. It does not
need a database or server. The browser demo models the compiler stages in JavaScript; it
does **not** execute `variable_compiler.exe` or compile the `.l`/`.y` files on GitHub Pages.

## Native Lex/Yacc version (Windows with MSYS2 UCRT64)

Install MSYS2 from https://www.msys2.org/, open **MSYS2 UCRT64**, and install the tools:

```bash
pacman -Syu
pacman -S --needed mingw-w64-ucrt-x86_64-gcc flex bison
```

From the project folder, regenerate the parser/scanner and build the executable:

```bash
bison -d parser.y
flex lexer.l
gcc -Wall -Wextra parser.tab.c lex.yy.c -o variable_compiler.exe
```

Run examples:

```bash
./variable_compiler.exe < input_valid.txt
./variable_compiler.exe < input_duplicate.txt
./variable_compiler.exe < input_invalid.txt
```

## Features

- `int` and `float` declarations, with or without initialization
- Assignment statements and arithmetic expressions (`+`, `-`, `*`, `/`, parentheses, unary minus)
- Token display in the browser demo
- Duplicate declaration and undeclared-variable checks
- Division-by-zero checks
- Symbol table and compilation summary

## Project files

- `index.html` — GitHub Pages website entry point
- `lexer.l` — Flex lexical rules
- `parser.y` — Bison/Yacc grammar, symbol table, and semantic actions
- `lex.yy.c`, `parser.tab.c`, `parser.tab.h` — generated C files (regenerate from `.l` and `.y` when needed)
- `input_valid.txt` — valid example program
- `input_duplicate.txt` — duplicate-declaration example
- `input_invalid.txt` — invalid example program

## Limitations

This is an educational compiler front end, not a complete C compiler. The native version uses a
global symbol table limited to 200 variables and does not implement scopes, functions, arrays,
or code generation. The browser demo is a JavaScript simulation of the front-end behavior.




