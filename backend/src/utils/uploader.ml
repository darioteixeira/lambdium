(********************************************************************************)
(*	Uploader.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Unix
open Lwt
open Prelude


(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception User_pool_exhausted
exception Global_pool_exhausted
exception Invalid_token


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

module Fileset = Set.Make (struct type t = string let compare = Pervasives.compare end)
module Uuidset = Set.Make (struct type t = string let compare = Pervasives.compare end)


type token_t =
	{
	owner: User.Id.t;
	uuid: string;
	tmp_dir: string;
	mutable files: Fileset.t;
	}


type status_t = (string * bool) list


type pool_t =
	{
	usage: (User.Id.t, int) Hashtbl.t;
	mutable uuids: Uuidset.t;
	}


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

let pool = lazy
	{
	usage = Hashtbl.create !Config.global_upload_limit;
	uuids = Uuidset.empty;
	}


let smartcp srcname dstname =
	(try Unix.unlink dstname with _ -> ());
	try
		Unix.link srcname dstname;
		Lwt.return ()
	with
		Unix.Unix_error (Unix.EXDEV, _, _) ->
			let srcchan = Lwt_io.open_file Lwt_io.input srcname
			and dstchan = Lwt_io.open_file Lwt_io.output dstname in
			Lwt_io.read srcchan >>= fun data ->
			Lwt_io.write dstchan data


let deltree dir =
	Ocsigen_messages.warning (Printf.sprintf "Called deltree for directory %s" dir);
	let dh = Unix.opendir dir in
	let rec del_next dh =
		let name = dir ^ "/" ^ (Unix.readdir dh) in
		if (Unix.stat name).st_kind == S_REG then Unix.unlink (name) else ();
		del_next dh
	in try
		del_next dh
	with
		End_of_file ->
			Unix.closedir dh;
			Unix.rmdir dir


let remove_references token =
	!!pool.uuids <- Uuidset.remove token.uuid !!pool.uuids;
	let new_count = (Hashtbl.find !!pool.usage token.owner) - 1 in
	if new_count = 0
	then Hashtbl.remove !!pool.usage token.owner
	else Hashtbl.replace !!pool.usage token.owner new_count


let discard_aux ~manual token =
	Ocsigen_messages.warning (Printf.sprintf "Called discard for token %s with manual=%B" token.uuid manual);
	if Uuidset.mem token.uuid !!pool.uuids
	then begin
		Ocsigen_messages.warning (Printf.sprintf "Actually discarding token %s" token.uuid);
		remove_references token;
		deltree token.tmp_dir;
		Lwt.return ()
	end
	else
		if manual
		then Lwt.fail Invalid_token
		else Lwt.return ()


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let init () =
	ignore !!pool


let discard =
	discard_aux ~manual:true


let request ~sp ~uid ~limit =
	let current = try Hashtbl.find !!pool.usage uid with Not_found -> 0 in
	if current >= limit
	then
		raise User_pool_exhausted
	else
		if Uuidset.cardinal !!pool.uuids >= !Config.global_upload_limit
		then
			raise Global_pool_exhausted
		else
			let now = Unix.gettimeofday () in
			let uuid = Printf.sprintf "%ld-%Lx-%Lx" uid (Int64.bits_of_float now) (Random.int64 Int64.max_int) in
			let tmp_dir = !Config.static_dir ^ "/" ^ !Config.limbo_dir ^ "/" ^ uuid in
			let () = Unix.mkdir tmp_dir 0o750 in
			let token =
				{
				owner = uid;
				uuid = uuid;
				tmp_dir = tmp_dir;
				files = Fileset.empty;
				}
			in	Hashtbl.replace !!pool.usage uid (current + 1);
				!!pool.uuids <- Uuidset.add uuid !!pool.uuids;
				Lwt_gc.finalise (discard_aux ~manual:false) token;
				Ocsigen_messages.warning (Printf.sprintf "Called request for token %s" token.uuid);
				Lwt.return token


let commit ~path token =
	Ocsigen_messages.warning (Printf.sprintf "Called commit for token %s" token.uuid);
	if Uuidset.mem token.uuid !!pool.uuids
	then begin
		Ocsigen_messages.warning (Printf.sprintf "Actually committing token %s" token.uuid);
		let full_path = !Config.static_dir :: path in
		let dst_dir = (List.hd full_path) ^ (List.fold_left (fun acc x -> acc ^ "/" ^ x) "" (List.tl full_path)) in
		Ocsigen_messages.warning (Printf.sprintf "Destination dir: %s" dst_dir);
		Unix.mkdir dst_dir 0o750;
		let copy file =
			let src = token.tmp_dir ^ "/" ^ file
			and dst = dst_dir ^ "/" ^ file
			in smartcp src dst in
		Lwt_util.iter_serial copy (Fileset.elements token.files) >>= fun () ->
		remove_references token;
		deltree token.tmp_dir;
		Lwt.return ()
	end
	else
		Lwt.fail Invalid_token


let add_files aliases submissions token =
	let add (alias, file) = match Eliom_sessions.get_filesize file with
		| 0L ->
			Lwt.return ()
		| _ ->
			let tmpname = Eliom_sessions.get_tmp_filename file in
			let newname = token.tmp_dir ^ "/" ^ alias in
			smartcp tmpname newname >>= fun () ->
			token.files <- Fileset.add alias token.files;
			Lwt.return ()
	in	Lwt_util.iter_serial add (List.map2 (fun x y -> (x, y)) aliases submissions) >>= fun () ->
		Lwt.return (List.for_all (fun alias -> Fileset.mem alias token.files) aliases)


let get_status aliases token =
	List.map (fun alias -> (alias, Fileset.mem alias token.files)) aliases


let get_path token =
	[!Config.limbo_dir; token.uuid]

