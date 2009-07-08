(********************************************************************************)
(*	Add_story.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open XHTML.M
open Eliom_parameters
open Litiom_wizard
open Common


(********************************************************************************)
(**	{2 Step 3 of the wizard}						*)
(********************************************************************************)

let step3 =
	let carrier ~carry_in:story sp _ _ =
		Database.add_story story >>= fun () ->
		Lwt.return (`Proceed ()) in
	let normal_content ~carry_in ~carry_out sp _ _ =
		Lwt.return
			(html
			(head (title (pcdata "Wizard step 3")) [])
			(body [p [pcdata "Story has been added"]]))
	in Steps.make_last
		~fallback: Visible.add_story
		~carrier
		~normal_content
		~post_params: Eliom_parameters.unit
		()


(********************************************************************************)
(**	{2 Step 2 of the wizard}						*)
(********************************************************************************)

let step2 =
	let carrier ~carry_in:login sp () (title, (intro_src, body_src)) =
		Document.parse_composition intro_src >>= fun (intro_doc, intro_out) ->
		Document.parse_manuscript body_src >>= fun (body_doc, body_out) ->
		let author = Login.to_user login in
		let story = Story.make_fresh author title intro_src intro_doc intro_out body_src body_doc body_out
		in Lwt.return (`Proceed story) in
	let normal_content ~carry_in:login ~carry_out:story ~form sp _ _ =
		Lwt.return
			(html
			(head (title (pcdata "Wizard step 2")) [])
			(body	[
				h1 [pcdata "Story preview:"];
				Story_output.output_fresh login sp story;
				form
				]))
	in Steps.make_intermediate
		~fallback: Visible.add_story
		~carrier
		~form_maker: Forms.empty
		~normal_content
		~post_params: (Eliom_parameters.string "title" ** Eliom_parameters.string "intro" ** Eliom_parameters.string "body")
		~next: step3
		()


(********************************************************************************)
(**	{2 Step 1 of the wizard}						*)
(********************************************************************************)

let step1_handler =
	let carrier ~carry_in sp () () =
		Session.get_login sp >>= fun login ->
		Lwt.return (`Proceed login) in
	let form_maker ~carry_in ~carry_out (enter_title, (enter_intro, enter_body)) =
		Lwt.return
			[
			fieldset ~a:[a_class ["form_fields"]]
				[
				legend [pcdata "Story contents:"];

				label ~a:[a_class ["textarea_label"]; a_for "enter_title"] [pcdata "Enter story title:"];
				Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_title"] ~name:enter_title ~rows:1 ~cols:80 ();
				label ~a:[a_class ["textarea_label"]; a_for "enter_intro"] [pcdata "Enter story introduction:"];
				Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_intro"] ~name:enter_intro ~rows:5 ~cols:80 ();
				label ~a:[a_class ["textarea_label"]; a_for "enter_body"] [pcdata "Enter story body:"];
				Eliom_predefmod.Xhtml.textarea ~a:[a_id "enter_body"] ~name:enter_body ~rows:10 ~cols:80 ()
				]
			] in
	let normal_content ~carry_in ~carry_out ~form sp () () =
		Lwt.return
			(html
			(head (title (pcdata "Wizard step 1")) [])
			(body [form]))
	in Steps.make_first_handler
		~carrier
		~form_maker
		~normal_content
		~next: step2
		()

