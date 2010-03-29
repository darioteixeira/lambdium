(********************************************************************************)
(*	Document.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Prelude


(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Invalid_manuscript of [ `Div ] XHTML.M.elt
exception Invalid_composition of [ `Div ] XHTML.M.elt


(********************************************************************************)
(**	{1 Modules}								*)
(********************************************************************************)

module Markup:
sig
	include Lambdoc_proxy.Markup.S

	val of_string: string -> t
	val to_string: t -> string

	val param:
		string ->
		(t, [ `WithoutSuffix ], [ `One of t ] Eliom_parameters.param_name) Eliom_parameters.params_type

	val select:
		?a:Xhtmltypes.select_attrib XHTML.M.attrib list ->
		name:[< `One of t ] Eliom_parameters.param_name ->
		?value:t ->
		unit ->
		[> Xhtmltypes.select ] XHTML.M.elt
end


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type source_t = string
type output_t = [ `Div ] XHTML.M.elt
type manuscript_t
type composition_t


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

val dummy_output: [> `Div ] XHTML.M.elt

val output_of_manuscript: sp:Eliom_sessions.server_params -> path:string list -> manuscript_t -> [> `Div ] XHTML.M.elt
val output_of_composition: sp:Eliom_sessions.server_params -> path:string list -> composition_t -> [> `Div ] XHTML.M.elt

val parse_manuscript: markup:Markup.t -> source_t -> (manuscript_t * string list, [> `Div ] XHTML.M.elt) result_t Lwt.t
val parse_composition: markup:Markup.t -> source_t -> (composition_t * string list, [> `Div ] XHTML.M.elt) result_t Lwt.t

val parse_manuscript_exc: markup:Markup.t -> source_t -> (manuscript_t * string list) Lwt.t
val parse_composition_exc: markup:Markup.t -> source_t -> (composition_t * string list) Lwt.t

val serialise_manuscript: manuscript_t -> string
val serialise_composition: composition_t -> string

val serialise_output: output_t -> string
val deserialise_output: string -> [> `Div ] XHTML.M.elt

