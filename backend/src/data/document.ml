(********************************************************************************)
(*	Document.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type source_t = string
type output_t = [ `Div ] XHTML.M.elt
type manuscript_t = Lambdoc_core.Valid.manuscript_t
type composition_t = Lambdoc_core.Valid.composition_t


(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Invalid_manuscript of output_t
exception Invalid_composition of output_t


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let parse_manuscript src =
	Lambdoc_proxy.Client.ambivalent_manuscript_from_string `Lambtex src >>= fun doc ->
	let xhtml = Lambdoc_write_xhtml.Main.write_ambivalent_manuscript doc in
	let out : [> `Div ] XHTML.M.elt = XHTML.M.unsafe_data (Xhtmlpretty.xhtml_list_print [xhtml])
	in match doc with
		| `Valid doc -> Lwt.return (doc, out)
		| `Invalid _ -> Lwt.fail (Invalid_manuscript out)


let parse_composition src =
	Lambdoc_proxy.Client.ambivalent_composition_from_string `Lambtex src >>= fun doc ->
	let xhtml = Lambdoc_write_xhtml.Main.write_ambivalent_composition doc in
	let out : [> `Div ] XHTML.M.elt = XHTML.M.unsafe_data (Xhtmlpretty.xhtml_list_print [xhtml])
	in match doc with
		| `Valid doc -> Lwt.return (doc, out)
		| `Invalid _ -> Lwt.fail (Invalid_composition out)


let output_of_string str =
	(XHTML.M.unsafe_data str : [> `Div ] XHTML.M.elt)


let string_of_output raw =
	Xhtmlpretty.xhtml_list_print [raw]


let serialise_manuscript = Lambdoc_core.Valid.serialize_manuscript


let serialise_composition = Lambdoc_core.Valid.serialize_composition

