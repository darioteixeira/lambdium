(********************************************************************************)
(*	Canvas implementation.
	Copyright (c) 2007-2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open XHTML.M


(********************************************************************************)
(**	{2 Private functions}							*)
(********************************************************************************)

let output_canvas contents =
	Lwt.return (div ~a:[a_id "canvas"] contents)


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

(**	Outputs a customised canvas, whose contents must be provided.
*)
let custom = output_canvas


(**	Outputs a standard canvas for reporting a success condition.
	The actual success message must be provided.
*)
let success msg =
	output_canvas [p ~a:[a_class ["msg_success"]] [pcdata msg]]


(**	Outputs a standard canvas for reporting a failure condition.
	The actual failure message must be provided.
*)
let failure msg =
	output_canvas [p ~a:[a_class ["msg_failure"]] [pcdata msg]]


(**	Outputs a standard canvas for reporting that the user is not logged in.
*)
let identity_failure () =
	failure "You are not logged in!"

