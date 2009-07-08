(********************************************************************************)
(*	Document.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt

type timestamp_t = string
type source_t = string
type output_t = [ `Div ] XHTML.M.elt
type manuscript_t = Lambdoc_core.Valid.manuscript_t
type composition_t = Lambdoc_core.Valid.composition_t


exception Invalid_document of output_t


let parse_manuscript src =
	Lambdoc_proxy.Client.ambivalent_manuscript_from_string `Lambtex src >>= fun doc ->
	let xhtml = Write_xhtml.Main.write_ambivalent_manuscript doc in
	let out : [> `Div ] XHTML.M.elt = XHTML.M.unsafe_data (Xhtmlpretty.xhtml_list_print [xhtml])
	in match doc with
		| `Valid doc -> Lwt.return (doc, out)
		| `Invalid doc -> Lwt.fail (Invalid_document out)


let parse_composition src =
	Lambdoc_proxy.Client.ambivalent_composition_from_string `Lambtex src >>= fun doc ->
	let xhtml = Write_xhtml.Main.write_ambivalent_composition doc in
	let out : [> `Div ] XHTML.M.elt = XHTML.M.unsafe_data (Xhtmlpretty.xhtml_list_print [xhtml])
	in match doc with
		| `Valid doc -> Lwt.return (doc, out)
		| `Invalid doc -> Lwt.fail (Invalid_document out)


let output_of_string str =
	(XHTML.M.unsafe_data str : [> `Div ] XHTML.M.elt)


let string_of_output raw =
	Xhtmlpretty.xhtml_list_print [raw]


let serialise_manuscript = Lambdoc_core.Valid.serialize_manuscript_to_sexp


let serialise_composition = Lambdoc_core.Valid.serialize_composition_to_sexp

