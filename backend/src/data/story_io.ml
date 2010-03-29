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
open Document


(********************************************************************************)
(**	{1 Output-related functions}						*)
(********************************************************************************)

let output_metadata ?localiser maybe_login sp story =
	let localiser = Timestamp.make_localiser ?localiser maybe_login
	in div ~a:[a_class ("story_meta" :: (Login.own_element story#author maybe_login))]
		[
		h1 ~a:[a_class ["story_title"]] [pcdata story#title];
		h2 ~a:[a_class ["story_author"]] [pcdata "by "; Eliom_predefmod.Xhtml.a !!Services.show_user sp [pcdata story#author#nick] story#author#uid];
		h2 ~a:[a_class ["story_timestamp"]] [pcdata "on "; pcdata (localiser story#timestamp)];
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
	in li ~a:[a_class ["story"; "story_blurb"]] [metadata; intro_out; gateway]


let output_full ?localiser maybe_login sp story comments =
	let form_maker () = match maybe_login with
		| Some _ ->
			Forms.Monatomic.make_form
				~label: "Preview"
				~service: !!Services.add_comment
				~sp
				~content: (Comment_io.form_for_incipient ~sid:story#sid)
				() >>= fun form ->
			Lwt.return [form]
		| None ->
			Lwt.return [] in
	form_maker () >>= fun form ->
	Lwt.return (div ~a:[a_class ["story"; "story_full"]]
		([
		output_metadata maybe_login sp story;
		(story#intro_out : [ `Div ] XHTML.M.elt :> [> `Div ] XHTML.M.elt);
		(story#body_out : [ `Div ] XHTML.M.elt :> [> `Div ] XHTML.M.elt);
		div ~a:[a_class ["story_comments"]] (List.map (Comment_io.output_full ?localiser maybe_login sp) comments);
		] @ form))


let output_fresh ?localiser login sp story =
	let metadata = output_metadata ?localiser (Some login) sp story
	and intro_out = (story#intro_out : [ `Div ] XHTML.M.elt :> [> `Div ] XHTML.M.elt)
	and body_out = (story#body_out : [ `Div ] XHTML.M.elt :> [> `Div ] XHTML.M.elt)
	in div ~a:[a_class ["story"; "story_full"; "story_preview"]] [metadata; intro_out; body_out]


(********************************************************************************)
(**	{1 Input-related functions}						*)
(********************************************************************************)

let form_for_incipient ?story (enter_title, (enter_intro_mrk, (enter_intro_src, (enter_body_mrk, enter_body_src)))) =
	let (title, intro_mrk, intro_src, body_mrk, body_src) = match story with
		| Some s -> (Some s#title, Some s#intro_mrk, Some s#intro_src, Some s#body_mrk, Some s#body_src)
		| None   -> (None, None, None, None, None)
	in Lwt.return
		[fieldset
			[
			legend [pcdata "Story contents:"];

			label ~a:[a_class ["textarea_label"]; a_for "enter_title"] [pcdata "Story title:"];
			Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_title"] ~input_type:`Text ~name:enter_title ?value:title ();

			label ~a:[a_class ["textarea_label"]; a_for "enter_intro_mrk"] [pcdata "Markup:"];
			Markup.select ~a:[a_id "enter_intro_mrk"] ~name:enter_intro_mrk ?value:intro_mrk ();

			label ~a:[a_class ["textarea_label"]; a_for "enter_intro_src"] [pcdata "Story introduction:"];
			Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_intro_src"] ~name:enter_intro_src ?value:intro_src ~rows:8 ~cols:80 ();

			label ~a:[a_class ["textarea_label"]; a_for "enter_body_mrk"] [pcdata "Markup:"];
			Markup.select ~a:[a_id "enter_body_mrk"] ~name:enter_body_mrk ?value:body_mrk ();

			label ~a:[a_class ["textarea_label"]; a_for "enter_body_src"] [pcdata "Story body:"];
			Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_body_src"] ~name:enter_body_src ?value:body_src ~rows:16 ~cols:80 ()
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
				let uri = Eliom_predefmod.Xhtml.make_uri ~service:(External.static (path @ [alias])) ~sp ()
				in [p [pcdata "Currently uploaded image:"]; XHTML.M.img ~src:uri ~alt:"" ()]
			| false -> []
		in enter @ show
	in Lwt.return [fieldset ([legend [pcdata "Images:"]] @ (List.flatten (List.map make_input status)))]

