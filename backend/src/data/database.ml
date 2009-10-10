(********************************************************************************)
(*	Database.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open Common

module PGOCaml = PGOCaml_generic.Make (struct include Lwt include Lwt_chan end)


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

let pool =
	let connect () = PGOCaml.connect
		?host:!Config.pghost
		?port:!Config.pgport
		?user:!Config.pguser
		?password:!Config.pgpassword
		?database:!Config.pgdatabase
		?unix_domain_socket_dir:!Config.pgsocketdir
	in lazy (Lwt_pool.create 8 (connect ()))


(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Database_error

exception Cannot_get_timezone
exception Cannot_get_user
exception Cannot_get_story
exception Cannot_get_comment

exception Cannot_add_user
exception Cannot_add_story
exception Cannot_add_comment

exception Cannot_edit_user_credentials
exception Cannot_edit_user_settings

exception Cannot_get_nick_availability


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

(********************************************************************************)
(**	{2 Functions returning timezones}					*)
(********************************************************************************)

let get_timezones () =
	assert (Ocsigen_messages.warning "Database.get_timezones ()"; true);
	let get_data dbh =
		PGSQL (dbh) "nullres=none" "SELECT * FROM get_timezones ()" >>= fun timezones ->
		Lwt.return (List.map Timezone.full_of_tuple timezones)
	in Lwt_pool.use !!pool get_data 


let get_timezone = function
	| None ->
		assert (Ocsigen_messages.warning "Database.get_timezone (UTC)"; true);
		Lwt.return Timezone.utc
	| Some tid ->
		assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_timezone %ld" tid); true);
		let get_data dbh =
			PGSQL (dbh) "nullres=none" "SELECT * FROM get_timezone ($tid)" >>= function
				| [tz]	-> Lwt.return (Timezone.full_of_tuple tz)
				| _	-> Lwt.fail Cannot_get_timezone
		in Lwt_pool.use !!pool get_data 


(********************************************************************************)
(**	{2 Functions returning users}						*)
(********************************************************************************)

let get_users () =
	assert (Ocsigen_messages.warning "Database.get_users ()"; true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_users ()" >>= fun users ->
		Lwt.return (List.map User.handle_of_tuple users)
	in Lwt_pool.use !!pool get_data


let get_user uid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_user %ld" uid); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=f,f,f,t" "SELECT * FROM get_user ($uid)" >>= function
			| [u]	-> Lwt.return (User.full_of_tuple u)
			| _	-> Lwt.fail Cannot_get_user
	in Lwt_pool.use !!pool get_data


let get_login_from_credentials nick password =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_login_from_credentials (%s, ***)" nick); true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=f,f,t" "SELECT * FROM get_login_from_credentials ($nick, $password)" >>= function
				| [u]	-> Lwt.return (Some (Login.of_tuple u))
				| _	-> Lwt.fail Database_error
		with 
			| PGOCaml.PostgreSQL_Error _ -> Lwt.return None
	in Lwt_pool.use !!pool get_data


let get_login_update uid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_login_update %ld" uid); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=f,f,t" "SELECT * FROM get_login_update ($uid)" >>= function
			| [u]	-> Lwt.return (Login.of_tuple u)
			| _	-> Lwt.fail Database_error
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions returning stories}						*)
(********************************************************************************)

let get_stories () =
	assert (Ocsigen_messages.warning "Database.get_stories ()"; true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_stories ()" >>= fun stories ->
		Lwt.return (List.map Story.blurb_of_tuple stories)
	in Lwt_pool.use !!pool get_data


let get_user_stories uid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_user_stories %ld" uid); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_user_stories ($uid)" >>= fun stories ->
		Lwt.return (List.map Story.handle_of_tuple stories)
	in Lwt_pool.use !!pool get_data


let get_story sid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_story %ld" sid); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_story ($sid)" >>= function
			| [s]	-> Lwt.return (Story.full_of_tuple s)
			| _	-> Lwt.fail Cannot_get_story
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions returning comments}					*)
(********************************************************************************)

