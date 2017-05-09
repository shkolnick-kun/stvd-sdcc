%{

/*
 * Lexer.l file
 * To generate the lexical analyzer run: "flex Lexer.l"
 */
#include <stdio.h>
#include <stdlib.h>
//#include <stdint.h>
//#include <stdbool.h>
#include <string.h>


#define YYDEBUG 1

#include <Options.h>
#include "InputParser.h"

//#define YYSTYPE YY_OPT_STYPE
%}

%option outfile="InputLexer.c" header-file="InputLexer.h"
%option warn nodefault

%option reentrant noyywrap never-interactive nounistd
%option bison-bridge

SET         "="
LPAREN      "("
RPAREN      ")"
COMMA       ","

WS          [ \r\n\t]*

UNUSED_1    (NOOBJECT|noobject|NOOJ|nooj|NODEBUG|nodebug|NODB|nodb)
UNUSED_2    (CASESENSITIVE|casesensitive|CS|cs|CASEINSENSITIVE|caseinsensitive|CIS|cis)
UNUSED_3    (MODESTM8|modestm8|NOPRINTMODEST7|modest7|NOPRINT|noprint|NOPR|nopr)
UNUSED_4    (PAGEWIDTH|pagewidth|PW|pw|COND|cond|CD|cd|NOCOND|nocond|NOCD|nocd)
UNUSED_5    (ERRORPRINT|errorptint|EP|ep|NOERRORPRINT|noerrorptint|NOEP|noep)
UNUSED_6    (GEN|gen|NOGEN|nogen|LIST|list|LI|li|NOLIST|nolist|NOLI|noli)
UNUSED_7    (SYMBOLS|symbols|SB|sb|NOSYMBOLS|nosymbols|NOSB|nosb)
UNUSED_8    (XREF|xref|XR|xr|NOXREF|noxref|NOXR|noxr)

UNUSED_01   ({UNUSED_1}|{UNUSED_2}|{UNUSED_3}|{UNUSED_4}|{UNUSED_5}|{UNUSED_6})
UNUSED_02   ({UNUSED_7}|{UNUSED_8})

UNUSED      ({UNUSED_01}|{UNUSED_02})

DEBUG       ("DEBUG"|"debug"|"DB"|"db")
OBJECT      ("OBJECT"|"object"|"OJ"|"oj")
INCLUDE     ("INCLUDE"|"include"|"I"|"i")
PATHINCLUDE ("PATHINCLUDE"|"pathinclude"|"PIN"|"pin")
PRINT       ("PRINT"|"print"|"PR"|"pr")
QUIET       ("QUIET"|"quiet")

NUMBER      [0-9]+

PATH         [a-zA-Z0-9\\\/\_\.\:\[\]\{\}\- ]+

FULL_PATH   ({PATH}|({PATH}(\(x86\))?{PATH}))


%s GET_FILE
%s GET_DIR

%%
{WS}            { /* Skip blanks. */ }
{UNUSED}        { return TOKEN_UNUSED; }
{DEBUG}         { return TOKEN_DEBUG; }
{OBJECT}        { BEGIN(GET_FILE); return TOKEN_OBJECT; }
{INCLUDE}       { BEGIN(GET_FILE); return TOKEN_INCLUDE; }
{PATHINCLUDE}   { BEGIN(GET_DIR);  return TOKEN_PATHINCLUDE; }
{PRINT}         { BEGIN(GET_FILE); return TOKEN_PRINT; }
{NUMBER}        { return TOKEN_NUMBER; }
{QUIET}         { return TOKEN_QUIET; }

<GET_FILE>{FULL_PATH} { yylval->file   = my_strdup(yytext); return TOKEN_FILE;  }
<GET_DIR>{FULL_PATH}  { yylval->dir    = my_strdup(yytext); return TOKEN_DIR;   }

{LPAREN}        { return TOKEN_LPAREN; }
{RPAREN}        { BEGIN(INITIAL); return TOKEN_RPAREN; }
{COMMA}         { return TOKEN_COMMA; }
.               { /**/ }

%%
