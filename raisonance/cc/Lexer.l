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

UNUSED_1    (NOAUTO|noauto|AUTOINLINE|autoinline)
UNUSED_2    (CLEANIRQDIVFLAG|cleanirqdivflag|NOCLEANIRQDIVFLAG|nocleanirqdivflag)
UNUSED_3    (CODE|code|CD|cd|COND|cond|CO|co|NOCOND|nocond|NOCO|noco|NODEBUG|nodebug|NODB|nodb)
UNUSED_4    (DEFAULTGC|defaultgc|DGC|dgc|DEFAULTLC|defaultlc|DLC|dlc|DEFINEJOKER|definejoker|DEFJ|defj)
UNUSED_5    (DUPLICATESTRING|duplicatestring|DS|ds|NODUPLICATESTRING|noduplicatestring|NODS|nods)
UNUSED_6    (ENUMTYPE|enumtype|ET|et|FARPOINTERS|farpointers|NOFARPOINTERS|nofarpointers|NOFP|nofp)
UNUSED_7    (GENERATEDEPFILE|generatedepfile|GENDEP|gendep|GLOBAL|global|GLB|glb)
UNUSED_8    (INITSTATICVAR|initstaticvar|IS|is|NOINITSTATICVAR|noinitstaticvar|NOIS|nois)
UNUSED_9    (INLINE|"inline"|NOINLINE|noinline|INLINEFUNCTION|inlinefunction|INSECTION0|insection0|NOINSECTION0|noin0)
UNUSED_10   (INRAM|inram|NOINRAM|noinram|NOIR|noir|INTVECTOR|intvector|NOINTVECTOR|nointvector)
UNUSED_11   (LARGEOBJECT|largeobject|LAOB|laob|SMALLOBJECT|smallobject|LARGESTACK|largestack)
UNUSED_12   (NOLARGESTACK|nolargestack|nolstk|LISTINCLUDE|listinclude|LC|lc|NOLISTINCLUDE|nolistinclude)
UNUSED_13   (MAXERR|maxerr|MAXWAR|maxwar|MODANSI|modansi|ansi|NOPRINTOFFSET|noprintoffset|NOPROF|noprof)
UNUSED_14   (NOPROPAGATION|nopropagation|NOPROP|noprop|NOOBJECT|noobject|NOOJ|nooj)
UNUSED_15   (PREPRINTON|preprinton|PPON|ppon|PREPRINTOFF|preprintoff|PPOFF|ppoff|NOPRINT|noprint|NOPR|nopr)
UNUSED_16   (QUIET|quiet|NOQUIET|noquiet|RESTORE|restore|SAVE|save|SPACEDEF|spacedef|SD|sd|SRC|src)
UNUSED_17   (STACKSPACEFOREXP|stackspaceforexp|SSX|ssx|STM8|stm8|STM8SET|stm8set|STM8STACKSET0|stm8stackset0|STACK0|stack0)
UNUSED_18   (STM8STACKSET1|stm8stackset1|STACK1|stack1|STRUCT_OPT|struct_opt|SUE_OPT|sue_opt|SYMBOLS|symbols|SB|sb)
UNUSED_19   (UNSIGNEDCHAR|unsignedchar|UNSC|unsc|WARNINGRETVAL|warningretval|WRV|wrv)

UNUSED_01   ({UNUSED_1}|{UNUSED_2}|{UNUSED_3}|{UNUSED_4}|{UNUSED_5}|{UNUSED_6})
UNUSED_02   ({UNUSED_7}|{UNUSED_8}|{UNUSED_9}|{UNUSED_10}|{UNUSED_11}|{UNUSED_12})
UNUSED_03   ({UNUSED_13}|{UNUSED_14}|{UNUSED_15}|{UNUSED_16}|{UNUSED_17}|{UNUSED_18})
UNUSED_04   ({UNUSED_19})

UNUSED      ({UNUSED_01}|{UNUSED_02}|{UNUSED_03}|{UNUSED_04})

DEBUG       ("DEBUG"|"debug"|"DB"|"db")
AUTO        ("AUTO"|"auto"|"AU"|"au")
WL          ("WARNINGLEVEL"|"warninglevel"|"WL"|"wl")
SC          ("SIGNEDCHAR"|"signedchar"|"SC"|"sc")
OBJECT      ("OBJECT"|"object"|"OJ"|"oj")
INCLUDE     ("INCLUDE"|"include"|"I"|"i")
PREPRINT    ("PREPRINT"|"preprint"|"PP"|"pp")
PRINT       ("PRINT"|"print"|"PR"|"pr")
PATHINCLUDE ("PATHINCLUDE"|"pathinclude"|"PIN"|"pin")

OPTIMIZE    ("OPTIMIZE"|"optimize"|"OT"|"ot"|"O"|"o")
SIZE        ("SIZE"|"size")
SPEED       ("SPEED"|"speed")

DEFINE      ("DEFINE"|"define"|"DF"|"df")

NUMBER      [0-9]+
DFSTR       [a-zA-Z\_][a-zA-Z0-9\_]*

PATH         [a-zA-Z0-9\\\/\_\.\:\[\]\{\}\- ]+

FULL_PATH   ({PATH}|({PATH}(\(x86\))?{PATH}))


%s GET_FILE
%s GET_DIR
%s GET_DF

%%
{WS}            { /* Skip blanks. */ }
{UNUSED}        { return TOKEN_UNUSED; }
{DEBUG}         { return TOKEN_DEBUG; }
{AUTO}          { return TOKEN_AUTO; }
{SC}            { return TOKEN_SC; }
{WL}            { return TOKEN_WL; }
{OBJECT}        { BEGIN(GET_FILE); return TOKEN_OBJECT; }
{INCLUDE}       { BEGIN(GET_FILE); return TOKEN_INCLUDE; }
{PREPRINT}      { BEGIN(GET_FILE); return TOKEN_PREPRINT; }
{PRINT}         { BEGIN(GET_FILE); return TOKEN_PRINT; }
{PATHINCLUDE}   { BEGIN(GET_DIR);  return TOKEN_PATHINCLUDE; }
{OPTIMIZE}      { return TOKEN_OPTIMIZE; }
{SIZE}          { return TOKEN_SIZE; }
{SPEED}         { return TOKEN_SPEED; }
{DEFINE}        { BEGIN(GET_DF); return TOKEN_DEFINE; }

<GET_DF>{DFSTR}       { yylval->string = my_strdup(yytext); return TOKEN_DFSTR; }
<GET_FILE>{FULL_PATH} { yylval->file   = my_strdup(yytext); return TOKEN_FILE;  }
<GET_DIR>{FULL_PATH}  { yylval->dir    = my_strdup(yytext); return TOKEN_DIR;   }

{NUMBER}              { sscanf(yytext, "%d", &yylval->num); return TOKEN_NUMBER; }

{LPAREN}        { return TOKEN_LPAREN; }
{RPAREN}        { BEGIN(INITIAL); return TOKEN_RPAREN; }
{SET}           { return TOKEN_SET; }
{COMMA}         { return TOKEN_COMMA; }
.               { /**/ }

%%

//int yy_opt_lex_error(const char *msg) {
//    fprintf(stderr,"Error:%s\n",msg); return 0;
//}
