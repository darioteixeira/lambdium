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
open Litiom_wizard
open Common


(********************************************************************************)
(**	{2 Step 2 of the wizard}						*)
(********************************************************************************)

let step2 =
	let carrier ~carry_in:comment sp _ _ =
		Database.add_comment comment >>= fun () ->
		Lwt.return (`Proceed ()) in
	let normal_content ~carry_in ~carry_out sp _ _ =
		Lwt.return
			(html
			(head (title (pcdata "Wizard step 2")) [])
			(body [p [pcdata "Comment has been added"]]))
	in Steps.make_last
		~fallback: Visible.add_comment_fallback
		~carrier
		~normal_content
		~post_params: Eliom_parameters.unit
		()


(********************************************************************************)
(**	{2 Step 1 of the wizard}						*)
(********************************************************************************)

let step1_handler =
	let carrier ~carry_in sp () (sid, (title, body_src)) =
		Session.get_login sp >>= fun login ->
		Document.parse_composition body_src >>= fun (body_doc, body_out) ->
		let author = Login.to_user login in
		let comment = Comment.make_fresh sid author title body_src body_doc body_out
		in Lwt.return (`Proceed comment) in
	let normal_content ~carry_in ~carry_out:comment ~form sp _ _ =
		Lwt.return
			(html
			(head (title (pcdata "Wizard step 1")) [])
			(body	[
				h1 [pcdata "Comment preview:"];
				Comment_output.output_fresh sp comment;
				form
				]))
	in Steps.make_first_handler
		~carrier
		~form_maker: Forms.empty
		~normal_content
		~next: step2
		()


(********************************************************************************)
(**	{2 Wizard fallback (if no POST parameters are given)}			*)
(********************************************************************************)

let step1_fallback_handler sp () () =
        Lwt.return
                (html
                (head (title (pcdata "Wizard fallback")) [])
                (body [p [pcdata "This is the fallback"]]))

