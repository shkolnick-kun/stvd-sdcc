#include "Options.h"

extern bool debug_opt = false;

char* my_strdup(char* s)
{
    char* p = malloc(strlen(s)+1);
    if (p) strcpy(p, s);
    return p;
}

static char str_buf[1024] = {0};

char* my_concat(char* a, char* b)
{
    sprintf(str_buf, "%s%s", a, b);
    return my_strdup(str_buf);
}

char* opt_merge(char* a, char* b)
{
    char * p;
    p = my_concat(a, b);
    free(a);
    free(b);
    return p;
}

char* opt_inc_path(char* a)
{
    sprintf(str_buf, " -I\"%s\"", a);
    free(a);
    return my_strdup(str_buf);
}
//=====================================================
// Compiler
//=====================================================
char* opt_df_df(char* a)
{
    sprintf(str_buf, " -D%s", a);
    free(a);
    return my_strdup(str_buf);
}

char* opt_df_str(char* a, char* b)
{
    sprintf(str_buf, " -D%s=%s", a, b);
    free(a);
    free(b);
    return my_strdup(str_buf);
}

char* opt_df_num(char* a, int b)
{
    sprintf(str_buf, " -D%s=%d", a, b);
    free(a);
    return my_strdup(str_buf);
}



char* opt_opt_lev(bool sz, int l)
{
    char * p = NULL;
    if( l > 0 )
    {
        if( sz )
        {
            p = my_strdup(" --opt-code-size" );
        }
        else
        {
            p = my_strdup(" --opt-code-speed" );
        }
    }
    return p;
}


char* opt_obj(char* a)
{
    sprintf(str_buf, " -o \"%s.rel\"", a);
    free(a);
    return my_strdup(str_buf);
}

char* opt_cc_get_opt(char* a)
{
    if( !debug_opt )
    {
        a = opt_merge(a, my_strdup(" --out-fmt-ihx"));
    }
    a = opt_merge(my_strdup("--verbose --stack-auto -lstm8 -mstm8"), a);
    return a;
}

char* opt_cc_get_cmd(char* a, char * fname)
{
    a = opt_merge(my_strdup("\" "), a);
    a = opt_merge(my_strdup(fname), a);
    a = opt_merge(my_strdup("sdcc -c \""), a);
    return a;
}
//=====================================================
// Assembler
//=====================================================
char * asm_obj = NULL;
char* opt_asm_get_opt(char* a)
{
    return opt_merge(my_strdup(" "), a);
}

char* opt_asm_get_cmd(char* a, char * fname)
{
    a = opt_merge(my_strdup("sdasstm8 -opff"), a);
    if (NULL != asm_obj)
    {
        a = opt_merge(a, my_strdup(" \""));
        a = opt_merge(a, asm_obj);
        a = opt_merge(a, my_strdup(".rel\""));
    }
    a = opt_merge(a, my_strdup(" \""));
    a = opt_merge(a, my_strdup(fname));
    a = opt_merge(a, my_strdup("\""));
    return a;
}
//=====================================================
// Linker
//=====================================================
char* lnk_obj_list = NULL;
char* lnk_out_basename = NULL;

char* opt_lnk_obj(char* a)
{
    a = opt_merge(my_strdup(" \""), a);
    a = opt_merge(a, my_strdup(".rel\""));
    return a;
}

char* opt_lnk_lib(char* a)
{
    a = opt_merge(my_strdup(" -L\""), a);
    a = opt_merge(a, my_strdup("\""));
    return a;
}

char* opt_lnk_dbg(void)
{
    if (!debug_opt)
    {
        debug_opt = true;
        return my_strdup(" --out-fmt-elf --debug");
    }
    else
    {
        return my_strdup("");
    }
}

char* opt_lnk_cstr(int x)
{
    sprintf(str_buf, " --code-loc 0x%x", x);
    return my_strdup(str_buf);
}

char* opt_lnk_csz(int x)
{
    sprintf(str_buf, " --code-size 0x%x", x);
    return my_strdup(str_buf);
}

char* opt_lnk_dstr(int x)
{
    sprintf(str_buf, " --data-loc 0x%x", x);
    return my_strdup(str_buf);
}

char* opt_lnk_dsz(int x)
{
    sprintf(str_buf, " --iram-size 0x%x", x);
    return my_strdup(str_buf);
}

char* opt_lnk_stack(int x)
{
    sprintf(str_buf, " --stack-loc 0x%x", x);
    return my_strdup(str_buf);
}

char* opt_lnk_get_cmd(char* a)
{
    if( NULL == lnk_out_basename )
    {
        lnk_out_basename = my_strdup("out");
    }

    if( NULL == lnk_obj_list )
    {
        lnk_obj_list = my_strdup("");
    }

    //Add output file options
    if( !debug_opt )
    {
        a = opt_merge(a, my_strdup(" --out-fmt-ihx"));
        sprintf(str_buf, " -o \"%s.hex\"", lnk_out_basename);
    }
    else
    {
        sprintf(str_buf, " -o \"%s.elf\"", lnk_out_basename);
    }
    free(lnk_out_basename);//Not needed any more
    a = opt_merge(a, my_strdup(str_buf));
    //Additional stm8 options
    a = opt_merge(my_strdup(" --verbose --stack-auto -lstm8 -mstm8"), a);
    //Add object file list
    a = opt_merge(a, lnk_obj_list);
    return opt_merge(my_strdup("sdcc "), a);
}
