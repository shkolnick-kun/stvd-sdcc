#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <malloc.h>
#include <errno.h>

#include <Options.h>

/**
////////////////////////////////////////////////////////////////////////////
SDCC uses the standard error (stderr) for error output. You should use

c:>d:\sdcc\bin\sdcc.exe -c -I d:\sdcc\Include e:\sample\sample.c > 1.txt
> 2.txt

Errors will be redirected to the file 2.txt.

Felipe
////////////////////////////////////////////////////////////////////////////
https://ss64.com/nt/syntax-redirection.html
http://www.robvanderwoude.com/redirection.php
http://www.perlmonks.org/?node=How%20can%20I%20capture%20STDERR%20from%20an%20external%20command%3F
////////////////////////////////////////////////////////////////////////////
MASM options:

+ OBJECT|OJ
+ DEBUG|DB
+ INCLUDE
+ PATHINCLUDE|PIN
+ PRINT|PR

+ NOOBJECT|NOOJ
+ NODEBUG|NODB
+CASESENSITIVE|CS
+ CASEINSENSITIVE|CIS
+ MODESTM8
+ MODEST7
+ NOPRINT|NOPR
+ PAGEWIDTH|PW
+ COND
+ NOCOND
+ ERRORPRINT|EP
+ NOERRORPRINT|NOEP
+ GEN
+ NOGEN
+ LIST|LI
+ NOLIST|NOLI
+ SYMBOLS|SB
+ NOSYMBOLS|NOSB
XREF|XR
NOXREF|NOXR
QUIET
*/

//int main(int argc, char *argv[])
//{
//    uint32_t i;
//    size_t len;
//    char * input;
//    char * dst;
//    const char * space = " ";
//
//    len = 0;
//    for (i = 1; i < argc; i++)
//    {
//        len += strlen(argv[i]) + 1;//One symbol for space
//        printf("\n%s", argv[i]);
//    }
//
//    input = malloc(len);
//
//    if (NULL == input)
//    {
//        printf("\nERROR: Out of memory!!!\n");
//        exit(ENOMEM);
//    }
//
//    len = 0;
//    for (i = 1; i < argc - 1; i++)
//    {
//        (void)strcpy(input + len, argv[i]);
//        len += strlen(argv[i]);
//        (void)strcpy(input + len, space);
//        len++;
//    }
//    (void)strcpy(input + len, argv[argc-1]);
//
//    printf("\n%s\n", input);
//
//    free(input);
//    return 0;
//}

/*
 * main.c file
 */

#include "Options.h"
#include "InputParser.h"
#include "InputLexer.h"

/*
DIR         [a-zA-Z0-9\/.-]+   ([a-zA-Z]\:[\\\/])?([a-zA-Z0-9\.\\\/\[\]\9\0\{\}\_\-\+\=]{2,}[\\\/]|[a-zA-Z]\:[\\\/])
FILE        [a-zA-Z0-9\/.-]+  {DIR}[a-zA-Z0-9\.\[\]\9\0\{\}\_\-\+\=]+\.[CcHcOo]


([a-zA-Z]\:[\\\/]|\.\.[\\\/]|[\\\/][\\\/])? - начало пути

*/



#include <stdio.h>

//int yyparse(SExpression **expression, yyscan_t scanner);
extern int yydebug;

int main(int argc, char *argv[])
{

    uint32_t i;
    size_t len;
    char * input;
    const char * space = " ";

    yyscan_t scanner;
    YY_BUFFER_STATE state;
    char * opt_str = NULL;
    // Concatenate options
    len = 0;
    for (i = 2; i < argc; i++)
    {
        len += strlen(argv[i]) + 1;//One symbol for space
    }

    input = malloc(len);

    if (NULL == input)
    {
        printf("\nERROR: Out of memory!!!\n");
        exit(1);
    }

    len = 0;
    for (i = 2; i < argc - 1; i++)
    {
        (void)strcpy(input + len, argv[i]);
        len += strlen(argv[i]);
        (void)strcpy(input + len, space);
        len++;
    }
    (void)strcpy(input + len, argv[argc-1]);
    // Parse options
    //yydebug = 1;

    if (yylex_init(&scanner)) {
        // couldn't initialize
        printf("\nERROR: Could not init scanner!!!\n");
        exit(2);
    }

    state = yy_scan_string(input, scanner);

    if (yyparse(&opt_str, scanner)) {
        // error parsing
        printf("\nERROR: Parsing error!!!\n");
        exit(3);
    }

    yy_delete_buffer(state, scanner);

    yylex_destroy(scanner);

    if( NULL == opt_str )
    {
        printf("\nERROR: Parsing error!!!\n");
        exit(4);
    }

    opt_str = opt_asm_get_cmd(opt_str, argv[1]);

    if( NULL == opt_str )
    {
        printf("\nERROR: Parsing error!!!\n");
        exit(5);
    }

    printf("\n%s\n", opt_str);

    return system(opt_str);
}
