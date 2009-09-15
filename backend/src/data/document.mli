(********************************************************************************)
(*	Document.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type timestamp_t = string
type source_t = string
type output_t = [ `Div ] XHTML.M.elt
type manuscript_t
type composition_t


(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Invalid_manuscript of output_t
exception Invalid_composition of output_t


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

val parse_manuscript: string -> (manuscript_t * [> `Div ] XHTML.M.elt) Lwt.t
val parse_composition: string -> (composition_t * [> `Div ] XHTML.M.elt) Lwt.t

val output_of_string: string -> output_t
val string_of_output: output_t -> string

val serialise_manuscript: manuscript_t -> string
val serialise_composition: composition_t -> string

