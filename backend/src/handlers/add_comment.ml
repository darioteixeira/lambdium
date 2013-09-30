(********************************************************************************)
(*	Add_comment.ml
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
open Page


(********************************************************************************)
(**	{1 Wizard steps}							*)
(********************************************************************************)

let rec step1_handler sp () (sid, (title, (body_mrk, body_src))) =
	let output_core login sp =
		Document.parse_composition_exc ~markup:body_mrk body_src >>= fun (body_doc, _) ->
		let body_out = Document.output_of_composition ~sp ~path:[] body_doc in
		let author = Login.to_user login in
		let comment = Comment.make_fresh sid author title body_mrk body_src body_doc body_out in
		let path_maker cid = [!Config.comment_dir; Comment.Id.to_string cid] in
		let output_maker cid =
			let path = path_maker cid
			in Document.serialise_output (Document.output_of_composition ~sp ~path comment#body_doc) in
		Database.add_comment ~output_maker comment >>= fun cid ->
		Status.success ~sp [pcdata "Comment has been added!"] [];
		Show_comment.handler sp cid ()


		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_comment_fallback
			~post_params: (Forms.Previewable.param ** Params.add_comment)
			(step2_handler ~comment) in
		Forms.Previewable.make_form
			~service: step2_service
			~sp
			~content: (Comment_io.form_for_incipient ~comment:(comment :> Comment.incipient_t))
			() >>= fun form ->
		Lwt.return [Comment_io.output_fresh (Some login) sp comment; form]
	in Page.login_enforced_handler
		~sp
		~page_title: "Add Comment - Step 1/2"
		~output_core
		()


and step2_handler ~comment sp () (action, (sid, (title, body))) =
	match action with
		| `Preview ->
			step1_handler sp () (sid, (title, body))
		| `Cancel ->
			Status.warning ~sp [pcdata "You have cancelled!"] [];
			Page.login_enforced_handler ~sp ~page_title:"Add Comment - Step 2/2" ()
		| `Finish ->
			try_lwt
				let path_maker cid = [!Config.comment_dir; Comment.Id.to_string cid] in
				let output_maker cid =
					let path = path_maker cid
					in Document.serialise_output (Document.output_of_composition ~sp ~path comment#body_doc) in
				Database.add_comment ~output_maker comment >>= fun cid ->
				Status.success ~sp [pcdata "Comment has been added!"] [];
				Show_comment.handler sp cid ()
			with
				exc ->
					Status.failure ~sp [pcdata "Error!"] [];
					step1_handler sp () (sid, (title, body))


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let fallback_handler sp () () =
	Page.fallback_handler ~sp ~page_title: "Add Comment"


let handler = step1_handler

