(********************************************************************************)
(*	View_stories.ml
        Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
        This software is distributed under the terms of the GNU GPL version 2.
        See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open XHTML.M
open Page


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

let output_core maybe_login sp =
	Database.get_stories () >>= fun stories ->
	match stories with
		| hd :: tl ->
			let hd' = Story_io.output_blurb maybe_login sp hd
			and tl' = List.map (Story_io.output_blurb maybe_login sp) tl
			in
			Lwt.return (Stat_nothing, Some [ul ~a:[a_class ["list_of_stories"]] hd' tl'])
		| [] ->
			Lwt.return (Stat_warning [p [pcdata "There are no stories in the system!"]], None)


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler sp () () =
	Page.login_agnostic_handler
		~sp
		~page_title: "View Stories"
		~output_core
		()

