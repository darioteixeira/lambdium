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

let rec step1_handler ?token ?title ?intro_src ?body_src sp () () =
	let output_core login sp =
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_story
			~post_params: Params.add_story
			(step2_handler ?token ~login) in
		Forms.Monatomic.make_form
			~label: "Preview"
			~service: step2_service
			~sp
			~content: (Story_io.form_for_fresh ?title ?intro_src ?body_src)
			() >>= fun form ->
		Lwt.return [form]
	in Page.login_enforced_handler
		~sp
		~page_title: "Add story - Step 1/6"
		~output_core
		()


and step2_handler ?token ~login sp () (title, (intro_src, body_src)) =
	(match token with
		| Some t -> Lwt.return t
		| None	 -> Uploader.request ~sp ~uid:(Login.uid login) ~limit:3) >>= fun token ->
	Document.parse_composition intro_src >>= fun intro_res ->
	Document.parse_manuscript body_src >>= fun body_res ->
	match (intro_res, body_res) with
		| (`Okay (intro_doc, _), `Okay (body_doc, images)) ->
			let path = Uploader.get_path token in
			let intro_out = Document.output_of_composition ~sp ~path intro_doc in
			let body_out = Document.output_of_manuscript ~sp ~path body_doc in
			let author = Login.to_user login in
			let story = Story.make_fresh author title intro_src intro_doc intro_out body_src body_doc body_out in
			if List.length images <> 0
			then step3 ~token ~story ~login ~sp ~images
			else step5 ~token ~story ~login ~sp
		| (`Error intro_err, `Error body_err) ->
			Status.failure ~sp [pcdata "Error in story intro and body:"] ([intro_err; body_err] :> XHTML.M.block XHTML.M.elt list);
			step1_handler ~title ~intro_src ~body_src sp () ()
		| (`Error intro_err, _) ->
			Status.failure ~sp [pcdata "Error in story intro:"] ([intro_err] :> XHTML.M.block XHTML.M.elt list);
			step1_handler ~title ~intro_src ~body_src sp () ()
		| (_, `Error body_err) ->
			Status.failure ~sp [pcdata "Error in story body:"] ([body_err] :> XHTML.M.block XHTML.M.elt list);
			step1_handler ~title ~intro_src ~body_src sp () ()


and step3 ~token ~story ~login ~sp ~images =
	let output_core login sp =
		let step4_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_story
			~post_params: (Forms.Triatomic.param ** (Eliom_parameters.set Eliom_parameters.file "files"))
			(step4_handler ~token ~story ~login ~images) in
		Forms.Triatomic.make_form
			~service: step4_service
			~sp
			~content: (Story_io.form_for_images ~sp ~path:(Uploader.get_path token) ~status:(Uploader.get_status images token))
			() >>= fun form ->
		Lwt.return [form]
	in Page.login_enforced_handler
		~sp
		~page_title: "Add story - Step 3/6"
		~output_core
		()


and step4_handler ~token ~story ~login ~images sp () (action, files) =
	match action with
		| `Cancel ->
			Uploader.discard token >>= fun () ->
			Status.warning ~sp [pcdata "You have cancelled!"] [];
			Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ()
		| `Continue ->
			Uploader.add_files images files token >>= fun _ ->
			step1_handler ~token ~title:story#title ~intro_src:story#intro_src ~body_src:story#body_src sp () ()
		| `Conclude ->
			Uploader.add_files images files token >>= function
				| true  -> step5 ?token ~story ~login ~sp
				| false -> step3 ?token ~story ~login ~sp ~images


and step5 ~token ~story ~login ~sp =
	let output_core login sp =
		let step6_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_story
			~post_params: (Forms.Triatomic.param ** Eliom_parameters.unit)
			(step6_handler ?token ~story) in
		Forms.Triatomic.make_form
			~service: step6_service
			~sp
			() >>= fun form ->
		Lwt.return [Story_io.output_fresh login sp story; form]
	in Page.login_enforced_handler
		~sp
		~page_title: "Add story - Step 5/6"
		~output_core
		()


and step6_handler ~token ~story sp () (action, ()) =
	match action with
		| `Cancel ->
			Uploader.discard token >>= fun () ->
			Status.warning ~sp [pcdata "You have cancelled!"] [];
			Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ()
		| `Continue ->
			step1_handler ~token ~title:story#title ~intro_src:story#intro_src ~body_src:story#body_src sp () ()
		| `Conclude ->
			try_lwt

				let path_maker sid = [!Config.story_dir; Story.Id.to_string sid] in
				let output_maker sid =
					let path = path_maker sid in
					let intro_xout = Document.serialise_output (Document.output_of_composition ~sp ~path story#intro_doc)
					and body_xout = Document.serialise_output (Document.output_of_manuscript ~sp ~path story#body_doc)
					in (intro_xout, body_xout) in
				Database.add_story ~output_maker story >>= fun sid ->
				Uploader.commit ~path:(path_maker sid) token >>= fun () ->
				Status.success ~sp [pcdata "Story has been added!"] [];
				Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ()
			with
				| Database.Cannot_add_story ->
					Status.failure ~sp [pcdata "Cannot add story!"] [];
					Page.login_enforced_handler ~sp ~page_title:"Add Story - Step 6/6" ()


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler = step1_handler

