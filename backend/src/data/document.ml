(********************************************************************************)
(*	Document.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open Prelude
open Lambdoc_core
open Lambdoc_writer.Settings


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type source_t = string
type output_t = [ `Div ] XHTML.M.elt
type manuscript_t = Valid.manuscript_t
type composition_t = Valid.composition_t


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

let output writer ~sp ~path doc =
	let bitmap_lookup bmp = Eliom_predefmod.Xhtml.make_uri ~service:(External.link_static (path @ [bmp])) ~sp () in
	let settings = Some {Lambdoc_writer.Settings.default with bitmap_lookup = bitmap_lookup} in
	let xhtml = writer ?settings doc
	in (XHTML.M.unsafe_data (Xhtmlpretty.xhtml_list_print [xhtml]) : [> `Div ] XHTML.M.elt)


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let output_of_manuscript =
	output Lambdoc_write_xhtml.Main.write_valid_manuscript


let output_of_composition =
	output Lambdoc_write_xhtml.Main.write_valid_composition


let output_of_string str =
	(XHTML.M.unsafe_data str : [> `Div ] XHTML.M.elt)


let string_of_output raw =
	Xhtmlpretty.xhtml_list_print [raw]


let parse_manuscript src =
	Lambdoc_proxy.Client.ambivalent_manuscript_from_string `Lambtex src >>= function
		| `Valid doc ->
			Lwt.return (`Okay (doc, Resource.elements doc.Valid.bitmaps))
		| `Invalid doc ->
			let xhtml = Lambdoc_write_xhtml.Main.write_invalid_manuscript doc in
			let out = (XHTML.M.unsafe_data (Xhtmlpretty.xhtml_list_print [xhtml]) : [> `Div ] XHTML.M.elt)
			in Lwt.return (`Error out)


let parse_composition src =
	Lambdoc_proxy.Client.ambivalent_composition_from_string `Lambtex src >>= function
		| `Valid doc ->
			Lwt.return (`Okay (doc, Resource.elements doc.Valid.bitmaps))
		| `Invalid doc ->
			let xhtml = Lambdoc_write_xhtml.Main.write_invalid_composition doc in
			let out = (XHTML.M.unsafe_data (Xhtmlpretty.xhtml_list_print [xhtml]) : [> `Div ] XHTML.M.elt)
			in Lwt.return (`Error out)


let serialise_manuscript = Valid.serialize_manuscript


let serialise_composition = Valid.serialize_composition