let get_story_comments sid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_story_comments %ld" sid); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_story_comments ($sid)" >>= fun comments ->
		Lwt.return (List.map Comment.full_of_tuple comments)
	in Lwt_pool.use !!pool get_data


let get_user_comments uid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_user_comments %ld" uid); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_user_comments ($uid)" >>= fun comments ->
		Lwt.return (List.map Comment.handle_of_tuple comments)
	in Lwt_pool.use !!pool get_data


let get_comment cid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database#get_comment %ld" cid); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_comment ($cid)" >>= function
			| [c]	-> Lwt.return (Comment.full_of_tuple c)
			| _	-> Lwt.fail Cannot_get_comment
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions returning mixed content (this AND that)}			*)
(********************************************************************************)

let get_story_with_comments sid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_story_with_comments %ld" sid); true);
	let get_data dbh =
		try_lwt
			PGOCaml.begin_work dbh >>= fun () ->
			get_story sid >>= fun story ->
			get_story_comments sid >>= fun comments ->
			PGOCaml.commit dbh >>= fun () ->
			Lwt.return (story, comments)
		with
			| exc -> PGOCaml.rollback dbh >>= fun () -> Lwt.fail exc
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions that add content to the database}				*)
(********************************************************************************)

let add_user user =
	assert (Ocsigen_messages.warning "Database.add_user ()"; true);
	let (nick, fullname, password, maybe_tid) = User.tuple_of_fresh user in
	let get_data dbh =
		PGSQL(dbh) "SELECT add_user ($nick, $fullname, $password, $?maybe_tid)" >>= function
			| [Some uid] -> Lwt.return uid
			| _	     -> Lwt.fail Cannot_add_user
	in Lwt_pool.use !!pool get_data


let add_story story =
	assert (Ocsigen_messages.warning "Database.add_story ()"; true);
	let (uid, title, intro_src, intro_pickle, intro_out, body_src, body_pickle, body_out) = Story.tuple_of_fresh story in
	let get_data dbh =
		PGSQL(dbh) "SELECT add_story ($uid, $title, $intro_src, $intro_pickle, $intro_out, $body_src, $body_pickle, $body_out)" >>= function
			| [Some sid] -> Lwt.return sid
			| _	     -> Lwt.fail Cannot_add_story
	in Lwt_pool.use !!pool get_data


let add_comment comment =
	assert (Ocsigen_messages.warning "Database.add_comment ()"; true);
	let (sid, uid, title, body_src, body_pickle, body_out) = Comment.tuple_of_fresh comment in
	let get_data dbh =
		PGSQL(dbh) "SELECT add_comment ($sid, $uid, $title, $body_src, $body_pickle, $body_out)" >>= function
			| [Some cid] -> Lwt.return cid
			| _	     -> Lwt.fail Cannot_add_comment
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions that edit content from the database}			*)
(********************************************************************************)

let edit_user_credentials user_credentials =
	assert (Ocsigen_messages.warning "Database.edit_user_credentials"; true);
	let (uid, old_password, new_password) = User.tuple_of_changed_credentials user_credentials in
	let get_data dbh =
		PGSQL(dbh) "SELECT edit_user_credentials ($uid, $old_password, $new_password)" >>= fun _ ->
		Lwt.return ()
	in Lwt_pool.use !!pool get_data


let edit_user_settings user_settings =
	assert (Ocsigen_messages.warning "Database.edit_user_settings"; true);
	let (uid, fullname, maybe_tid) = User.tuple_of_changed_settings user_settings in
	let get_data dbh =
		PGSQL(dbh) "SELECT edit_user_settings ($uid, $fullname, $?maybe_tid)" >>= fun _ ->
		Lwt.return ()
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions that return the availability of a given element}		*)
(********************************************************************************)

let is_available_nick nick =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.is_available_nick %s" nick); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM is_available_nick ($nick)" >>= function
			| [x]	-> Lwt.return x
			| _	-> Lwt.fail Cannot_get_nick_availability
	in Lwt_pool.use !!pool get_data

