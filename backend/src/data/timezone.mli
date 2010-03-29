(********************************************************************************)
(*	Timezone.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

module Id: Id.ID32

type handle_t = < tid: Id.t option >
type full_t = < tid: Id.t option; name: string >


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

(********************************************************************************)
(**	{2 Constructors}							*)
(********************************************************************************)

val utc: full_t
val make_handle: Id.t option -> handle_t
val make_full: Id.t -> string -> full_t
val full_of_tuple: Id.t * string -> full_t


(********************************************************************************)
(**	{2 (De)serialisers}							*)
(********************************************************************************)

val to_string: handle_t -> string
val of_string: string -> handle_t


(********************************************************************************)
(**	{2 Output-related functions}						*)
(********************************************************************************)

val output_full:
	full_t ->
	[> `Dl ] XHTML.M.elt


(********************************************************************************)
(**	{2 Input-related functions}						*)
(********************************************************************************)

val param:
	string ->
	(handle_t, [ `WithoutSuffix ], [ `One of handle_t ] Eliom_parameters.param_name) Eliom_parameters.params_type

val select:
	?a:Xhtmltypes.select_attrib XHTML.M.attrib list ->
	name:[< `One of handle_t ] Eliom_parameters.param_name ->
	?value:handle_t ->
	full_t list ->
	[> Xhtmltypes.select ] XHTML.M.elt

