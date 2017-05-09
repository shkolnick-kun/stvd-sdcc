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

UNUSED_1    (BIT|bit|BI|bi|"-C"|"-c"|"-PC"|"-pc"|"-pC"|"-Pc"|CODE|code|CD|cd|CRCPLACE|crcplace|PLACECRC|placecrc)
UNUSED_2    (DATA|data|DT|dt|FASTLIBRARY|fastlibrary|FASTLIB|fastlib|FILLGAP|fillgap|GAP|gap)
UNUSED_3    (FCODE|fcode|FCO|fco|FDATA|fdata|FDT|fdt|GLOBAL|global|GLB|glb)
UNUSED_4    (INPAGE|inpage|IP|ip|IXREF|ixref|IX|ix|LINES|lines|LI|li)
UNUSED_5    (NODEBUGLINES|nodebuglines|NODL|nodl|NODEBUGPUBLICS|nodebugpublicls|NODP|nodp)
UNUSED_6    (NODEBUGSYMBOLS|nodebugsymbols|NODS|nods|NOFASTLIBRARY|nofastlibrary|NOFASTLIB|nofastlib)
UNUSED_7    (NOIXREF|noixref|NOIX|noix|NOLINES|nolines|NOLI|noli|NOMAP|nomap|NOMA|noma)
UNUSED_8    (NOOVERLAY|nooverlay|NOOL|nool|NOPRINT|noprint|NOPR|nopr|NOPUBLICS|nopublics|NOPU|nopu)
UNUSED_9    (NOSYMBOLS|nosymbols|NOSB|nosb|OVERLAY|overplay|OL|ol|"-P"|"-p"|PAGEWIDTH|pagewidth|PW|pw)
UNUSED_10   (POSTOPTI|postopti|PRESERVE|preserve|PUBLICS|publics|PU|pu)
UNUSED_11   (REDEFINE|redefine|REDEF|redef|REMOVEUNCALLED|removeuncalled|RMUN|rmun)
UNUSED_12   (RESERVE|reserve|RES|res|SEGALIGNMENT|segalignment|SA|sa|SEGINCLUSION|seginclusion|SI|si)
UNUSED_13   (SEGMENTOVERLAY|segmentoverlay|SO|so|STACKSIZE|stacksize|SS|ss)
UNUSED_14   (SCINAME|sciname|SYMBOLS|symbols|SB|sb)

UNUSED_01   ({UNUSED_1}|{UNUSED_2}|{UNUSED_3}|{UNUSED_4}|{UNUSED_5}|{UNUSED_6})
UNUSED_02   ({UNUSED_7}|{UNUSED_8}|{UNUSED_9}|{UNUSED_10}|{UNUSED_11}|{UNUSED_12})
UNUSED_03   ({UNUSED_13}|{UNUSED_14})

UNUSED      ({UNUSED_01}|{UNUSED_02}|{UNUSED_03})


INPUT       ("INPUT"|"input")

CSZ         (CODESIZE|codesize|CSIZE|csize)
CSTR        (CODESTART|codestart|CST|cst)

DSTR        (DATASTART|datastart|DST|dst)

DBGL        (DEBUGLINES|debuglines|DL|dl)
DBGP        (DEBUGPUBLICS|debugpublics|DP|dp)
DBGS        (DEBUGSYMBOLS|debugsymbols|DS|ds)
DEBUG       ({DBGL}|{DBGP}|{DBGS})

EESZ        (EEPROMSIZE|eepromsize|ESZ|esz)
EESTR       (EEPROMSTART|eepromstart|EST|est)
LIB         (LIBPATH|libpath)
MAP         ("MAP"|"map"|MA|ma)
OUTPUT      (NAME|name|NA|na|TO|to)
NOSTDLIB    (NODEFAULTLIBRARY|nodefaultlibrary|NLIB|nlib)
PRINT       ("PRINT"|"print"|"PR"|"pr")
RAMSIZE     ("RAMSIZE"|"ramsize"|"RS"|"rs")
STACKTOP    ("STACKTOP"|"stacktop"|"ST"|"st")

ZERO        0
HEX_STR     x
HEX_END     [Hh]
DDIGIT      [1-9]
DNUMBER     {DDIGIT}[0-9]*
HNUMBER     [0-9a-fA-F]+

QUOTE       \"

DFSTR       [a-zA-Z\_][a-zA-Z0-9\_]*
PATH         [a-zA-Z0-9\\\/\_\.\:\[\]\{\}\- ]+
FULL_PATH   ({PATH}|({PATH}(\(x86\))?{PATH}))

%s GET_FILE
%s GET_DIR

%%
{WS}            { /* Skip blanks. */ }
{UNUSED}        { return TOKEN_UNUSED; }
{DEBUG}         { return TOKEN_DEBUG; }
{CSZ}           { return TOKEN_CSZ; }
{CSTR}          { return TOKEN_CSTR; }
{DSTR}          { return TOKEN_DSTR; }
{EESZ}          { return TOKEN_EESZ; }
{EESTR}         { return TOKEN_EESTR; }

{LIB}           { BEGIN(GET_DIR); return TOKEN_LIB; }
{MAP}           { return TOKEN_MAP; }
{OUTPUT}        { BEGIN(GET_FILE); return TOKEN_OUT; }
{NOSTDLIB}      { return TOKEN_NOSTDLIB; }
{RAMSIZE}       { return TOKEN_RAMSZ; }
{STACKTOP}      { return TOKEN_STACKTOP; }
{PRINT}         { BEGIN(GET_FILE); return TOKEN_PRINT; }

<INITIAL>{ZERO}       { return TOKEN_ZERO;    }
<INITIAL>{HEX_STR}    { return TOKEN_HEX_STR; }
<INITIAL>{HEX_END}    { return TOKEN_HEX_END; }
<INITIAL>{DDIGIT}     { sscanf(yytext, "%u", &yylval->num); return TOKEN_DDIGIT;  }
<INITIAL>{DNUMBER}    { yylval->string = my_strdup(yytext); return TOKEN_DNUMBER; }
<INITIAL>{HNUMBER}    { yylval->string = my_strdup(yytext); return TOKEN_HNUMBER; }

<INITIAL>{QUOTE}      { BEGIN(GET_FILE); return TOKEN_QUOTE; }
<GET_FILE>{FULL_PATH} { yylval->file   = my_strdup(yytext); return TOKEN_FILE;  }
<GET_FILE>{QUOTE}     { BEGIN(INITIAL); return TOKEN_QUOTE; }

<GET_DIR>{FULL_PATH}  { yylval->dir    = my_strdup(yytext); return TOKEN_DIR;   }

{LPAREN}        { return TOKEN_LPAREN; }
{RPAREN}        { BEGIN(INITIAL); return TOKEN_RPAREN; }
{SET}           { return TOKEN_SET; }
{COMMA}         { return TOKEN_COMMA; }
.               { /**/ }

%%

//int yy_opt_lex_error(const char *msg) {
//    fprintf(stderr,"Error:%s\n",msg); return 0;
//}
