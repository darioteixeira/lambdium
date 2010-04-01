(********************************************************************************)
(*	Comment_io.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open XHTML.M
open Eliom_parameters
open Prelude
open Document


(********************************************************************************)
(**	{1 Output-related functions}						*)
(********************************************************************************)

let output_metadata ?localiser maybe_login sp comment =
	let localiser = Timestamp.make_localiser ?localiser maybe_login
	in div ~a:[a_class ("comment_meta" :: (Login.own_element comment#author maybe_login))]
		[
		h1 ~a:[a_class ["comment_title"]] [pcdata comment#title];
		h1 ~a:[a_class ["comment_author"]] [Eliom_predefmod.Xhtml.a !!Services.show_user sp [pcdata comment#author#nick] comment#author#uid];
		h1 ~a:[a_class ["comment_timestamp"]] [pcdata (localiser comment#timestamp)];
		]


let output_handle sp comment =
	li ~a:[a_class ["comment_handle"]]
		[
		Eliom_predefmod.Xhtml.a !!Services.show_comment sp [pcdata comment#title] comment#cid
		]


let output_full ?localiser maybe_login sp comment =
	div ~a:[a_class ["comment_full"]]
		[
		output_metadata ?localiser maybe_login sp comment;
		comment#body_out
		]


let output_fresh = output_full


(********************************************************************************)
(**	{1 Input-related functions}						*)
(********************************************************************************)

let form_for_incipient ~sid ?comment (enter_sid, (enter_title, (enter_body_mrk, (enter_body_src)))) =
	let (title, body_mrk, body_src) = match comment with
		| Some c -> (Some c#title, Some c#body_mrk, Some c#body_src)
		| None	 -> (None, None, None)
	in Lwt.return
		[
		fieldset ~a:[a_id "comment_set"]
			[
			legend [pcdata "Enter comment:"];

			Eliom_predefmod.Xhtml.user_type_input ~input_type:`Hidden ~name:enter_sid ~value:sid Story.Id.to_string ();

			div ~a:[a_class ["field"; "area_field"]]
				[
				label ~a:[a_for "enter_title"] [pcdata "Comment title:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_title"] ~input_type:`Text ~name:enter_title ?value:title ();
				];

			div ~a:[a_class ["field"; "area_field"]]
				[
				div ~a:[a_class ["markup_field"]]
					[
					label ~a:[a_for "enter_body_mrk"] [pcdata "Markup:"];
					Markup.select ~a:[a_id "enter_body_mrk"] ~name:enter_body_mrk ?value:body_mrk ();
					];
				label ~a:[a_for "enter_body_src"] [pcdata "Comment body:"];
				Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_body_src"] ~name:enter_body_src ?value:body_src ~rows:8 ~cols:80 ();
				];
			]
		]

