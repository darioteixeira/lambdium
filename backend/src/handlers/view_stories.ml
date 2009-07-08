(********************************************************************************)
(*	View_stories.ml
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
	Database.get_stories maybe_login >>= fun stories ->
	match stories with
		| hd :: tl ->
			Canvas.custom
				[ul ~a:[a_class ["list_of_stories"]]
					(Story_output.output_blurb maybe_login sp hd)
					(List.map (Story_output.output_blurb maybe_login sp) tl)]
		| [] ->
			Canvas.failure "There are no stories in the system!"


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

let handler sp () () =
	Page.standard_handler
		~sp
		~page_title: "View Stories"
		~canvas_maker: output_canvas

