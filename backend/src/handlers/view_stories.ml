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
(**	{1 Private functions and values}					*)
(********************************************************************************)

let output_core maybe_login sp =
	Database.get_stories maybe_login >>= fun stories ->
	match stories with
		| hd :: tl ->
			Lwt.return [ul ~a:[a_class ["list_of_stories"]]
				(Story_io.output_blurb maybe_login sp hd)
				(List.map (Story_io.output_blurb maybe_login sp) tl)]
		| [] ->
			Lwt.return [p [pcdata "There are no stories in the system!"]]


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler sp () () =
	Page.login_agnostic_handler
		~sp
		~page_title: "View Stories"
		~output_core
		()

