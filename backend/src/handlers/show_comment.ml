(********************************************************************************)
(*	Show_comment.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt


(********************************************************************************)
(**	{2 Private functions}							*)
(********************************************************************************)

let output_canvas cid maybe_login sp =
	Lwt.catch
		(fun () ->
			Database.get_comment maybe_login cid >>= fun comment ->
			Canvas.custom [Comment_output.output_full maybe_login sp comment])
		(function
			| Database.Cannot_get_comment	-> Canvas.failure "Cannot find specified comment!"
			| exc				-> Lwt.fail exc)


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

let handler sp cid () =
	Page.standard_handler
		~sp
		~page_title: "Show Comment"
		~canvas_maker: (output_canvas cid)

