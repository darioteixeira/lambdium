(********************************************************************************)
(*	Database.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open Prelude

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

exception Unexpected_result
exception Unique_violation
exception Unknown_tid
exception Unknown_uid
exception Unknown_sid
exception Unknown_cid
exception Unknown_nick
exception Invalid_password
exception Error of string


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

let process_error = function
	| PGOCaml.PostgreSQL_Error (_, fields) ->
		let exc = match List.assoc 'C' fields with
			| "P0001" ->
				begin match List.assoc 'M' fields with
					| "unknown_uid"      -> Unknown_uid
					| "unknown_nick"     -> Unknown_nick
					| "invalid_password" -> Invalid_password
					| x		     -> Error x
				end
			| "23505" -> Unique_violation
			| x	  -> Error x
		in Lwt.fail exc
	| exc ->
		Lwt.fail exc


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

(********************************************************************************)
(**	{2 Functions returning timezones}					*)
(********************************************************************************)

let get_timezones () =
	assert (Ocsigen_messages.warning "Database.get_timezones ()"; true);
	let get_data dbh =
		try_lwt
			PGSQL (dbh) "nullres=none" "SELECT * FROM get_timezones ()" >>= fun timezones ->
			Lwt.return (List.map Timezone.full_of_tuple timezones)
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


let get_timezone = function
	| None ->
		assert (Ocsigen_messages.warning "Database.get_timezone (UTC)"; true);
		Lwt.return Timezone.utc
	| Some tid ->
		assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_timezone %ld" tid); true);
		let get_data dbh =
			try_lwt
				PGSQL (dbh) "nullres=none" "SELECT * FROM get_timezone ($tid)" >>= function
					| [tz] -> Lwt.return (Timezone.full_of_tuple tz)
					| []   -> Lwt.fail Unknown_tid
					| _    -> Lwt.fail Unexpected_result
			with
				exc -> process_error exc
		in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions returning users}						*)
(********************************************************************************)

let get_users () =
	assert (Ocsigen_messages.warning "Database.get_users ()"; true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=none" "SELECT * FROM get_users ()" >>= fun users ->
			Lwt.return (List.map User.handle_of_tuple users)
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


let get_user uid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_user %ld" uid); true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=f,f,f,t" "SELECT * FROM get_user ($uid)" >>= function
				| [u] -> Lwt.return (User.full_of_tuple u)
				| []  -> Lwt.fail Unknown_uid
				| _   -> Lwt.fail Unexpected_result
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


let get_login_from_credentials nick password =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_login_from_credentials (%s, ***)" nick); true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=f,f,t" "SELECT * FROM get_login_from_credentials ($nick, $password)" >>= function
				| [u] -> Lwt.return (Login.of_tuple u)
				| _   -> Lwt.fail Unexpected_result
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


let get_login_update uid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_login_update %ld" uid); true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=f,f,t" "SELECT * FROM get_login_update ($uid)" >>= function
				| [u] -> Lwt.return (Login.of_tuple u)
				| []  -> Lwt.fail Unknown_uid
				| _   -> Lwt.fail Unexpected_result
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions returning stories}						*)
(********************************************************************************)

let get_stories () =
	assert (Ocsigen_messages.warning "Database.get_stories ()"; true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=none" "SELECT * FROM get_stories ()" >>= fun stories ->
			Lwt.return (List.map Story.blurb_of_tuple stories)
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


let get_user_stories uid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_user_stories %ld" uid); true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=none" "SELECT * FROM get_user_stories ($uid)" >>= fun stories ->
			Lwt.return (List.map Story.handle_of_tuple stories)
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


let get_story sid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_story %ld" sid); true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=none" "SELECT * FROM get_story ($sid)" >>= function
				| [s] -> Lwt.return (Story.full_of_tuple s)
				| []  -> Lwt.fail Unknown_sid
				| _   -> Lwt.fail Unexpected_result
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions returning comments}					*)
(********************************************************************************)

let get_story_comments sid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_story_comments %ld" sid); true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=none" "SELECT * FROM get_story_comments ($sid)" >>= fun comments ->
			Lwt.return (List.map Comment.full_of_tuple comments)
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


let get_user_comments uid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_user_comments %ld" uid); true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=none" "SELECT * FROM get_user_comments ($uid)" >>= fun comments ->
			Lwt.return (List.map Comment.handle_of_tuple comments)
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


let get_comment cid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_comment %ld" cid); true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=none" "SELECT * FROM get_comment ($cid)" >>= function
				| [c] -> Lwt.return (Comment.full_of_tuple c)
				| []  -> Lwt.fail Unknown_cid
				| _   -> Lwt.fail Unexpected_result
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions returning mixed content (this AND that)}			*)
(********************************************************************************)

