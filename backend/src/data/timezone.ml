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
	name: string;
	abbrev: string;
	offset: float;
	dst: bool >


let utc =
	object
		method tid = None
		method name = "Coordinated Universal Time"
		method abbrev = "UTC"
		method offset = 0.0
		method dst = false
	end


let make_handle tid =
	object
		method tid = tid
	end


let make_full tid name abbrev offset dst =
	object
		method tid = Some tid
		method name = name
		method abbrev = abbrev
		method offset = offset
		method dst = dst
	end


let full_of_tuple (tid, name, abbrev, offset, dst) =
	make_full tid name abbrev offset dst


let to_string tz = match tz#tid with
	| None		-> "UTC"
	| Some tz	-> Id.to_string tz


let of_string = function
	| "UTC"		-> make_handle None
	| x		-> make_handle (Some (Id.of_string x))


let param = Eliom_parameters.user_type of_string to_string

