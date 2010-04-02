(********************************************************************************)
(*	Show_comment.ml
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

let output_core cid maybe_login sp =
	try_lwt
		Database.get_comment cid >>= fun comment ->
		Lwt.return [Comment_io.output_full maybe_login sp comment]
	with
		Database.Unknown_cid ->
			Status.failure ~sp [pcdata "Cannot find specified comment!"] [];
			Lwt.return []


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler sp cid () =
	Page.login_agnostic_handler
		~sp
		~page_title: "Show Comment"
		~output_core: (output_core cid)
		()