let get_story_with_comments sid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_story_with_comments %ld" sid); true);
	let get_story dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_story ($sid)" >>= function
			| [s] -> Lwt.return (Story.full_of_tuple s)
			| []  -> Lwt.fail Unknown_sid
			| _   -> Lwt.fail Unexpected_result in
	let get_story_comments dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_story_comments ($sid)" >>= fun comments ->
		Lwt.return (List.map Comment.full_of_tuple comments) in
	let get_data dbh =
		try_lwt
			PGOCaml.begin_work dbh >>= fun () ->
			get_story dbh >>= fun story ->
			get_story_comments dbh >>= fun comments ->
			PGOCaml.commit dbh >>= fun () ->
			Lwt.return (story, comments)
		with
			exc -> PGOCaml.rollback dbh >>= fun () -> process_error exc
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions that add content to the database}				*)
(********************************************************************************)

let add_user user =
	assert (Ocsigen_messages.warning "Database.add_user ()"; true);
	let (nick, fullname, password, maybe_tid) = User.tuple_of_fresh user in
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "SELECT add_user ($nick, $fullname, $password, $?maybe_tid)" >>= function
				| [Some uid] -> Lwt.return uid
				| _	     -> Lwt.fail Unexpected_result
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


let add_story ~output_maker ~side_action story =
	assert (Ocsigen_messages.warning "Database.add_story ()"; true);
	let add dbh =
		let (uid, title, intro_xmrk, intro_src, intro_xdoc, _intro_xout, body_xmrk, body_src, body_xdoc, _body_xout) = Story.tuple_of_fresh story
		and intro_xout = ""
		and body_xout = ""
		in PGSQL(dbh) "SELECT add_story ($uid, $title, $intro_xmrk, $intro_src, $intro_xdoc, $intro_xout, $body_xmrk, $body_src, $body_xdoc, $body_xout)" >>= function
			| [Some sid] -> Lwt.return sid
			| _	     -> Lwt.fail Unexpected_result in
	let edit dbh sid intro_xout body_xout =
		PGSQL(dbh) "SELECT edit_story_output ($sid, $intro_xout, $body_xout)" >>= fun _ ->
		Lwt.return () in
	let get_data dbh =
		try_lwt
			PGOCaml.begin_work dbh >>= fun () ->
			add dbh >>= fun sid ->
			let (intro_xout, body_xout) = output_maker sid in
			edit dbh sid intro_xout body_xout >>= fun () ->
			side_action sid >>= fun () ->
			PGOCaml.commit dbh >>= fun () ->
			Lwt.return sid
		with
			exc -> PGOCaml.rollback dbh >>= fun () -> process_error exc
	in Lwt_pool.use !!pool get_data


let add_comment ~output_maker comment =
	assert (Ocsigen_messages.warning "Database.add_comment ()"; true);
	let add dbh =
		let (sid, uid, title, body_xmrk, body_src, body_xdoc, _body_xout) = Comment.tuple_of_fresh comment
		and body_xout = ""
		in PGSQL(dbh) "SELECT add_comment ($sid, $uid, $title, $body_xmrk, $body_src, $body_xdoc, $body_xout)" >>= function
			| [Some cid] -> Lwt.return cid
			| _	     -> Lwt.fail Unexpected_result in
	let edit dbh cid body_xout =
		PGSQL(dbh) "SELECT edit_comment_output ($cid, $body_xout)" >>= fun _ ->
		Lwt.return () in
	let get_data dbh =
		try_lwt
			PGOCaml.begin_work dbh >>= fun () ->
			add dbh >>= fun cid ->
			let body_xout = output_maker cid in
			edit dbh cid body_xout >>= fun () ->
			PGOCaml.commit dbh >>= fun () ->
			Lwt.return cid
		with
			exc -> PGOCaml.rollback dbh >>= fun () -> process_error exc
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions that edit content from the database}			*)
(********************************************************************************)

let edit_user_credentials user_credentials =
	assert (Ocsigen_messages.warning "Database.edit_user_credentials"; true);
	let (uid, old_password, new_password) = User.tuple_of_changed_credentials user_credentials in
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "SELECT edit_user_credentials ($uid, $old_password, $new_password)" >>= fun _ ->
			Lwt.return ()
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


let edit_user_settings user_settings =
	assert (Ocsigen_messages.warning "Database.edit_user_settings"; true);
	let (uid, fullname, maybe_tid) = User.tuple_of_changed_settings user_settings in
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "SELECT edit_user_settings ($uid, $fullname, $?maybe_tid)" >>= fun _ ->
			Lwt.return ()
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data


(********************************************************************************)
(**	{2 Functions that return the availability of a given element}		*)
(********************************************************************************)

let is_available_nick nick =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.is_available_nick %s" nick); true);
	let get_data dbh =
		try_lwt
			PGSQL(dbh) "nullres=none" "SELECT * FROM is_available_nick ($nick)" >>= function
				| [x]	-> Lwt.return x
				| _	-> Lwt.fail Unexpected_result
		with
			exc -> process_error exc
	in Lwt_pool.use !!pool get_data

