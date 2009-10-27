(********************************************************************************)
(*	Document.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Prelude


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

val output_of_manuscript: (string -> XHTML.M.uri) -> manuscript_t -> [> `Div ] XHTML.M.elt
val output_of_composition: (string -> XHTML.M.uri) -> composition_t -> [> `Div ] XHTML.M.elt

val output_of_string: string -> [> `Div ] XHTML.M.elt
val string_of_output: output_t -> string

val parse_manuscript: source_t -> (manuscript_t * string list, [> `Div ] XHTML.M.elt) result_t Lwt.t
val parse_composition: source_t -> (composition_t * string list, [> `Div ] XHTML.M.elt) result_t Lwt.t

val serialise_manuscript: manuscript_t -> string
val serialise_composition: composition_t -> string

