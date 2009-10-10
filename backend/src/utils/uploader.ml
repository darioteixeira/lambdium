(********************************************************************************)
(*	Uploader.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Unix
open Lwt
open Common


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

module Fileset = Set.Make (struct type t = string let compare = Pervasives.compare end)


type t =
	{
	token: ResourceGC.token_t;
	tmpdir: string;
	mutable files: Fileset.t;
	}


type status_t = (string * bool) list


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

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
	let dh = Unix.opendir dir in
	let rec del_next dh =
		let name = dir ^ "/" ^ (Unix.readdir dh) in
		if (Unix.stat name).st_kind == S_REG then Unix.unlink (name) else ();
		Lwt_unix.yield () >>= fun () ->
		del_next dh
	in try
		del_next dh
	with
		End_of_file ->
			Unix.closedir dh;
			Unix.rmdir dir;
			Lwt.return ()


let pool =
	let timeout = lazy (Eliom_sessions.get_global_service_session_timeout ())
	in lazy (ResourceGC.make_pool ~name:"Uploader" ~capacity:!Config.uploader_global_capacity ~period:!Config.uploader_period ~default_timeout:!!timeout)


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let init () =
	ignore !!pool


let cleaner uuid =
	Ocsigen_messages.warning (Printf.sprintf "Cleaner called for UUID %s!" uuid);
	Unix.rmdir (!Config.uploader_limbo_dir ^ "/" ^ uuid)


let request ~sp ~login =
	(* let timeout = Some (Eliom_sessions.get_service_session_timeout ~sp ()) in *)
	let timeout = Some (Some 120.0) in
	let token = ResourceGC.request_token ~group:(Login.nick login, !Config.uploader_group_capacity) ?timeout !!pool cleaner in
	let tmpdir = !Config.uploader_limbo_dir ^ "/" ^ (ResourceGC.uuid_of_token token) in
	let () = Unix.mkdir tmpdir 0o750
	in {token = token; tmpdir = tmpdir; files = Fileset.empty;}


let refresh uploader =
	ResourceGC.refresh_token uploader.token


let discard uploader =
	ResourceGC.retire_token uploader.token;
	deltree uploader.tmpdir


let commit destination uploader =
	ResourceGC.retire_token uploader.token;
	Unix.mkdir destination 0o750;
	let copy file =
		let src = uploader.tmpdir ^ "/" ^ file
		and dst = destination ^ "/" ^ file
		in smartcp src dst in
	Lwt_util.iter_serial copy (Fileset.elements uploader.files)


let add_files uploader aliases submissions =
	let add alias file = match Eliom_sessions.get_filesize file with
		| 0L ->
			Lwt.return ()
		| _ ->
			let tmpname = Eliom_sessions.get_tmp_filename file in
			let newname = uploader.tmpdir ^ "/" ^ alias in
			smartcp tmpname newname >>= fun () ->
			uploader.files <- Fileset.add alias uploader.files;
			Lwt.return () in
	ignore (List.rev_map2 add aliases submissions);
	List.for_all (fun alias -> Fileset.mem alias uploader.files) aliases


let get_status uploader aliases =
	List.map (fun alias -> (alias, Fileset.mem alias uploader.files)) aliases

