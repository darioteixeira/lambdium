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
	in lazy (ResourceGC.make_pool ~name:"Uploader" ~capacity:20 ~period:600 ~default_timeout:!!timeout)


let init () =
	ignore !!pool


let request ~sp ~login =
	let timeout = Some (Eliom_sessions.get_service_session_timeout ~sp ()) in
	let cleaner () = Ocsigen_messages.warning "Cleaner called!"
	in ResourceGC.request_token ~group:(Login.nick login, 3) ?timeout !!pool cleaner


let retire uploads =
	ResourceGC.retire_token !!pool uploads


let refresh uploads =
	ResourceGC.refresh_token !!pool uploads

