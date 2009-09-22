(********************************************************************************)
(*	Timestamp.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open CalendarLib


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type t = Calendar.t


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

external sprint_timestamp: float -> string = "sprint_timestamp"


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let soon = Calendar.now


let make_localiser ?localiser maybe_login =
	match localiser with
		| Some localiser ->
			localiser
		| None ->
			let default_tz = "UTC" in
			let tz = match maybe_login with
				| Some login -> (match Login.tz login with Some tz -> tz | None -> default_tz)
				| None	     -> default_tz in
			let () = Unix.putenv "TZ" tz
			in fun utc_cal -> sprint_timestamp (Calendar.to_unixfloat utc_cal)

