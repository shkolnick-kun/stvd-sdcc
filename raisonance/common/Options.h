#ifndef _OPTIONS_H_
#define _OPTIONS_H_

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <malloc.h>
#include <errno.h>
// Common
extern char* my_strdup(char* s);
extern char* my_concat(char* a, char* b);
extern char* opt_merge(char* a, char* b);
extern char* opt_inc_path(char* a);
// Compiler
extern char* opt_df_df(char* a);
extern char* opt_df_str(char* a, char* b);
extern char* opt_df_num(char* a, int b);

extern char* opt_opt_lev(bool sz, int l);
extern char* opt_obj(char* a);

extern bool debug_opt;
extern char* opt_cc_get_opt(char* a);
extern char* opt_cc_get_cmd(char* a, char * fname);
// Assembler
extern char * asm_obj;
extern char* opt_asm_get_opt(char* a);
extern char* opt_asm_get_cmd(char* a, char * fname);
// Linker
extern char* lnk_obj_list;
extern char* lnk_out_basename;
extern char* opt_lnk_obj(char* a);
extern char* opt_lnk_lib(char* a);
extern char* opt_lnk_dbg(void);
extern char* opt_lnk_cstr(int x);
extern char* opt_lnk_csz(int x);
extern char* opt_lnk_dstr(int x);
extern char* opt_lnk_dsz(int x);
extern char* opt_lnk_stack(int x);
extern char* opt_lnk_get_cmd(char* a);
#endif // _OPTIONS_H_
