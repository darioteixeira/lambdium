(********************************************************************************)
(*	Edit_user_credentials.ml
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
(**	{2 Exceptions}								*)
(********************************************************************************)

exception Passwords_mismatch


(********************************************************************************)
(**	{2 Step 2 of the wizard}						*)
(********************************************************************************)

let step2 =
	let carrier ~carry_in:login sp () (old_password, (new_password, new_password2)) =
		if new_password <> new_password2
		then Lwt.fail Passwords_mismatch
		else begin
			let credentials = User.make_changed_credentials (Login.uid login) old_password new_password
			in Database.edit_user_credentials credentials >>= fun () ->
			Lwt.return (`Proceed ())
		end in
	let normal_content ~carry_in ~carry_out sp _ _ =
		Lwt.return
			(html
			(head (title (pcdata "Wizard step 2")) [])
			(body [p [pcdata "User credentials have been changed"]]))
	in Steps.make_last
		~fallback: Visible.edit_user_credentials
		~carrier
		~normal_content
		~post_params:
			(Eliom_parameters.string "old_password" **
			 Eliom_parameters.string "new_password" **
			 Eliom_parameters.string "new_password2")
		()


(********************************************************************************)
(**	{2 Step 1 of the wizard}						*)
(********************************************************************************)

let step1_handler =
	let carrier ~carry_in sp () () =
		Session.get_login sp >>= fun login ->
		Lwt.return (`Proceed login) in
	let form_maker ~carry_in ~carry_out (enter_old_password, (enter_new_password, enter_new_password2)) =
		Lwt.return
			[
			fieldset ~a:[a_class ["form_fields"]]
				[
				legend [pcdata "Enter current password for verification, and then the new password:"];
				label ~a:[a_class ["input_label"]; a_for "enter_old_password"] [pcdata "Enter current password:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_old_password"] ~input_type:`Password ~name:enter_old_password ();
				label ~a:[a_class ["input_label"]; a_for "enter_new_password"] [pcdata "Enter new password:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_new_password"] ~input_type:`Password ~name:enter_new_password ();
				label ~a:[a_class ["input_label"]; a_for "enter_new_password2"] [pcdata "Confirm new password:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_new_password2"] ~input_type:`Password ~name:enter_new_password2 ();
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

