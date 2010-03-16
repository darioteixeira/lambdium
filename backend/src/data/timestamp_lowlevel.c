/********************************************************************************/
/*	Timestamp_lowlevel.c
        Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
        This software is distributed under the terms of the GNU GPL version 2.
        See LICENSE file for full license text.
*/
/********************************************************************************/

/*	This module is necessary because Ocaml's Unix module gives us no access
	to the 'tzname' variables from Libc, and we need them in order to print
	out the abbreviated name of the user's timezone.
*/


#include <stdio.h>
#include <time.h>

#include <caml/memory.h>
#include <caml/alloc.h>


/********************************************************************************/
/* Public functions and values.							*/
/********************************************************************************/

CAMLprim value sprint_timestamp (value v_time)

	{
	CAMLparam1 (v_time);
	CAMLlocal1 (v_res);

	time_t time = Double_val (v_time);
	struct tm* lt = localtime (&time);
	char res [40];
	snprintf (res, sizeof (res), "%04d-%02d-%02d %02d:%02d:%02d (%s)",
		(lt->tm_year) + 1900, (lt->tm_mon) + 1, lt->tm_mday, lt->tm_hour, lt->tm_min, lt->tm_sec, tzname [lt->tm_isdst]);
	v_res = caml_copy_string (res);

	CAMLreturn (v_res);
	}

