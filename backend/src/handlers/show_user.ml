(********************************************************************************)
(*	Show_user.ml
        Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
        This software is distributed under the terms of the GNU GPL version 2.
        See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt


(********************************************************************************)
(**	{2 Private helper functions}						*)
(********************************************************************************)

let output_canvas uid maybe_login sp =
	Lwt.catch
		(fun () ->
			Database.get_user uid >>= fun user ->
			let stories_thread =  Database.get_user_stories uid
			and comments_thread = Database.get_user_comments uid
			and timezone_thread = Database.get_timezone user#timezone#tid in
			stories_thread >>= fun stories ->
			comments_thread >>= fun comments ->
			timezone_thread >>= fun timezone ->
			Canvas.custom [User_output.output_full sp user timezone stories comments])
		(function
			| Database.Cannot_get_user	-> Canvas.failure "Cannot find specified user!"
			| exc				-> Lwt.fail exc)


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

let handler sp uid () =
	Page.standard_handler
		~sp
		~page_title: "Show User"
		~canvas_maker: (output_canvas uid)

