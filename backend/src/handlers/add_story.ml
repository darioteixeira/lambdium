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
open Common


(********************************************************************************)
(**	{1 Wizards steps}							*)
(********************************************************************************)

let rec step1_handler sp () () =
	let output_core login sp =
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Visible.add_story
			~post_params: Visible.story_param
			step2_handler in
		Forms.Monatomic.make_form
			~service: step2_service
			~sp
			~content: Story_io.form_for_fresh
			~label: "Preview" >>= fun form ->
		Lwt.return [form]
	in Page.login_enforced_handler
		~sp
		~page_title: "Add story - Step 1/3"
		~output_core
		()


and step2_handler ?(errors = []) sp () (title, (intro_src, body_src)) =
	let output_core login sp =
		Document.parse_composition intro_src >>= fun (intro_doc, intro_out) ->
		Document.parse_manuscript body_src >>= fun (body_doc, body_out) ->
		let author = Login.to_user login in
		let story = Story.make_fresh author title intro_src intro_doc intro_out body_src body_doc body_out in
		let step3_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Visible.add_story
			~post_params: (Forms.Previewable.param ** Visible.story_param)
			(step3_handler story) in
		Forms.Previewable.make_form
			~service: step3_service
			~sp
			~content: Story_io.form_for_fresh >>= fun form ->
		Lwt.return (errors @ [Story_io.output_fresh login sp story; form])
	in Page.login_enforced_handler
		~sp
		~page_title: "Add story - Step 2/3"
		~output_core
		()


and step3_handler story sp () (action, (title, (intro, body))) =
	match action with
		| `Preview ->
			step2_handler sp () (title, (intro, body))
		| `Cancel ->
			let output_core login sp = Lwt.return [p [pcdata "You have cancelled!"]]
			in Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 3/3" ~output_core ()
		| `Finish ->
			Lwt.catch
				(fun () ->
					Database.add_story story >>= fun () ->
					let output_core login sp = Lwt.return [p [pcdata "Comment has been added!"]]
					in Page.login_enforced_handler ~sp ~page_title:"Add Comment - Step 2/2" ~output_core ())
				(function
					| Database.Cannot_add_story -> step2_handler ~errors:[p [pcdata "Error!"]] sp () (title, (intro, body))
					| exc -> Lwt.fail exc)

