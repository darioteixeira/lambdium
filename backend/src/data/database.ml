(********************************************************************************)
(*	Database.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt

module PGOCaml = PGOCaml_generic.Make (struct include Lwt include Lwt_chan end)


(********************************************************************************)
(**	{2 Private functions}							*)
(********************************************************************************)

let pool = Lwt_pool.create 8 PGOCaml.connect


(********************************************************************************)
(**	{2 Exceptions}								*)
(********************************************************************************)

exception Cannot_get_timezone
exception Cannot_get_user
exception Cannot_get_login
exception Cannot_get_story
exception Cannot_get_comment

exception Cannot_add_user
exception Cannot_add_story
exception Cannot_add_comment

exception Cannot_edit_user_credentials
exception Cannot_edit_user_settings

exception Cannot_get_nick_availability


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

(********************************************************************************)
(**	{3 Functions returning timezones}					*)
(********************************************************************************)

let get_timezones () =
	assert (Ocsigen_messages.warning "Database.get_timezones ()"; true);
	let get_data dbh =
		PGSQL (dbh) "nullres=none" "SELECT * FROM get_timezones ()" >>= fun timezones ->
		Lwt.return (List.map Timezone.full_of_tuple timezones)
	in Lwt_pool.use pool get_data 


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
		in Lwt_pool.use pool get_data 


(********************************************************************************)
(**	{3 Functions returning users}						*)
(********************************************************************************)

let get_users () =
	assert (Ocsigen_messages.warning "Database.get_users ()"; true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_users ()" >>= fun users ->
		Lwt.return (List.map User.handle_of_tuple users)
	in Lwt_pool.use pool get_data


let get_user uid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_user %ld" uid); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=f,f,f,t" "SELECT * FROM get_user ($uid)" >>= function
			| [u]	-> Lwt.return (User.full_of_tuple u)
			| _	-> Lwt.fail Cannot_get_user
	in Lwt_pool.use pool get_data


let get_login nick password =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_login (%s, %s)" nick password); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_login ($nick, $password)" >>= function
			| [u]	-> Lwt.return (Login.of_tuple u)
			| _	-> Lwt.fail Cannot_get_login
	in Lwt_pool.use pool get_data


(********************************************************************************)
(**	{3 Functions returning stories}						*)
(********************************************************************************)

let get_stories maybe_login =
	assert (Ocsigen_messages.warning "Database.get_stories ()"; true);
	let client = Login.maybe_uid maybe_login in
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_stories ($?client)" >>= fun stories ->
		Lwt.return (List.map Story.blurb_of_tuple stories)
	in Lwt_pool.use pool get_data


let get_user_stories uid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_user_stories %ld" uid); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_user_stories ($uid)" >>= fun stories ->
		Lwt.return (List.map Story.handle_of_tuple stories)
	in Lwt_pool.use pool get_data


let get_story maybe_login sid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_story %ld" sid); true);
	let client = Login.maybe_uid maybe_login in
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_story ($sid, $?client)" >>= function
			| [s]	-> Lwt.return (Story.full_of_tuple s)
			| _	-> Lwt.fail Cannot_get_story
	in Lwt_pool.use pool get_data


(********************************************************************************)
(**	{3 Functions returning comments}					*)
(********************************************************************************)

let get_story_comments maybe_login sid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_story_comments %ld" sid); true);
	let client = Login.maybe_uid maybe_login in
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_story_comments ($sid, $?client)" >>= fun comments ->
		Lwt.return (List.map Comment.full_of_tuple comments)
	in Lwt_pool.use pool get_data


let get_user_comments uid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_user_comments %ld" uid); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_user_comments ($uid)" >>= fun comments ->
		Lwt.return (List.map Comment.handle_of_tuple comments)
	in Lwt_pool.use pool get_data


let get_comment maybe_login cid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database#get_comment %ld" cid); true);
	let client = Login.maybe_uid maybe_login in
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM get_comment ($cid, $?client)" >>= function
			| [c]	-> Lwt.return (Comment.full_of_tuple c)
			| _	-> Lwt.fail Cannot_get_comment
	in Lwt_pool.use pool get_data


(********************************************************************************)
(**	{3 Functions returning mixed content (this AND that)}			*)
(********************************************************************************)

(**	Note: the reason why these special methods should be used (instead of
	simply calling the individual methods separately) is to ensure that we
	get a consistent snapshot of the database at a point in time.  Note that
	we use the transaction mechanisms (PGOCaml.begin_work et al) for that.
*)

let get_story_with_comments maybe_login sid =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.get_story_with_comments %ld" sid); true);
	let get_data dbh =
		Lwt.catch
			(fun () ->
				PGOCaml.begin_work dbh >>= fun () ->
				get_story maybe_login sid >>= fun story ->
				get_story_comments maybe_login sid >>= fun comments ->
				PGOCaml.commit dbh >>= fun () ->
				Lwt.return (story, comments))
			(function exc ->
				PGOCaml.rollback dbh >>= fun () ->
				Lwt.fail exc)
	in Lwt_pool.use pool get_data


(********************************************************************************)
(**	{3 Functions that add content to the database}				*)
(********************************************************************************)

let add_user user =
	assert (Ocsigen_messages.warning "Database.add_user ()"; true);
	let (nick, fullname, password, maybe_tid) = User.tuple_of_fresh user in
	let get_data dbh =
		PGSQL(dbh) "SELECT add_user ($nick, $fullname, $password, $?maybe_tid)" >>= fun _ ->
		Lwt.return ()
	in Lwt_pool.use pool get_data


let add_story story =
	assert (Ocsigen_messages.warning "Database.add_story ()"; true);
	let (uid, title, intro_src, intro_pickle, intro_out, body_src, body_pickle, body_out) = Story.tuple_of_fresh story in
	let get_data dbh =
		PGSQL(dbh) "SELECT add_story ($uid, $title, $intro_src, $intro_pickle, $intro_out, $body_src, $body_pickle, $body_out)" >>= fun _ ->
		Lwt.return ()
	in Lwt_pool.use pool get_data


let add_comment comment =
	assert (Ocsigen_messages.warning "Database.add_comment ()"; true);
	let (sid, uid, title, body_src, body_pickle, body_out) = Comment.tuple_of_fresh comment in
	let get_data dbh =
		PGSQL(dbh) "SELECT add_comment ($sid, $uid, $title, $body_src, $body_pickle, $body_out)" >>= fun _ ->
		Lwt.return ()
	in Lwt_pool.use pool get_data


(********************************************************************************)
(**	{3 Functions that edit content from the database}			*)
(********************************************************************************)

let edit_user_credentials user_credentials =
	assert (Ocsigen_messages.warning "Database.edit_user_credentials ()"; true);
	let (uid, old_password, new_password) = User.tuple_of_changed_credentials user_credentials in
	let get_data dbh =
		PGSQL(dbh) "SELECT edit_user_credentials ($uid, $old_password, $new_password)" >>= fun _ ->
		Lwt.return ()
	in Lwt_pool.use pool get_data


let edit_user_settings user_settings =
	assert (Ocsigen_messages.warning "Database.edit_user_settings %ld"; true);
	let (uid, fullname, maybe_tid) = User.tuple_of_changed_settings user_settings in
	let get_data dbh =
		PGSQL(dbh) "SELECT edit_user_settings ($uid, $fullname, $?maybe_tid)" >>= fun _ ->
		Lwt.return ()
	in Lwt_pool.use pool get_data


(********************************************************************************)
(**	{3 Functions that return the availability of a given element}		*)
(********************************************************************************)

let is_available_nick nick =
	assert (Ocsigen_messages.warning (Printf.sprintf "Database.is_available_nick %s" nick); true);
	let get_data dbh =
		PGSQL(dbh) "nullres=none" "SELECT * FROM is_available_nick ($nick)" >>= function
			| [x]	-> Lwt.return x
			| _	-> Lwt.fail Cannot_get_nick_availability
	in Lwt_pool.use pool get_data

