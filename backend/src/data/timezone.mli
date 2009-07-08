(********************************************************************************)
(*	Timezone.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

module Id: Id.ID32

type handle_t =
	< tid: Id.t option >

type full_t =
	< tid: Id.t option;
	name: string;
	abbrev: string;
	offset: float;
	dst: bool >

val utc: full_t

val make_handle:
	Id.t option ->
	handle_t

val make_full:
	Id.t -> string -> string -> float -> bool ->
	full_t

val full_of_tuple:
	Id.t * string * string * float * bool ->
	full_t

val to_string:
	< tid: Id.t option; .. > ->
	string

val of_string:
	string ->
	< tid: Id.t option >

val param:
	string ->
	(handle_t, [ `WithoutSuffix ], [ `One of handle_t ] Eliom_parameters.param_name) Eliom_parameters.params_type

