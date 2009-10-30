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

let rec step1_handler ~status sp () (sid, (title, body_src)) =
	let output_core login sp =
		Comment_io.parse ~sp ~path:[] body_src >>= fun (body_doc, body_out) ->
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
		Lwt.return (status, Some [Comment_io.output_fresh (Some login) sp comment; form])
	in Page.login_enforced_handler
		~sp
		~page_title: "Add Comment - Step 1/2"
		~output_core
		()


and step2_handler comment sp () (action, (sid, (title, body))) =
	match action with
		| `Preview ->
			step1_handler ~status:Stat_nothing sp () (sid, (title, body))
		| `Cancel ->
			let output_core login sp = Lwt.return (Stat_warning [p [pcdata "You have cancelled!"]], None)
			in Page.login_enforced_handler ~sp ~page_title:"Add Comment - Step 2/2" ~output_core ()
		| `Finish ->
			try_lwt
				let output_maker cid =
					Document.string_of_output comment#body_out in
				Database.add_comment ~output_maker comment >>= fun _ ->
				let output_core login sp = Lwt.return (Stat_success [p [pcdata "Comment has been added!"]], None)
				in Page.login_enforced_handler ~sp ~page_title:"Add Comment - Step 2/2" ~output_core ()
			with
				| Database.Cannot_add_comment ->
					let status = Stat_failure [p [pcdata "Error!"]]
					in step1_handler ~status sp () (sid, (title, body))


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let fallback_handler sp () () =
	Page.fallback_handler ~sp ~page_title: "Add Comment"


let handler sp () (sid, (title, body_src)) =
	step1_handler ~status:Stat_nothing sp () (sid, (title, body_src))

