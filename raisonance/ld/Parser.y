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
    unsigned int num;
    char       * dir;
    char       * file;
    char       * string;
}

%token          TOKEN_SET
%token          TOKEN_LPAREN
%token          TOKEN_RPAREN
%token          TOKEN_COMMA
%token          TOKEN_QUOTE

%token <string> TOKEN_CSZ
%token <string> TOKEN_CSTR
%token <string> TOKEN_DSTR
%token <string> TOKEN_DEBUG

%token <string> TOKEN_EESZ
%token <string> TOKEN_EESTR

%token <string> TOKEN_LIB
%token <string> TOKEN_MAP
%token <string> TOKEN_OUT
%token          TOKEN_NOSTDLIB
%token <string> TOKEN_PRINT

%token <string> TOKEN_RAMSZ
%token <string> TOKEN_STACKTOP

%token          TOKEN_ZERO
%token          TOKEN_HEX_STR
%token          TOKEN_HEX_END
%token <num>    TOKEN_DDIGIT
%token <string> TOKEN_DNUMBER
%token <string> TOKEN_HNUMBER

%token <file>   TOKEN_FILE
%token <dir>    TOKEN_DIR
%token <string> TOKEN_DFSTR
%token <string> TOKEN_UNUSED

%type <string> opt
%type <string> opt_lst
%type <string> opt_fl_lst
%type <string> opt_dir_lst

%type <num>    t_num
%%

input
    : opt_lst { *opt_string = opt_lnk_get_cmd($1); }
    ;

opt_lst
    : opt                                                      { $$ = $1; }
    | opt_lst opt                                              { $$ = opt_merge($1, $2); }
    ;

opt
    : TOKEN_QUOTE       opt_fl_lst                TOKEN_QUOTE  { $$ = EMPTY; lnk_obj_list = $2; }
    | TOKEN_DEBUG                                              { $$ = opt_lnk_dbg(); }
    | TOKEN_CSZ         TOKEN_LPAREN t_num        TOKEN_RPAREN { $$ = opt_lnk_csz($3); }
    | TOKEN_CSTR        TOKEN_LPAREN t_num        TOKEN_RPAREN { $$ = opt_lnk_cstr($3); }
    | TOKEN_DSTR        TOKEN_LPAREN t_num        TOKEN_RPAREN { $$ = opt_lnk_dstr($3); }
    | TOKEN_EESTR       TOKEN_LPAREN t_num        TOKEN_RPAREN { $$ = EMPTY; /*TODO*/ }
    | TOKEN_EESZ        TOKEN_LPAREN t_num        TOKEN_RPAREN { $$ = EMPTY; /*TODO*/ }
    | TOKEN_LIB         TOKEN_LPAREN opt_dir_lst  TOKEN_RPAREN { $$ = $3; }
    | TOKEN_MAP                                                { $$ = EMPTY; /*TODO*/ }
    | TOKEN_OUT         TOKEN_LPAREN TOKEN_FILE TOKEN_RPAREN   { $$ = EMPTY; lnk_out_basename = $3; }
    | TOKEN_NOSTDLIB                                           { $$ = my_strdup(" --nostdlib"); }
    | TOKEN_RAMSZ       TOKEN_LPAREN t_num        TOKEN_RPAREN { $$ = opt_lnk_dsz($3); }
    | TOKEN_STACKTOP    TOKEN_LPAREN t_num        TOKEN_RPAREN { $$ = opt_lnk_stack($3); }
    | TOKEN_PRINT       TOKEN_LPAREN TOKEN_FILE   TOKEN_RPAREN { $$ = EMPTY;/*TODO*/ }
    | t_unused          TOKEN_LPAREN              TOKEN_RPAREN { $$ = EMPTY;/*Do nothing*/ }
    | t_unused          TOKEN_LPAREN t_unused     TOKEN_RPAREN { $$ = EMPTY;/*Do nothing*/ }
    | t_unused          TOKEN_LPAREN t_num        TOKEN_RPAREN { $$ = EMPTY;/*Do nothing*/ }
    | t_unused                                                 { $$ = EMPTY;/*Do nothing*/ }
    ;

opt_fl_lst
    : TOKEN_FILE                                               { $$ = opt_lnk_obj($1); }
    | opt_fl_lst TOKEN_COMMA TOKEN_FILE                        { $$ = opt_merge($1, opt_lnk_obj($3)); }
    ;

opt_dir_lst
    : TOKEN_DIR                                                { $$ = opt_lnk_lib($1); }
    | opt_dir_lst TOKEN_COMMA TOKEN_DIR                        { $$ = opt_merge($1, opt_lnk_lib($3)); }
    ;

t_unused
    : TOKEN_UNUSED
    | t_unused t_num
    | t_unused TOKEN_COMMA t_num
    | t_unused TOKEN_SET t_num
    | t_unused TOKEN_COMMA TOKEN_UNUSED
    | t_unused TOKEN_SET TOKEN_UNUSED
    ;

t_num
    : TOKEN_ZERO                                               { $$ = 0;                         }
    | TOKEN_DDIGIT                                             { $$ = $1;                        }
    | TOKEN_DNUMBER                                            { sscanf($1, "%u", &$$); free($1);}
    | TOKEN_ZERO TOKEN_HEX_STR TOKEN_ZERO                      { $$ = 0;                         }
    | TOKEN_ZERO TOKEN_HEX_STR TOKEN_DDIGIT                    { $$ = $3;                        }
    | TOKEN_ZERO TOKEN_HEX_STR TOKEN_DNUMBER                   { sscanf($3, "%x", &$$); free($3);}
    | TOKEN_ZERO TOKEN_HEX_STR TOKEN_HNUMBER                   { sscanf($3, "%x", &$$); free($3);}
    | TOKEN_ZERO    TOKEN_HEX_END                              { $$ = 0;                         }
    | TOKEN_DDIGIT  TOKEN_HEX_END                              { $$ = $1;                        }
    | TOKEN_DNUMBER TOKEN_HEX_END                              { sscanf($1, "%x", &$$); free($1);}
    | TOKEN_HNUMBER TOKEN_HEX_END                              { sscanf($1, "%x", &$$); free($1);}
    ;

%%
