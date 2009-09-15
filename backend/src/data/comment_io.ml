(********************************************************************************)
(*	Comment_io.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open XHTML.M
open Eliom_parameters
open Common


(********************************************************************************)
(**	{1 Output-related functions}						*)
(********************************************************************************)

let output_metadata maybe_login sp comment =
	div ~a:[a_class ("comment_meta" :: (Login.own_element comment#author maybe_login))]
		[
		h1 ~a:[a_class ["comment_author"]] [Eliom_predefmod.Xhtml.a !!Services.show_user sp [pcdata comment#author#nick] comment#author#uid];
		h1 ~a:[a_class ["comment_title"]] [pcdata comment#title];
		h1 ~a:[a_class ["comment_timestamp"]] [pcdata comment#timestamp];
		]


let output_handle sp comment =
	li ~a:[a_class ["comment_handle"]]
		[
		Eliom_predefmod.Xhtml.a !!Services.show_comment sp [pcdata comment#title] comment#cid
		]


let output_full maybe_login sp comment =
	div ~a:[a_class ["comment_full"]]
		[
		output_metadata maybe_login sp comment;
		comment#body_out
		]


let output_fresh sp comment =
	div ~a:[a_class ["comment_full"; "comment_preview"]]
		[
		output_metadata None sp comment;
		comment#body_out
		]


(********************************************************************************)
(**	{1 Input-related functions}						*)
(********************************************************************************)

let form_for_fresh ~sid ~title ~body_src (enter_sid, (enter_title, enter_body)) =
	Lwt.return
		[fieldset
			[
			legend [pcdata "Enter comment:"];

			Eliom_predefmod.Xhtml.user_type_input ~input_type:`Hidden ~name:enter_sid ~value:sid Story.Id.to_string;
			label ~a:[a_class ["textarea_label"]; a_for "enter_title"] [pcdata "Enter title:"];
			Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_title"] ~name:enter_title ~value:(pcdata title) ~rows:1 ~cols:80 ();
			label ~a:[a_class ["textarea_label"]; a_for "enter_body"] [pcdata "Enter body:"];
			Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_body"] ~name:enter_body ~value:(pcdata body_src) ~rows:10 ~cols:80 ();
			]]

