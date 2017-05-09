%{

/*
 * Parser.y file
 * To generate the parser run: "bison Parser.y"
 */

/**
TODO
Описать пути к файлам и папкам в виде грамматики,
для регекспов оставить тупо символы и элементарные теги

Либо, сделать мошину состояний лексера, чтобы распознавать теги только тогда, когда надо

*/


#define YYDEBUG 1

#include <Options.h>
#include "InputParser.h"
#include "InputLexer.h"

int yyerror(char ** opt_string, yyscan_t scanner, const char *msg)
{
    fprintf(stderr,"Error:%s\n",msg); return 0;
}

#define EMPTY my_strdup("")

%}

%code requires {

#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void* yyscan_t;
#endif

}

%output  "InputParser.c"
%defines "InputParser.h"

//%define api.prefix yy_opt_
%define api.pure


%lex-param   { yyscan_t scanner }
%parse-param { char **  opt_string }
%parse-param { yyscan_t scanner }

%union {
    char       * dir;
    char       * file;
    char       * string;
}

%token          TOKEN_LPAREN
%token          TOKEN_RPAREN
%token          TOKEN_COMMA

%token <string> TOKEN_DEBUG
%token <string> TOKEN_OBJECT
%token <string> TOKEN_INCLUDE
%token <string> TOKEN_PATHINCLUDE
%token <string> TOKEN_PRINT
%token          TOKEN_QUIET

%token          TOKEN_NUMBER
%token <file>   TOKEN_FILE
%token <dir>    TOKEN_DIR
%token <string> TOKEN_UNUSED

%type <string> opt
%type <string> opt_lst
%%

input
    : opt_lst { *opt_string = opt_asm_get_opt($1); }
    ;

opt_lst
    : opt                                                      { $$ = $1; }
    | opt_lst opt                                              { if ($2){$$ = opt_merge($1, $2);} }
    ;

opt
    : TOKEN_DEBUG                                              { $$ = my_strdup(" -y"); }
    | TOKEN_OBJECT      TOKEN_LPAREN TOKEN_FILE   TOKEN_RPAREN { $$ = EMPTY; asm_obj = $3; }
    | TOKEN_INCLUDE     TOKEN_LPAREN TOKEN_FILE   TOKEN_RPAREN { $$ = EMPTY; printf("\nINCLUDE(file) option is not supported!!!\n"); free($3); }
    | TOKEN_PATHINCLUDE TOKEN_LPAREN TOKEN_DIR    TOKEN_RPAREN { $$ = opt_inc_path($3); }
    | TOKEN_PRINT       TOKEN_LPAREN TOKEN_FILE   TOKEN_RPAREN { $$ = my_strdup(" -lsw"); free($3); }
    | TOKEN_QUIET                                              { $$ = EMPTY; printf("\nTODO: QUIET option is not supported!!!\n"); }
    | t_unused          TOKEN_LPAREN              TOKEN_RPAREN { $$ = EMPTY;/*Do nothing*/ }
    | t_unused          TOKEN_LPAREN TOKEN_NUMBER TOKEN_RPAREN { $$ = EMPTY;/*Do nothing*/ }
    | t_unused                                                 { $$ = EMPTY;/*Do nothing*/ }
    ;

t_unused
    : TOKEN_UNUSED
    | t_unused TOKEN_UNUSED;
    | t_unused TOKEN_NUMBER;
    | t_unused TOKEN_COMMA;
    ;

%%
