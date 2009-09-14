(********************************************************************************)
(*	Edit_user_settings.ml
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

let rec step1_handler ?user ?(errors = []) sp () () =
	let output_core login sp =
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Visible.edit_user_settings
			~post_params: Visible.edit_user_settings_param
			(step2_handler login) in
		(match user with
			| Some u -> Lwt.return u
			| None   -> Database.get_user (Login.uid login)) >>= fun user ->
		Forms.Monatomic.make_form
			~service: step2_service
			~sp
			~content: (User_io.form_for_changed_settings ~user)
			~label: "Change settings" >>= fun form ->
		Lwt.return (errors @ [form])
	in Page.login_enforced_handler
		~sp
		~page_title: "Edit settings - Step 1/2"
		~output_core
		()


and step2_handler login sp () (fullname, timezone) =
	Lwt.catch
		(fun () ->
			let output_core login sp = Lwt.return [p [pcdata "User settings have been changed"]] in
			let settings = User.make_changed_settings (Login.uid login) fullname timezone in
			Database.edit_user_settings settings >>= fun () ->
			Page.login_enforced_handler ~sp ~page_title:"Edit settings - Step 2/2" ~output_core ())
		(function
			| Database.Cannot_edit_user_settings -> step1_handler ~errors:[p [pcdata "Error!"]] sp () ()
			| exc -> Lwt.fail exc)

