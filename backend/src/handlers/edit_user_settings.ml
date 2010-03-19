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
open Prelude
open Page


(********************************************************************************)
(**	{1 Wizard steps}							*)
(********************************************************************************)

let rec step1_handler ?user sp () () =
	let output_core login sp =
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.edit_user_settings
			~post_params: Params.edit_user_settings
			(step2_handler ~login) in
		(match user with
			| Some u -> Lwt.return u
			| None   -> Database.get_user (Login.uid login)) >>= fun user ->
		Forms.Monatomic.make_form
			~label: "Change settings"
			~service: step2_service
			~sp
			~content: (User_io.form_for_changed_settings ~user)
			() >>= fun form ->
		Lwt.return [form]
	in Page.login_enforced_handler
		~sp
		~page_title: "Edit settings - Step 1/2"
		~output_core
		()


and step2_handler ~login sp () (fullname, timezone) =
	try_lwt
		let settings = User.make_changed_settings (Login.uid login) fullname timezone in
		Database.edit_user_settings settings >>= fun () ->
		Session.update_login sp login >>= fun () ->
		Status.success ~sp [pcdata "User settings have been changed"] [];
		Page.login_enforced_handler ~sp ~page_title:"Edit settings - Step 2/2" ()
	with
		| Database.Cannot_edit_user_settings ->
			Status.failure ~sp [pcdata "Error!"] [];
			step1_handler sp () ()


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler = step1_handler

