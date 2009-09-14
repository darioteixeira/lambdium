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
open Common


(********************************************************************************)
(**	{1 Wizard steps}							*)
(********************************************************************************)

let rec step1_handler ?(errors = []) sp () (sid, (title, body_src)) =
	let output_core login sp =
		Document.parse_composition body_src >>= fun (body_doc, body_out) ->
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
			~content: (Comment_io.form_for_fresh ~sid ~title ~body_src) >>= fun form ->
		Lwt.return (errors @ [Comment_io.output_fresh sp comment; form])
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
			let output_core login sp = Lwt.return [p [pcdata "You have cancelled!"]]
			in Page.login_enforced_handler ~sp ~page_title:"Add Comment - Step 2/2" ~output_core ()
		| `Finish ->
			Lwt.catch
				(fun () ->
					Database.add_comment comment >>= fun () ->
					let output_core login sp = Lwt.return [p [pcdata "Comment has been added!"]]
					in Page.login_enforced_handler ~sp ~page_title:"Add Comment - Step 2/2" ~output_core ())
				(function
					| Database.Cannot_get_comment -> step1_handler ~errors:[p [pcdata "Error!"]] sp () (sid, (title, body))
					| exc -> Lwt.fail exc)


(********************************************************************************)
(**	{1 Fallback}								*)
(********************************************************************************)

let fallback_handler sp () () =
	Page.fallback_handler ~sp ~page_title: "Add Comment"

