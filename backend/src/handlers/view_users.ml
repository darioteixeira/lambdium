(********************************************************************************)
(*	View_users.ml
        Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
        This software is distributed under the terms of the GNU GPL version 2.
        See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open XHTML.M


(********************************************************************************)
(**	{2 Private helper functions}						*)
(********************************************************************************)

let output_canvas maybe_login sp =
	Database.get_users () >>= fun users ->
	match users with
		| hd :: tl ->
			Canvas.custom
				[ul ~a:[a_class ["list_of_users"]]
					(User_output.output_handle sp hd)
					(List.map (User_output.output_handle sp) tl)]
		| [] ->
			Canvas.failure "There are no users in the system!"


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

let handler sp () () =
	Page.standard_handler
		~sp
		~page_title: "View users"
		~canvas_maker: output_canvas

