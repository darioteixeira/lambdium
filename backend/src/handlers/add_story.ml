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
open Page


(********************************************************************************)
(**	{1 Wizards steps}							*)
(********************************************************************************)

let rec step1_handler ~status ?title ?intro_src ?body_src sp () () =
	let output_core login sp =
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_story
			~post_params: Params.add_story
			(step2_handler ~login) in
		Forms.Monatomic.make_form
			~label: "Preview"
			~service: step2_service
			~sp
			~content: (Story_io.form_for_fresh ?title ?intro_src ?body_src)
			() >>= fun form ->
		Lwt.return (status, Some [form])
	in Page.login_enforced_handler
		~sp
		~page_title: "Add story - Step 1/6"
		~output_core
		()


and step2_handler ~login sp () (title, (intro_src, body_src)) =
	Lwt.catch
		(fun () ->
			Story_io.parse intro_src body_src >>= fun (intro_doc, intro_out, body_doc, body_out, bitmaps) ->
			let author = Login.to_user login in
			let story = Story.make_fresh author title intro_src intro_doc intro_out body_src body_doc body_out in
			if List.length bitmaps <> 0
			then step3 ~story ~login ~sp ~bitmaps
			else step5 ~story ~login ~sp)
		(function
			| Story_io.Invalid_story_intro intro_out ->
				let status = Stat_failure ([intro_out] :> XHTML.M.block XHTML.M.elt list)
				in step1_handler ~status ~title ~intro_src ~body_src sp () ()
			| Story_io.Invalid_story_body body_out ->
				let status = Stat_failure ([body_out] :> XHTML.M.block XHTML.M.elt list)
				in step1_handler ~status ~title ~intro_src ~body_src sp () ()
			| Story_io.Invalid_story_intro_and_body (intro_out, body_out) ->
				let status = Stat_failure ([intro_out; body_out] :> XHTML.M.block XHTML.M.elt list)
				in step1_handler ~status ~title ~intro_src ~body_src sp () ()
			| exc ->
				Lwt.fail exc)


and step3 ~story ~login ~sp ~bitmaps =
	let output_core login sp =
		let step4_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_story
			~post_params: (Forms.Triatomic.param ** (Eliom_parameters.set Eliom_parameters.file "files"))
			(step4_handler ~story ~login) in
		Forms.Triatomic.make_form
			~service: step4_service
			~sp
			~content: (Story_io.form_for_images ~bitmaps)
			() >>= fun form ->
		Lwt.return (Stat_nothing, Some [form])
	in Page.login_enforced_handler
		~sp
		~page_title: "Add story - Step 3/6"
		~output_core
		()


and step4_handler ~story ~login sp () (action, files) =
	match action with
		| `Cancel ->
			let output_core login sp = Lwt.return (Stat_warning [p [pcdata "You have cancelled!"]], None)
			in Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ~output_core ()
		| `Continue ->
			step1_handler ~status:Stat_nothing ~title:story#title ~intro_src:story#intro_src ~body_src:story#body_src sp () ()
		| `Conclude ->
			step5 ~story ~login ~sp


and step5 ~story ~login ~sp =
	let output_core login sp =
		let step6_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_story
			~post_params: (Forms.Triatomic.param ** Eliom_parameters.unit)
			(step6_handler ~story) in
		Forms.Triatomic.make_form
			~service: step6_service
			~sp
			() >>= fun form ->
		Lwt.return (Stat_nothing, Some [Story_io.output_fresh login sp story; form])
	in Page.login_enforced_handler
		~sp
		~page_title: "Add story - Step 5/6"
		~output_core
		()


and step6_handler ~story sp () (action, ()) =
	match action with
		| `Cancel ->
			let output_core login sp = Lwt.return (Stat_warning [p [pcdata "You have cancelled!"]], None)
			in Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ~output_core ()
		| `Continue ->
			step1_handler ~status:Stat_nothing ~title:story#title ~intro_src:story#intro_src ~body_src:story#body_src sp () ()
		| `Conclude ->
			Lwt.catch
				(fun () ->
					Database.add_story story >>= fun () ->
					let output_core _ _ = Lwt.return (Stat_success [p [pcdata "Story has been added!"]], None)
					in Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ~output_core ())
				(function
					| Database.Cannot_add_story ->
						let output_core _ _ = Lwt.return (Stat_failure [p [pcdata "Cannot add story!"]], None)
						in Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ~output_core ()
					| exc ->
						Lwt.fail exc)


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler sp () () =
	step1_handler ~status:Stat_nothing sp () ()

