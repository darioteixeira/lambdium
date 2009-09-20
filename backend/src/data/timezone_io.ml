(********************************************************************************)
(*	Timezone_io.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open XHTML.M


(********************************************************************************)
(**	{1 Output-related functions}						*)
(********************************************************************************)

let output_full tz =
	dl ~a:[a_class ["timezone_info"]]
		(dt [pcdata "Name:"])
		[
		dd [pcdata tz#name];
		]

let describe tz =
	pcdata (Printf.sprintf "%s" tz#name)

