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
open Prelude
open Page


(********************************************************************************)
(**	{1 Wizard steps}							*)
(********************************************************************************)

let rec step1_handler sp () () =
	let output_core login sp =
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.edit_user_credentials
			~post_params: Params.edit_user_credentials
			(step2_handler login) in
		Forms.Monatomic.make_form
			~label: "Change password"
			~service: step2_service
			~sp
			~content: User_io.form_for_changed_credentials
			() >>= fun form ->
		Lwt.return [form]
	in Page.login_enforced_handler
		~sp
		~page_title: "Change password - Step 1/2"
		~output_core
		()


and step2_handler login sp () (old_password, (new_password, new_password2)) =
	if new_password <> new_password2
	then begin
		Status.failure ~sp [pcdata "Passwords do not match!"] [];
		step1_handler sp () ()
	end
	else
		try_lwt
			let uid = Login.uid login in
			let credentials = User.make_changed_credentials uid old_password new_password in
			Database.edit_user_credentials credentials >>= fun () ->
			Status.success ~sp [pcdata "Password has been changed!"] [];
			Show_user.handler sp uid ()
		with
			exc ->
				Status.failure ~sp [pcdata "Error!"] [];
				step1_handler sp () ()


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler = step1_handler

