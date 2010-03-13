(********************************************************************************)
(*	Session.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open Prelude


(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Invalid_login
exception No_login


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

(**	The type of the login table.
*)
type 'a login_table_t =
	| Persistent of 'a Eliom_sessions.persistent_table
	| Volatile of 'a Eliom_sessions.volatile_table


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

(**	The [Polytables] key that holds a boolean indicating
	whether or not there was an error during login.
*)
let login_error_key =
	lazy (Polytables.make_key ())


(**	Creates the login table.  By default we use a persistent table, but you
	can choose a volatile table by setting the 'login_table' configuration
	option to 'volatile'.  Volatile tables tend to be faster, since they are
	kept entirely in memory.  On the other hand, persistent tables can survive
	across a restart of the server.
*)
let login_table = lazy
	(let msg = Printf.sprintf "Using %s table for logins"
	in match !Config.login_table with
		| Config.Use_volatile ->
			Ocsigen_messages.warning (msg "volatile");
			Volatile (Eliom_sessions.create_volatile_table ())
		| Config.Use_persistent ->
			Ocsigen_messages.warning (msg "persistent");
			Persistent (Eliom_sessions.create_persistent_table "login_table"))


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

(**	Initialises session handling.
*)
let init () =
	ignore !!login_error_key;
	ignore !!login_table


(**	Has there been an error during a login attempt?
*)
let get_login_error sp =
	try
		Polytables.get ~table:(Eliom_sessions.get_request_cache sp) ~key:!!login_error_key
	with
		Not_found -> false


(**	Returns the currently logged-in user, if any.
*)
let get_maybe_login sp =
	(match !!login_table with
		| Persistent table ->
			Eliom_sessions.get_persistent_session_data ~table ~sp ()
		| Volatile table ->
			Lwt.return (Eliom_sessions.get_volatile_session_data table sp ())) >>= fun login_data ->
	match login_data with
		| Eliom_sessions.Data login		-> Lwt.return (Some login)
		| Eliom_sessions.No_data 
		| Eliom_sessions.Data_session_expired	-> Lwt.return None


(**	Returns the currently logged-in user.  Fails if none.
*)
let get_login sp =
	get_maybe_login sp >>= function
		| Some login -> Lwt.return login
		| None	     -> Lwt.fail No_login


(**	Handler for login action.
*)
let login_handler sp () (username, (password, remember)) =
	Eliom_sessions.close_session ~sp () >>= fun () ->
	Database.get_login_from_credentials username password >>= function
		| Some login ->
			let login_group = User.Id.to_string (Login.uid login) in
			Eliom_sessions.set_service_session_group ~set_max:4 ~sp login_group;

			(match !!login_table with
				| Persistent table ->
					Eliom_sessions.set_persistent_session_data ~table ~sp login >>= fun () ->
					Eliom_sessions.set_persistent_data_session_group ~set_max:(Some 4) ~sp login_group
				| Volatile table ->
					Eliom_sessions.set_volatile_session_data ~table ~sp login;
					Eliom_sessions.set_volatile_data_session_group ~set_max:4 ~sp login_group;
					Lwt.return ()) >>= fun () ->
	
			(if remember
			then begin
				Eliom_sessions.set_service_session_timeout ~sp None;
				Eliom_sessions.set_persistent_data_session_timeout ~sp None >>= fun () ->
				Eliom_sessions.set_persistent_data_session_cookie_exp_date ~sp (Some 3153600000.0)
			end
			else begin
				Lwt.return ()
			end)
		| None ->
			Polytables.set ~table:(Eliom_sessions.get_request_cache sp) ~key:!!login_error_key ~value:true;
			Lwt.return ()


(**	Handler for logout action.
*)
let logout_handler sp () global =
	Eliom_sessions.close_session ~close_group:global ~sp ()


(**	Update login.  This function should be invoked upon
	a change in the user's settings stored in the login.
*)
let update_login sp login =
	Database.get_login_update (Login.uid login) >>= fun new_login ->
	match !!login_table with
		| Persistent table -> Eliom_sessions.set_persistent_session_data ~table ~sp new_login
		| Volatile table   -> Lwt.return (Eliom_sessions.set_volatile_session_data ~table ~sp new_login)

