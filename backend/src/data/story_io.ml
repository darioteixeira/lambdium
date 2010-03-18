(********************************************************************************)
(*	Story_io.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open XHTML.M
open Eliom_parameters
open Prelude


(********************************************************************************)
(**	{1 Output-related functions}						*)
(********************************************************************************)

let output_metadata ?localiser maybe_login sp story =
	let localiser = Timestamp.make_localiser ?localiser maybe_login
	in div ~a:[a_class ("story_meta" :: (Login.own_element story#author maybe_login))]
		[
		h1 ~a:[a_class ["story_title"]] [pcdata story#title];
		h1 ~a:[a_class ["story_author"]] [Eliom_predefmod.Xhtml.a !!Services.show_user sp [pcdata story#author#nick] story#author#uid];
		h1 ~a:[a_class ["story_timestamp"]] [pcdata (localiser story#timestamp)];
		]


let output_gateway sp story =
	let comments_msg = match story#num_comments with 0l -> "no" | x -> Story.Id.to_string x in
	let gateway_msg = "Read entire story (" ^ comments_msg ^ " comments)"
	in p ~a:[a_class ["story_gateway"]] [Eliom_predefmod.Xhtml.a !!Services.show_story sp [pcdata gateway_msg] story#sid]


let output_handle sp story =
	li ~a:[a_class ["story_handle"]] [Eliom_predefmod.Xhtml.a !!Services.show_story sp [pcdata story#title] story#sid]


let output_blurb ?localiser maybe_login sp story =
	let metadata = output_metadata ?localiser maybe_login sp story
	and intro_out = (story#intro_out : [ `Div ] XHTML.M.elt :> [> `Div ] XHTML.M.elt)
	and gateway = output_gateway sp story
	in li ~a:[a_class ["story_blurb"]] [metadata; intro_out; gateway]


let output_full ?localiser maybe_login sp story comments =
	let comments_out = div ~a:[a_class ["story_comments"]] (List.map (Comment_io.output_full ?localiser maybe_login sp) comments)
	and add_comment () =
		let create_form (enter_sid, (enter_title, enter_body)) =
			[
			fieldset ~a:[a_class ["form_fields"]]
				[
				legend [pcdata "Enter new comment:"];
				Eliom_predefmod.Xhtml.user_type_input ~input_type:`Hidden ~name:enter_sid ~value:story#sid Story.Id.to_string ();
				label ~a:[a_class ["textarea_label"]; a_for "enter_title"] [pcdata "Enter title:"];
				Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_title"] ~name:enter_title ~rows:1 ~cols:80 ();
				label ~a:[a_class ["textarea_label"]; a_for "enter_body"] [pcdata "Enter body:"];
				Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_body"] ~name:enter_body ~rows:10 ~cols:80 ();
				]
			]
		in
		[
		div ~a:[a_class ["story_add_comment"]]
			[
			Eliom_predefmod.Xhtml.post_form ~a:[a_class ["previewable"]] ~service:!!Services.add_comment ~sp create_form ()
			]
		]

	in
	div ~a:[a_class ["story_full"]]
		(List.append
		[
		output_metadata maybe_login sp story;
		story#intro_out;
		story#body_out;
		comments_out;
		]
		(match maybe_login with
		| None		-> []
		| Some _	-> add_comment ()))


let output_fresh ?localiser login sp story =
	let metadata = output_metadata ?localiser (Some login) sp story
	and intro_out = (story#intro_out : [ `Div ] XHTML.M.elt :> [> `Div ] XHTML.M.elt)
	and body_out = (story#body_out : [ `Div ] XHTML.M.elt :> [> `Div ] XHTML.M.elt)
	in div ~a:[a_class ["story_full"; "story_preview"]] [metadata; intro_out; body_out]


(********************************************************************************)
(**	{1 Input-related functions}						*)
(********************************************************************************)

let form_for_fresh ?title ?intro_src ?body_src (enter_title, (enter_intro, enter_body)) =
	Lwt.return
		[fieldset
			[
			legend [pcdata "Story contents:"];

			label ~a:[a_class ["textarea_label"]; a_for "enter_title"] [pcdata "Enter story title:"];
			Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_title"] ~name:enter_title ?value:title ~rows:1 ~cols:80 ();
			label ~a:[a_class ["textarea_label"]; a_for "enter_intro"] [pcdata "Enter story introduction:"];
			Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_intro"] ~name:enter_intro ?value:intro_src ~rows:5 ~cols:80 ();
			label ~a:[a_class ["textarea_label"]; a_for "enter_body"] [pcdata "Enter story body:"];
			Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_body"] ~name:enter_body ?value:body_src ~rows:10 ~cols:80 ()
			]]


let form_for_images ~sp ~path ~status enter_file =
	let make_input (alias, is_uploaded) =
		let lbl = "enter_file_" ^ alias in
		let enter =
			[
			label ~a:[a_for lbl] [pcdata (Printf.sprintf "Enter file for bitmap with alias '%s':" alias)];
			Eliom_predefmod.Xhtml.file_input ~a:[a_id lbl] ~name:enter_file ();
			]
		and show = match is_uploaded with
			| true  ->
				let uri = Eliom_predefmod.Xhtml.make_uri ~service:(External.link_static (path @ [alias])) ~sp ()
				in [p [pcdata "Currently uploaded image:"]; XHTML.M.img ~src:uri ~alt:"" ()]
			| false -> []
		in enter @ show
	in Lwt.return [fieldset ([legend [pcdata "Images:"]] @ (List.flatten (List.map make_input status)))]

