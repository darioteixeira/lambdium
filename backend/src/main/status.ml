(********************************************************************************)
(*	Status.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type stat_t =
	| Success
	| Warning
	| Failure

type entry_t = stat_t * [XHTML.M.inline | `PCDATA ] XHTML.M.elt list * XHTML.M.block XHTML.M.elt list

type t = entry_t list


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

let key = Polytables.make_key ()

let set ~sp (entry : entry_t) =
	let table = Eliom_sessions.get_request_cache sp in
	let current = try Polytables.get ~table ~key with Not_found -> []
	in Polytables.set ~table ~key ~value:(entry :: current)


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let string_of_stat = function
	| Success -> "success"
	| Warning -> "warning"
	| Failure -> "failure"


let get sp =
	try Polytables.get ~table:(Eliom_sessions.get_request_cache sp) ~key
	with Not_found -> []


let success ~sp head body = set ~sp (Success, head, body)
let warning ~sp head body = set ~sp (Warning, head, body)
let failure ~sp head body = set ~sp (Failure, head, body)

