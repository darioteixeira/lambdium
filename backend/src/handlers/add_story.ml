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
open Prelude
open Page


(********************************************************************************)
(**	{1 Wizards steps}							*)
(********************************************************************************)

let rec step1_handler ?maybe_token ?title ?intro_src ?body_src ~status sp () () =
	let output_core login sp =
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_story
			~post_params: Params.add_story
			(step2_handler ?maybe_token ~login) in
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


and step2_handler ?maybe_token ~login sp () (title, (intro_src, body_src)) =
	try_lwt
		Story_io.parse intro_src body_src >>= fun (intro_doc, intro_out, body_doc, body_out, bitmaps) ->
		let author = Login.to_user login in
		let story = Story.make_fresh author title intro_src intro_doc intro_out body_src body_doc body_out in
		if List.length bitmaps <> 0
		then step3 ?maybe_token ~story ~login ~sp ~bitmaps
		else step5 ?maybe_token ~story ~login ~sp
	with
		| Story_io.Invalid_story_intro intro_out ->
			let status = Stat_failure ([intro_out] :> XHTML.M.block XHTML.M.elt list)
			in step1_handler ~title ~intro_src ~body_src ~status sp () ()
		| Story_io.Invalid_story_body body_out ->
			let status = Stat_failure ([body_out] :> XHTML.M.block XHTML.M.elt list)
			in step1_handler ~title ~intro_src ~body_src ~status sp () ()
		| Story_io.Invalid_story_intro_and_body (intro_out, body_out) ->
			let status = Stat_failure ([intro_out; body_out] :> XHTML.M.block XHTML.M.elt list)
			in step1_handler ~title ~intro_src ~body_src ~status sp () ()


and step3 ?maybe_token ~story ~login ~sp ~bitmaps =
	let token = match maybe_token with
		| Some t -> t
		| None	 -> Uploader.request ~sp ~uid:(Login.uid login) ~limit:3 in
	let output_core login sp =
		let step4_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_story
			~post_params: (Forms.Triatomic.param ** (Eliom_parameters.set Eliom_parameters.file "files"))
			(step4_handler ~token ~story ~login ~bitmaps) in
		Forms.Triatomic.make_form
			~service: step4_service
			~sp
			~content: (Story_io.form_for_images ~status:(Uploader.get_status bitmaps token))
			() >>= fun form ->
		Lwt.return (Stat_nothing, Some [form])
	in Page.login_enforced_handler
		~sp
		~page_title: "Add story - Step 3/6"
		~output_core
		()


and step4_handler ~token ~story ~login ~bitmaps sp () (action, files) =
	match action with
		| `Cancel ->
			Uploader.discard token;
			let output_core login sp = Lwt.return (Stat_warning [p [pcdata "You have cancelled!"]], None)
			in Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ~output_core ()
		| `Continue ->
			step1_handler ?maybe_token:(Some token) ~title:story#title ~intro_src:story#intro_src ~body_src:story#body_src ~status:Stat_nothing sp () ()
		| `Conclude ->
			Uploader.add_files bitmaps files token >>= function
				| true  -> step5 ?maybe_token:(Some token) ~story ~login ~sp
				| false -> step3 ?maybe_token:(Some token) ~story ~login ~sp ~bitmaps


and step5 ?maybe_token ~story ~login ~sp =
	let output_core login sp =
		let step6_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_story
			~post_params: (Forms.Triatomic.param ** Eliom_parameters.unit)
			(step6_handler ?maybe_token ~story) in
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


and step6_handler ?maybe_token ~story sp () (action, ()) =
	match action with
		| `Cancel ->
			Option.may Uploader.discard maybe_token;
			let output_core login sp = Lwt.return (Stat_warning [p [pcdata "You have cancelled!"]], None)
			in Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ~output_core ()
		| `Continue ->
			step1_handler ?maybe_token ~title:story#title ~intro_src:story#intro_src ~body_src:story#body_src ~status:Stat_nothing sp () ()
		| `Conclude ->
			try_lwt
				Database.add_story story >>= fun sid ->
				lwt_may (Uploader.commit (!Config.story_data_dir ^ "/" ^ Story.Id.to_string sid)) maybe_token >>= fun () ->
				let output_core _ _ = Lwt.return (Stat_success [p [pcdata "Story has been added!"]], None)
				in Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ~output_core ()
			with
				| Database.Cannot_add_story ->
					let output_core _ _ = Lwt.return (Stat_failure [p [pcdata "Cannot add story!"]], None)
					in Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ~output_core ()


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler sp () () =
	Eliom_sessions.set_global_service_session_timeout ~sp (Some 120.0);
	Eliom_sessions.set_service_session_timeout ~sp (Some 120.0);
	step1_handler ~status:Stat_nothing sp () ()

