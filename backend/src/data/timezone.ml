(********************************************************************************)
(*	Timezone.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

module Id = Id.Id32

type handle_t =
	< tid: Id.t option >

type full_t =
	< tid: Id.t option;
	name: string >


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


let full_of_tuple (tid, name) =
	make_full tid name


let to_string tz = match tz#tid with
	| None		-> "UTC"
	| Some tz	-> Id.to_string tz


let of_string = function
	| "UTC"		-> make_handle None
	| x		-> make_handle (Some (Id.of_string x))


let param = Eliom_parameters.user_type of_string to_string

