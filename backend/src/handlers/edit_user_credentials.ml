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
open Common


(********************************************************************************)
(**	{1 Wizard steps}							*)
(********************************************************************************)

let rec step1_handler ?(errors = []) sp () () =
	let output_core login sp =
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Visible.edit_user_credentials
			~post_params: Visible.edit_user_credentials_param
			(step2_handler login) in
		Forms.Monatomic.make_form
			~service: step2_service
			~sp
			~content: User_io.form_for_changed_credentials
			~label: "Change password" >>= fun form ->
		Lwt.return (errors @ [form])
	in Page.login_enforced_handler
		~sp
		~page_title: "Change password - Step 1/2"
		~output_core
		()


and step2_handler login sp () (old_password, (new_password, new_password2)) =
	if new_password <> new_password2
	then
		step1_handler ~errors:[p [pcdata "Passwords do not match!"]] sp () ()
	else
		Lwt.catch
			(fun () ->
				let output_core login sp = Lwt.return [p [pcdata "Password has been changed!"]] in
				let credentials = User.make_changed_credentials (Login.uid login) old_password new_password in
				Database.edit_user_credentials credentials >>= fun () ->
				Page.login_enforced_handler ~sp ~page_title:"Change password - Step 2/2" ~output_core ())
			(function
				| Database.Cannot_edit_user_credentials -> step1_handler ~errors:[p [pcdata "Error!"]] sp () ()
				| exc -> Lwt.fail exc)

