(********************************************************************************)
(*	Show_user.ml
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

let output_core uid maybe_login sp =
	try_lwt
		Database.get_user uid >>= fun user ->
		let stories_thread = Database.get_user_stories uid
		and comments_thread = Database.get_user_comments uid
		and timezone_thread = Database.get_timezone user#timezone#tid in
		stories_thread >>= fun stories ->
		comments_thread >>= fun comments ->
		timezone_thread >>= fun timezone ->
		Lwt.return [User_io.output_full sp user timezone stories comments]
	with
		Database.Unknown_uid ->
			Status.failure ~sp [pcdata "Cannot find specified user!"] [];
			Lwt.return []


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler sp uid () =
	Page.login_agnostic_handler
		~sp
		~page_title: "Show User"
		~output_core: (output_core uid)
		()


