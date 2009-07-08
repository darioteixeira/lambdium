(********************************************************************************)
(**	This module is responsible for managing user sessions.

	Copyright (c) 2007-2009 Dario Teixeira (dario.teixeira@yahoo.com)

	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt


(********************************************************************************)
(**	{2 Exceptions that may be raised by this module}			*)
(********************************************************************************)

exception Invalid_login
exception No_login


(********************************************************************************)
(**	{2 Private functions}							*)
(********************************************************************************)

let table = Eliom_sessions.create_persistent_table "login_table"


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

(**	Returns the currently logged-in user, if any.
*)
let get_maybe_login sp =
	Eliom_sessions.get_persistent_session_data ~table ~sp () >>= function
		| Eliom_sessions.Data login		-> Lwt.return (Some login)
		| Eliom_sessions.No_data 
		| Eliom_sessions.Data_session_expired	-> Lwt.return None


(**	Returns the currently logged-in user.  Fails if none.
*)
let get_login sp =
	get_maybe_login sp >>= function
		| Some login	-> Lwt.return login
		| None		-> Lwt.fail No_login


(**	Handler for action "login".
*)
let login_handler sp () (username, (password, remember)) =
	Eliom_sessions.close_session ~sp () >>=
	fun () -> Lwt.catch
		(fun () ->
			Database.get_login username password >>= fun login ->
			let login_group = User.Id.to_string (Login.uid login) in
			Eliom_sessions.set_service_session_group ~set_max:(Some 4) ~sp login_group;
			Eliom_sessions.set_persistent_session_data ~table ~sp login >>= fun () ->
			Eliom_sessions.set_persistent_data_session_group ~set_max:(Some 4) ~sp login_group >>= fun () ->

			(if remember
			then
				begin
				Eliom_sessions.set_service_session_timeout ~sp None;
				Eliom_sessions.set_persistent_data_session_timeout ~sp None >>= fun () ->
				Eliom_sessions.set_persistent_data_session_cookie_exp_date ~sp (Some 3153600000.0)
				end
			else	Lwt.return ()) >>= fun () ->
			Lwt.return [])

		(function _ -> Lwt.return [Invalid_login])


(**	Handler for action "logout".
*)
let logout_handler sp () global =
	Eliom_sessions.close_session ~close_group:global ~sp () >>= fun () ->
	Lwt.return []

