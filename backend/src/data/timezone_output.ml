(********************************************************************************)
(*	Timezone_output.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open XHTML.M


(**	Outputs the markup for a full timezone.
*)
let output_full tz =
	dl ~a:[a_class ["timezone_info"]]
		(dt [pcdata "Name:"])
		[
		dd [pcdata tz#name];
		dt [pcdata "Abbrev:"];
		dd [pcdata tz#abbrev];
		dt [pcdata "UTC offset:"];
		dd [pcdata (Printf.sprintf "%+06.2fh" tz#offset)];
		dt [pcdata "Daylight savings:"];
		dd [pcdata (string_of_bool tz#dst)]
		]

let describe tz =
	pcdata (Printf.sprintf "%s (%s) UTC%+06.2f" tz#name tz#abbrev tz#offset)

