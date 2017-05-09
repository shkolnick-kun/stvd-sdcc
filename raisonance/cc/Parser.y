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

#define EMPTY my_strdup("")

int yyerror(char ** opt_string, yyscan_t scanner, const char *msg)
{
    fprintf(stderr,"Error:%s\n",msg); return 0;
}

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
    int num;
    char       * dir;
    char       * file;
    char       * string;
}

%token          TOKEN_SET
%token          TOKEN_LPAREN
%token          TOKEN_RPAREN
%token          TOKEN_COMMA

%token <string> TOKEN_DEBUG
%token <string> TOKEN_AUTO
%token <string> TOKEN_SC
%token          TOKEN_WL
%token <string> TOKEN_OBJECT
%token <string> TOKEN_INCLUDE
%token <string> TOKEN_PREPRINT
%token <string> TOKEN_PRINT
%token <string> TOKEN_PATHINCLUDE
%token <string> TOKEN_OPTIMIZE
%token          TOKEN_SIZE
%token          TOKEN_SPEED
%token <string> TOKEN_DEFINE
%token <num>    TOKEN_NUMBER
%token <file>   TOKEN_FILE
%token <dir>    TOKEN_DIR
%token <string> TOKEN_DFSTR
%token <string> TOKEN_UNUSED

%type <string> opt
%type <string> opt_lst
%type <string> t_opt_lev
%type <string> t_df_list
%type <string> t_define
%type <string> t_unused

%%

input
    : opt_lst { *opt_string = opt_cc_get_opt($1); }
    ;

opt_lst
    : opt                                                      { $$ = $1; }
    | opt_lst opt                                              { if ($2){$$ = opt_merge($1, $2);} }
    ;

opt
    : TOKEN_DEBUG                                              { $$ = my_strdup(" --out-fmt-elf --debug"); debug_opt = true; }
    | TOKEN_AUTO                                               { $$ = my_strdup(" --stack-auto"); }
    | TOKEN_SC                                                 { $$ = my_strdup(" --fsigned-char"); }
    | TOKEN_WL          TOKEN_LPAREN TOKEN_NUMBER TOKEN_RPAREN { $$ = EMPTY;/**TODO: НАПИСАТЬ ПОВЕДЕНИЕ!!! */ }
    | TOKEN_OBJECT      TOKEN_LPAREN TOKEN_FILE   TOKEN_RPAREN { $$ = opt_obj($3); }
    | TOKEN_INCLUDE     TOKEN_LPAREN TOKEN_FILE   TOKEN_RPAREN { $$ = EMPTY; printf("\nINCLUDE(file) option is not supported!!!\n"); free($3); }
    | TOKEN_PREPRINT    TOKEN_LPAREN TOKEN_FILE   TOKEN_RPAREN { $$ = EMPTY;/*Do nothing, SDCC does it by default.*/ }
    | TOKEN_PRINT       TOKEN_LPAREN TOKEN_FILE   TOKEN_RPAREN { $$ = EMPTY;/*Do nothing, SDCC does it by default.*/ }
    | TOKEN_PATHINCLUDE TOKEN_LPAREN TOKEN_DIR    TOKEN_RPAREN { $$ = opt_inc_path($3); }
    | TOKEN_OPTIMIZE    TOKEN_LPAREN t_opt_lev    TOKEN_RPAREN { $$ = $3; }
    | TOKEN_DEFINE      TOKEN_LPAREN t_df_list    TOKEN_RPAREN { $$ = $3; }
    | t_unused                                                 { $$ = EMPTY;/*Do nothing*/ }
    ;

t_unused
    : TOKEN_UNUSED
    | t_unused TOKEN_UNUSED;
    | t_unused TOKEN_NUMBER;
    | t_unused TOKEN_COMMA;
    | t_unused TOKEN_SET ;
    | t_unused TOKEN_LPAREN              TOKEN_RPAREN
    | t_unused TOKEN_LPAREN TOKEN_NUMBER TOKEN_RPAREN
    ;

t_opt_lev
    : TOKEN_NUMBER                         { $$ = opt_opt_lev(false, $1); }
    | TOKEN_NUMBER TOKEN_COMMA TOKEN_SIZE  { $$ = opt_opt_lev(true, $1); }
    | TOKEN_NUMBER TOKEN_COMMA TOKEN_SPEED { $$ = opt_opt_lev(false, $1); }
    ;

t_df_list
    : t_define                             { $$ = $1; }
    | t_df_list TOKEN_COMMA t_define       { $$ = opt_merge($1, $3); }
    ;

t_define
    : TOKEN_DFSTR                          { $$ = opt_df_df($1); }
    | TOKEN_DFSTR TOKEN_SET TOKEN_DFSTR    { $$ = opt_df_str($1, $3); }
    | TOKEN_DFSTR TOKEN_SET TOKEN_NUMBER   { $$ = opt_df_num($1, $3); }
    ;

%%
