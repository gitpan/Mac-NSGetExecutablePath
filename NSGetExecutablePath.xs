/* This file is part of the Mac::NSGetExecutablePath Perl module.
 * See http://search.cpan.org/dist/Mac-NSGetExecutablePath/ */

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <mach-o/dyld.h>


static const char nsgep_too_long[] = "NSGetExecutablePath() wants to return a path too large";

/* --- XS ------------------------------------------------------------------ */

MODULE = Mac::NSGetExecutablePath        PACKAGE = Mac::NSGetExecutablePath

PROTOTYPES: ENABLE

void
NSGetExecutablePath()
PROTOTYPE:
PREINIT:
 char      buf[1];
 uint32_t  size = sizeof buf;
 SV       *dst;
 char     *buffer;
PPCODE:
 _NSGetExecutablePath(buf, &size);
 if (size >= MAXPATHLEN * MAXPATHLEN)
  croak(nsgep_too_long);
#ifdef newSV_type
 dst = newSV_type(SVt_PV);
#else
 dst = sv_newmortal();
 (void) SvUPGRADE(dst, SVt_PV);
#endif
 buffer = SvGROW(dst, size);
 if (_NSGetExecutablePath(buffer, &size))
  croak(nsgep_too_long);
 SvCUR_set(dst, size - 1);
 SvPOK_on(dst);
 XPUSHs(dst);
 XSRETURN(1);
