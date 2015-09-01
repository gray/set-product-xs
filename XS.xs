#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

MODULE = Set::Product::XS     PACKAGE = Set::Product::XS

void
product (code, ...)
    SV *code
PROTOTYPE: &@
PREINIT:
    int i, *idx;
    AV **in;
    SV **out;
    CV *cv;
    HV *stash;
    GV *gv;
PPCODE:
    cv = sv_2cv(code, &stash, &gv, 0);
    if (! cv)
      croak("Not a subroutine reference");

    if (2 > items)
        XSRETURN_EMPTY;

    for (i = 1; i < items; i++) {
        SvGETMAGIC(ST(i));
        if (! SvROK(ST(i)) || SVt_PVAV != SvTYPE(SvRV(ST(i))))
            croak("Not an array reference");
    }
    for (i = 1; i < items; i++)
        if (0 > av_len((AV *)SvRV(ST(i))))
            XSRETURN_EMPTY;
    items--;

    Newx(in, items, AV*);
    for (i = 0; i < items; i++)
        in[i] = (AV *)SvRV(ST(i+1));
    Newx(out, items, SV*);
    for (i = 0; i < items; i++)
        out[i] = AvARRAY(in[i])[0];
    Newxz(idx, items, int);

    for (i = 0; i >= 0; ) {
        int j;

        PUSHMARK(SP);
        EXTEND(SP, items);
        for (j = 0; j < items; j++)
            PUSHs(out[j]);
        PUTBACK;

        call_sv((SV *)cv, G_VOID | G_DISCARD);

        SPAGAIN;

        for (i = items - 1; i >= 0; i--) {
            idx[i]++;
            if (idx[i] > av_len(in[i])) {
                idx[i] = 0;
                out[i] = AvARRAY(in[i])[0];
            }
            else {
                out[i] = AvARRAY(in[i])[idx[i]];
                break;
            }
        }
    }

    Safefree(in);
    Safefree(out);
    Safefree(idx);
