(********************************************************************************)
(*	Uploader.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Common


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type t = ResourceGC.token_t


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let pool =
	let timeout = lazy (Eliom_sessions.get_global_service_session_timeout ())
	in lazy (ResourceGC.make_pool ~name:"Uploader" ~capacity:20 ~period:10 ~default_timeout:!!timeout)


let init () =
	ignore !!pool


let cleaner uuid =
	Ocsigen_messages.warning (Printf.sprintf "Cleaner called for UUID %s!" uuid);
	Unix.rmdir ("/tmp/" ^ uuid)


let request ~sp ~login =
	let timeout = Some (Eliom_sessions.get_service_session_timeout ~sp ()) in
	let timeout = Some (Some 60.0) in
	let token = ResourceGC.request_token ~group:(Login.nick login, 3) ?timeout !!pool cleaner in
	let uuid = ResourceGC.uuid_of_token token in
	let () = Unix.mkdir ("/tmp/" ^ uuid) 0o640
	in token


let refresh token =
	ResourceGC.refresh_token token


let retire token =
	ResourceGC.retire_token token

