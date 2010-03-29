(********************************************************************************)
(*	Document.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open XHTML.M
open Prelude
open Lambdoc_core
open Lambdoc_writer.Settings
open Lambdoc_proxy.Client


(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Invalid_manuscript of [ `Div ] XHTML.M.elt
exception Invalid_composition of [ `Div ] XHTML.M.elt


(********************************************************************************)
(**	{1 Modules}								*)
(********************************************************************************)

module Markup =
struct
	include Lambdoc_proxy.Markup.M

	let of_string = function
		| "lambtex"  -> Lambtex
		| "lambhtml" -> Lambhtml
		| "lamblite" -> Lamblite
		| _	     -> invalid_arg "Markup.of_string"

	let to_string = function
		| Lambtex  -> "lambtex"
		| Lambhtml -> "lambhtml"
		| Lamblite -> "lamblite"

	let param = Eliom_parameters.user_type ~of_string ~to_string

	let select ?a ~name ?value () =
		let option_of_markup markup =
			let is_selected = match value with
				| Some v -> markup = v
				| None   -> markup = Lambtex
			in Eliom_predefmod.Xhtml.Option ([], markup, Some (XHTML.M.pcdata (to_string markup)), is_selected)
		in Eliom_predefmod.Xhtml.user_type_select
			to_string
			?a
			~name
			(option_of_markup Lambtex)
			[
			option_of_markup Lambhtml;
			option_of_markup Lamblite;
			]
end


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

let socket =
	{
	sockaddr = !Config.sockaddr;
	sockdomain = !Config.sockdomain;
	socktype = !Config.socktype;
	sockproto = !Config.sockproto;
	}


let output writer ~sp ~path doc =
	let image_lookup img = Eliom_predefmod.Xhtml.make_uri ~service:(External.static (path @ [img])) ~sp () in
	let settings = Some {Lambdoc_writer.Settings.default with image_lookup = image_lookup} in                     
	let xhtml = writer ?settings doc                                                                              
	in (XHTML.M.unsafe_data (Xhtmlpretty.xhtml_list_print [xhtml]) : [> `Div ] XHTML.M.elt)                       


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let dummy_output =
	XHTML.M.div []


let output_of_manuscript =
	output Lambdoc_write_xhtml.Main.write_valid_manuscript


let output_of_composition =
	output Lambdoc_write_xhtml.Main.write_valid_composition


let parse_manuscript ~markup src =
	ambivalent_manuscript_from_string ~socket ~markup src >>= function
		| `Valid doc ->
			Lwt.return (`Okay (doc, doc.Valid.images))
		| `Invalid doc ->
			let xhtml = Lambdoc_write_xhtml.Main.write_invalid_manuscript doc in
			let out = (XHTML.M.unsafe_data (Xhtmlpretty.xhtml_list_print [xhtml]) : [> `Div ] XHTML.M.elt)
			in Lwt.return (`Error out)


let parse_composition ~markup src =
	ambivalent_composition_from_string ~socket ~markup src >>= function
		| `Valid doc ->
			Lwt.return (`Okay (doc, doc.Valid.images))
		| `Invalid doc ->
			let xhtml = Lambdoc_write_xhtml.Main.write_invalid_composition doc in
			let out = (XHTML.M.unsafe_data (Xhtmlpretty.xhtml_list_print [xhtml]) : [> `Div ] XHTML.M.elt)
			in Lwt.return (`Error out)


let parse_manuscript_exc ~markup src =
	parse_manuscript ~markup src >>= function
		| `Okay x  -> Lwt.return x
		| `Error x -> Lwt.fail (Invalid_manuscript x)


let parse_composition_exc ~markup src =
	parse_composition ~markup src >>= function
		| `Okay x  -> Lwt.return x
		| `Error x -> Lwt.fail (Invalid_composition x)


let serialise_manuscript = Valid.serialize_manuscript


let serialise_composition = Valid.serialize_composition


let serialise_output raw =
	Xhtmlpretty.xhtml_list_print [raw]


let deserialise_output str =
	(XHTML.M.unsafe_data str : [> `Div ] XHTML.M.elt)

