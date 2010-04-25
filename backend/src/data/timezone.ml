(********************************************************************************)
(*	Timezone.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open XHTML.M


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

module Id = Id.Id32

type handle_t = < tid: Id.t option >
type full_t = < tid: Id.t option; name: string >


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

(********************************************************************************)
(**	{2 Constructors}							*)
(********************************************************************************)

let utc =
	object
		method tid = None
		method name = "Coordinated Universal Time"
	end


let make_handle tid =
	object
		method tid = tid
	end


let make_full tid name =
	object
		method tid = Some tid
		method name = name
	end


(********************************************************************************)
(**	{2 (De)serialisers}							*)
(********************************************************************************)

let to_string tz = match tz#tid with
	| None		-> "UTC"
	| Some tz	-> Id.to_string tz


let of_string = function
	| "UTC"		-> make_handle None
	| x		-> make_handle (Some (Id.of_string x))


(********************************************************************************)
(**	{2 Output-related functions}						*)
(********************************************************************************)

let output_full tz =
	dl ~a:[a_class ["timezone"]]
		(dt [pcdata "Name:"])
		[
		dd [pcdata tz#name];
		]


(********************************************************************************)
(**	{2 Input-related functions}						*)
(********************************************************************************)

let param = Eliom_parameters.user_type ~of_string ~to_string


let select ?a ~name ?value timezones =
	let option_of_tz tz =
		let is_selected = match value with
			| Some v -> tz#tid = v#tid
			| None	 -> tz#tid = utc#tid
		in Eliom_predefmod.Xhtml.Option ([], make_handle tz#tid, Some (pcdata tz#name), is_selected)
	in Eliom_predefmod.Xhtml.user_type_select
		to_string
		?a
		~name
		(option_of_tz utc)
		(List.map option_of_tz timezones)

