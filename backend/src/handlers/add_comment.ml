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
open Page


(********************************************************************************)
(**	{1 Wizard steps}							*)
(********************************************************************************)

let rec step1_handler sp () (sid, (title, body_src)) =
	let output_core login sp =
		Comment_io.parse body_src >>= fun (body_doc, body_out) ->
		let author = Login.to_user login in
		let comment = Comment.make_fresh sid author title body_src body_doc body_out in
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_comment_fallback
			~post_params: (Forms.Previewable.param ** Params.add_comment)
			(step2_handler comment) in
		Forms.Previewable.make_form
			~service: step2_service
			~sp
			~content: (Comment_io.form_for_fresh ~sid ~title ~body_src)
			() >>= fun form ->
		Lwt.return [Comment_io.output_fresh (Some login) sp comment; form]
	in Page.login_enforced_handler
		~sp
		~page_title: "Add Comment - Step 1/2"
		~output_core
		()


and step2_handler comment sp () (action, (sid, (title, body))) =
	match action with
		| `Preview ->
			step1_handler sp () (sid, (title, body))
		| `Cancel ->
			Status.warning ~sp [p [pcdata "You have cancelled!"]];
			Page.login_enforced_handler ~sp ~page_title:"Add Comment - Step 2/2" ()
		| `Finish ->
			try_lwt
				Database.add_comment comment >>= fun _ ->
				Status.success ~sp [p [pcdata "Comment has been added!"]];
				Page.login_enforced_handler ~sp ~page_title:"Add Comment - Step 2/2" ()
			with
				| Database.Cannot_add_comment ->
					Status.failure ~sp [p [pcdata "Error!"]];
					step1_handler sp () (sid, (title, body))


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let fallback_handler sp () () =
	Page.fallback_handler ~sp ~page_title: "Add Comment"


let handler = step1_handler

